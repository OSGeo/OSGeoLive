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
% sed -e 's/^Temp Usage: //' tmp_usage.log | cut -f1 | tr ',' '\t' \
%   > tmp_usage.prn
% cat tmp_usage.prn | cut -f2 | sed -e 's/^\(^tmp\)/%\1/' > tmp_usage.dat
% 
% % alias xwdtopng='xwd | xwdtopnm | pnmtopng > '
% ###### end of prep work ######

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% matlab code
%%  probably works with minor tweaks in GNU Octave, and with moderate
%%  tweaks in Python's matplotlib.

%addpath ./bin/tools

build_ver = 'r10592';

load disk_usage.dat
raw_u0 = disk_usage(1);
raw_u_after =  disk_usage - raw_u0;
raw_u_before = [NaN; raw_u_after(1:end-1)];
raw_u_pkg = raw_u_after - raw_u_before;


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

time0 = pkg_times(1);
time_after =  pkg_times - time0;
time_before = [NaN time_after(1:end-1)];
time_pkg = time_after - time_before;


%%% load in /tmp usage
load tmp_usage.dat
tmp_u0 = tmp_usage(1);
tmp_u_after =  tmp_usage - tmp_u0;
tmp_u_before = [NaN; tmp_u_after(1:end-1)];
tmp_u_pkg = tmp_u_after - tmp_u_before;


%%% clear out bootstrap
raw_u_pkg(1) = [];
pkg_names(1) = [];
time_pkg(1) = [];
tmp_u_pkg(1) = [];


%%% remove /tmp space from drive use space to get installed usage
u_pkg = raw_u_pkg - tmp_u_pkg;


%%% plot timeseries %%%
figure, clf
set(gcf, 'color', 'w')
hB = bar(u_pkg);
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(u_pkg)+1])
ylim([-200 max(ylim)])
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
set(gcf, 'Position', [50 500 1750 400])

print -deps2 'disk_usage_timeseries.eps'
!gv disk_usage_timeseries.eps
!ps2pdf disk_usage_timeseries.eps


%%% timeseries of times
figure, clf
set(gcf, 'color', 'w')
hB = bar(time_pkg * 24*60);  % convert to minutes
colormap([.7 .7 .7]) % grey
grid on
xlim([0 length(time_pkg)+1])
ylabel('time to install (minutes)')
title(['OSGeo Live 7.0.' build_ver ' install times'], 'fontsize', 12)
set(gca, 'xtick', 1:length(time_pkg))
set(gca, 'xticklabel', pkg_names)
xticklabel_rotate;
set(gcf,'paperpos', [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')
set(gcf, 'Position', [50 500 1750 400])

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
ylim([-200 max(ylim)])
ylabel('megabytes used')
title(['OSGeo Live 7.0.' build_ver ' disk usage'], 'fontsize', 12)
set(gca, 'xtick', 1:length(u_sort))
set(gca, 'xticklabel', pkg_names_sorted)
xticklabel_rotate;
%hold on
%plot(1, 40, 'k*')  % setup.sh unknown
set(gcf,'paperpos',  [0 6 50 10], 'PaperType', 'A2', ...
        'PaperOrientation', 'landscape')
set(gcf, 'Position', [50 500 1750 400])

print -deps2 'disk_usage_sorted.eps'
%!gv disk_usage_sorted.eps
%!ps2pdf disk_usage_sorted.eps
%!xwdtopng disk_usage_sorted.png


%%% sorted timeseries of times
t_sort = flipud(sortrows([time_pkg' (1:length(time_pkg))']));
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
set(gcf, 'Position', [50 500 1750 400])

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
disp(['Median install time:' tab datestr(median(time_pkg), 13)]) 
disp(['Average install time:' tab datestr(mean(time_pkg), 13)]) 



%% disk space whisker plot
% http://www.mathworks.com/help/toolbox/stats/boxplot.html
figure, clf
set(gcf, 'color', 'w')
boxplot(u_pkg(1:end-1), 'notch', 'on', 'labels', ' ')
grid on
ylabel('megabytes used')
%ylim([-200 max(ylim)])
x = (0.10 * (max(xlim) - min(xlim))) + min(xlim);  % 10% from the left
y = min(u_pkg);
text(x, y, ['n = ' num2str(length(u_pkg))])
set(gcf, 'paperpos', [6.5816  7.2245  7.8207 15.2284], ...
         'Position', [200 500 300 500])

print -depsc2 'disk_usage_whisker.eps'



%% install time whisker plot
% http://www.mathworks.com/help/toolbox/stats/boxplot.html
figure, clf
set(gcf, 'color', 'w')
boxplot(time_pkg * 24*60, 'notch', 'on', 'labels', ' ')
grid on
ylabel('time to install (minutes)')

x = (0.10 * (max(xlim) - min(xlim))) + min(xlim);  % 10% from the left
y = min(time_pkg) * 24*60 + 0.5;
text(x, y, ['n = ' num2str(length(u_pkg))])
set(gcf, 'paperpos', [6.5816  7.2245  7.8207 15.2284], ...
         'Position', [400 500 300 500])

print -depsc2 'install_time_whisker.eps'
%!xwdtopng install_time_whisker.png

