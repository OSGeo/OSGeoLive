% Matlab script to sort and plot disk usage.
%   written by Hamish Bowman, Dunedin, NZ, July/August 2013
%
% Copyright (c) 2013 Hamish Bowman, and The Open Source Geospatial Foundation
% Licensed under the GNU LGPL version >= 2.1.
%
% This script is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published
% by the Free Software Foundation, either version 2.1 of the License,
% or any later version.  This library is distributed in the hope that
% it will be useful, but WITHOUT ANY WARRANTY, without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU Lesser General Public License for more details, either
% in the "LGPL-2.1.txt" file distributed with this software or at
% web page "http://www.fsf.org/licenses/lgpl.html".
%
%  Uses the xticklabel_rotate.m helper script (see xticklabel_rotate_license.txt)
%
%  .. Some assembly required .. So far I run through the code here by hand
%     instead of running the script autonomously.
%
%  All of this but the plotting handle graphics controls should work with
%  GNU Octave + gnuplot.
%
%  TODO: port to Python + numpy + matplotlib
%  TODO: incorporate removal of /tmp usage from the numbers
%  CAVEATS: many. don't trust these numbers for anything other than a guideline
%
% ###### Prep: shell code ######
% ### done by main install script ###
% #grep '^Disk Usage1:' chroot-build.log | head -n 1 | \
% #   sed -e 's/setup.sh/package/' > disk_usage.log2
% #grep '^Disk Usage2:' chroot-build.log >> disk_usage.log2
% # Disk Usage1: package,Filesystem,1K-blocks,Used,Available,Use%,Mounted_on,date
% # ...
% # col 9 is time
% ### end of done by main install script ###
% #
% ### do by hand:
% cut -f1,4,8 -d, disk_usage.log | sed -e 's/^ //' | tr ',' '\t' | \
%   cut -f3- -d' ' | sed -e 's/+[0-9][0-9]:00$//' > disk_usage.prn
% 
% cut -f1 disk_usage.prn | sed -e 's/^\(package\)$/%\1/' \
%   -e 's/\.sh$//' -e 's/^install_//' > disk_usage.pkg_names
% 
% cut -f2 disk_usage.prn | sed -e 's/^\(Used\)/%\1/' > disk_usage.dat
% cut -f3 disk_usage.prn | sed -e 's/^\(date\)/%\1/' > disk_usage.times
%
% alias xwdtopng='xwd | xwdtopnm | pnmtopng > '
% ###### end of prep work ######

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% matlab code
%%  probably works with minor tweaks in GNU Octave, and with moderate
%%  tweaks in Python's matplotlib.

build_ver = 'r10560';

load disk_usage.dat
u0 = disk_usage(1);
u_after =  disk_usage - u0;
u_before = [NaN; u_after(1:end-1)];
u_pkg = u_after - u_before;


%%% load in package names
fd1 = fopen('disk_usage.pkg_names', 'r');
% header line
buff = fgetl(fd1);

pkg_names(1:length(disk_usage)) = {''};
i = 0;
while (~feof(fd1))
   i = i + 1;
   buff = fgetl(fd1);
   pkg_names(i) = {strrep(buff, '_', ' ')};
end
fclose(fd1);


%%% load in package timestamps
fd1 = fopen('disk_usage.times', 'r');
% header line
buff = fgetl(fd1);

pkg_times(1:length(disk_usage)) = NaN;
i = 0;
while (~feof(fd1))
   i = i + 1;
   buff = fgetl(fd1);
   pkg_times(i) = datenum(buff);
end
fclose(fd1);

t0 = pkg_times(1);
t_after =  pkg_times - t0;
t_before = [NaN t_after(1:end-1)];
t_pkg = t_after - t_before;


% clear out bootstrap
u_pkg(1) = [];
pkg_names(1) = [];
t_pkg(1) = [];


%%% plot timeseries %%%
figure, clf
set(gcf, 'color', 'w')
hB = bar(u_pkg);
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(u_pkg)+1])
ylabel('megabytes used')
title(['OSGeo Live 7.0.' build_ver ' disk usage'], 'fontsize', 12)
set(gca, 'xtick', 1:length(u_pkg))
set(gca, 'xticklabel', pkg_names)
xticklabel_rotate;
%hold on
%plot(1, 40, 'k*')  % pre-setup.sh unknown
% left top(above bot) width height
set(gcf,'paperpos', [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')

print -deps2 'disk_usage_timeseries.eps'
!gv disk_usage_timeseries.eps
!ps2pdf disk_usage_timeseries.eps


%%% timeseries of times
figure, clf
set(gcf, 'color', 'w')
hB = bar(t_pkg * 24*60);  % convert to minutes
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(t_pkg)+1])
ylabel('time to install (minutes)')
title(['OSGeo Live 7.0.' build_ver ' install times'], 'fontsize', 12)
set(gca, 'xtick', 1:length(t_pkg))
set(gca, 'xticklabel', pkg_names)
xticklabel_rotate;

