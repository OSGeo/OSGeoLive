#!/usr/bin/python3
# -*- coding: utf-8 -*-
#############################################################################
#
# Purpose: This script is calculating the disk space
#
#############################################################################
# Copyright (c) 2013 Angelos Tzotsos
# Copyright (c) 2013-2020 The Open Source Geospatial Foundation.
# Lpcensed under the GNU LGPL version >= 2.1.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".
#############################################################################

import sys
import re

def usage():
    """Provide usage instructions"""
    return '''
    diskspace_calc.py log_path/disk_usage.log log_path/tmp_usage.log log_path/disk_usage_calc.log log_path/disk_usage_plot.png log_path/installation_time_plot.png [--sort]
'''

if ((len(sys.argv) < 6) or (len(sys.argv)> 7)):
    print(usage())
    sys.exit(1)

sort=False
try:
    if sys.argv[6] == "--sort":
        sort=True
except:
    pass

du_log = open(sys.argv[1], "r")
tmp_log = open(sys.argv[2], "r")
calc_log = open(sys.argv[3], "w")

du_lines = du_log.readlines()
tmp_lines = tmp_log.readlines()

du_log.close()
tmp_log.close()

i=0
previous_df=0
current_df=0
previous_tmp=1
current_tmp=0
current_df_script=""
current_tmp_script=""
previous_date=""
current_date=""

du_list=[]
name_list=[]
dt_list=[]

for dline,tline in zip(du_lines,tmp_lines):
    i=i+1
    if i==1:
        continue
    elif i==2:
        tmp_d=re.split(' |,',dline)
        tmp_t=re.split('\s+|,',tline)
        try:
            current_df = int(tmp_d[5])
            current_df_script = tmp_d[2]
            current_date = tmp_d[9]+"T"+tmp_d[10]
        except ValueError:
            current_df = 0
            current_df_script = ""
            current_date = ""
        try:
            current_tmp = int(tmp_t[3])
            current_tmp_script = tmp_t[2]
        except ValueError:
            current_tmp = 0
            current_tmp_script = ""
        continue
    
    tmp_d=re.split(' |,',dline)
    tmp_t=re.split('\s+|,',tline)
    previous_df = current_df
    previous_tmp = current_tmp
    previous_date = current_date
    
    try:
        current_df = int(tmp_d[5])
        current_df_script = tmp_d[2]
        current_date = tmp_d[9]+"T"+tmp_d[10]
    except ValueError:
        current_df = 0
        current_df_script = ""
        current_date = ""
    try:
        current_tmp = int(tmp_t[3])
        current_tmp_script = tmp_t[2]
    except ValueError:
        current_tmp = 0
        current_tmp_script = ""

    if (current_tmp_script != current_df_script):
        calc_log.write("installation script name missmatch\n")
        sys.exit(1)
    
    #Main disk usage calculation
    df_diff = current_df - previous_df
    tmp_diff = current_tmp - previous_tmp
    final_du = df_diff - tmp_diff
    du_list.append(final_du)
    name_list.append(current_df_script)
    
    #Install time calculation
    from datetime import timedelta,datetime
    previous_date_tmp=previous_date[::-1].replace(':','',1)[::-1]
    #print previous_date_tmp[-6:]
    previous_offset = int(previous_date_tmp[-6:])
    previous_delta = timedelta(hours = previous_offset / 100)
    previous_time = datetime.strptime(previous_date_tmp[:-6], "%Y-%m-%dT%H:%M:%S")
    previous_time -= previous_delta
    
    current_date_tmp=current_date[::-1].replace(':','',1)[::-1]
    current_offset = int(current_date_tmp[-6:])
    current_delta = timedelta(hours = current_offset / 100)
    current_time = datetime.strptime(current_date_tmp[:-6], "%Y-%m-%dT%H:%M:%S")
    current_time -= current_delta
    
    time_diff = current_time-previous_time
    time_diff_minutes = time_diff.seconds/60.0
    dt_list.append(time_diff_minutes)
    
    #write to log
    log_msg = current_df_script + " " + str(final_du) +"MB " + str(round(time_diff_minutes,2)) + "min\n"
    calc_log.write(log_msg)
    
name_list_2 = list(name_list)

if sort:
    du_tuple, name_tuple = zip(*sorted(zip(du_list, name_list),reverse=True))
    du_list=list(du_tuple)
    name_list=list(name_tuple)
    dt_tuple, name_tuple_2 = zip(*sorted(zip(dt_list, name_list_2),reverse=True))
    dt_list=list(dt_tuple)
    name_list_2=list(name_tuple_2)

calc_log.close()


try:
    import numpy as np
    import matplotlib as mpl
    mpl.use('Agg')
    import matplotlib.pyplot as plt
    
    # Disk Usage plot
    N = len(du_list)
    ind = np.arange(N)
    width = 1
    
    fig, ax = plt.subplots(figsize=(30,18))
    rects1 = ax.bar(ind, du_list, width, facecolor='#777777')
    
    def autolabel(rects):
    # attach some text labels
        for ii,rect in enumerate(rects):
            height = rect.get_height()
            if du_list[ii] >= 0:
                plt.text(rect.get_x()+rect.get_width()/2., 1.02*height, '%s'% (str(du_list[ii])),
                        ha='center', va='bottom')
            else:
                plt.text(rect.get_x()+rect.get_width()/2., 5, '%s'% (str(du_list[ii])),
                        ha='center', va='bottom')
    
    autolabel(rects1)
    ax.set_ylabel('Size in MBs')
    ax.set_title('Disk Usage per installation script')
    ax.set_xticks(ind+0.5)
    ax.set_ylim(-200, 1000)
    ax.xaxis.grid(True, zorder=0)
    ax.yaxis.grid(True, zorder=0)
    
    ax.set_xticklabels( name_list, rotation='vertical' )
    fig.autofmt_xdate()
    plt.savefig(sys.argv[4])
    plt.clf()
    
    # Installation Time plot
    N = len(dt_list)
    ind = np.arange(N)
    width = 1
    
    fig2, ax2 = plt.subplots(figsize=(30,18))
    rects2 = ax2.bar(ind, dt_list, width, facecolor='#777777')
    ax2.set_ylabel('Time in minutes')
    ax2.set_title('Installation Time per installation script')
    ax2.set_xticks(ind+0.5)
    #ax2.set_ylim(-200, 1000)
    ax2.xaxis.grid(True, zorder=0)
    ax2.yaxis.grid(True, zorder=0)
    ax2.set_xticklabels( name_list_2, rotation='vertical' )
    fig2.autofmt_xdate()
    plt.savefig(sys.argv[5])
    plt.close()
    
except ValueError:
    sys.exit(1)
else:
    sys.exit(1)