set(gcf,'paperpos', [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')
print -deps2 'time_to_install_timeseries.eps'
!gv time_to_install_timeseries.eps
%!xwdtopng time_to_install_timeseries.png



%%% sorted plots
u_sort = flipud(sortrows([u_pkg (1:length(u_pkg))']));
pkg_names_sorted = pkg_names(u_sort(:,2))';

figure, clf
set(gcf, 'color', 'w')
hB = bar(u_sort(:,1));
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(u_pkg)+1])
ylabel('megabytes used')
title(['OSGeo Live 7.0.' build_ver ' disk usage'], 'fontsize', 12)
set(gca, 'xtick', 1:length(u_sort))
set(gca, 'xticklabel', pkg_names_sorted)
xticklabel_rotate;
%hold on
%plot(1, 40, 'k*')  % setup.sh unknown
set(gcf,'paperpos',  [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')
print -deps2 'disk_usage_sorted.eps'
%!gv disk_usage_sorted.eps
%!ps2pdf disk_usage_sorted.eps
%!xwdtopng disk_usage_sorted.png


%%% sorted timeseries of times
t_sort = flipud(sortrows([t_pkg' (1:length(t_pkg))']));
pkg_names_sorted = pkg_names(t_sort(:,2))';

figure, clf
set(gcf, 'color', 'w')
hB = bar(t_sort(:,1) * 24*60);  % convert to minutes
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(t_sort)+1])
ylabel('time to install (minutes)')
title(['OSGeo Live 7.0.' build_ver ' install times'], 'fontsize', 12)
set(gca, 'xtick', 1:length(t_sort))
set(gca, 'xticklabel', pkg_names_sorted)
xticklabel_rotate;

set(gcf,'paperpos', [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')
print -deps2 'time_to_install_sorted.eps'
!gv time_to_install_sorted.eps
%!xwdtopng time_to_install_sorted.png



%%% summary stats
tab = char(9);
disp(['Median package size:' tab num2str(nanmedian(u_pkg)) ' mb'])
disp(['Mean package size:' tab num2str(nanmean(u_pkg)) ' mb'])
disp(['Max package size:' tab num2str(nanmax(u_pkg)) ' mb'])
disp(['Min package size:' tab num2str(nanmin(u_pkg)) ' mb'])
build_time = (max(pkg_times) - min(pkg_times));
disp(['Package install time:' tab datestr(build_time, 15)])
disp(['Median install time:' tab datestr(median(t_pkg), 13)]) 
disp(['Average install time:' tab datestr(mean(t_pkg), 13)]) 



%% disk space whisker plot
% http://www.mathworks.com/help/toolbox/stats/boxplot.html
figure, clf
set(gcf, 'color', 'w')
boxplot(u_pkg, 'notch', 'on', 'labels', ' ')
grid on
ylabel('megabytes used')

x = (0.10 * (max(xlim) - min(xlim))) + min(xlim);  % 10% from the left
y = min(u_pkg);
text(x, y, ['n = ' num2str(length(u_pkg))])
set(gcf,'paperpos',  [6.5816  7.2245  7.8207 15.2284])

print -depsc2 'disk_usage_whisker.eps'



%% install time whisker plot
% http://www.mathworks.com/help/toolbox/stats/boxplot.html
figure, clf
set(gcf, 'color', 'w')
boxplot(t_pkg * 24*60, 'notch', 'on', 'labels', ' ')
grid on
ylabel('time to install (minutes)')

x = (0.10 * (max(xlim) - min(xlim))) + min(xlim);  % 10% from the left
y = min(t_pkg) * 24*60 + 0.5;
text(x, y, ['n = ' num2str(length(u_pkg))])
set(gcf,'paperpos',  [6.5816  7.2245  7.8207 15.2284])

print -depsc2 'install_time_whisker.eps'
%!xwdtopng install_time_whisker.png

