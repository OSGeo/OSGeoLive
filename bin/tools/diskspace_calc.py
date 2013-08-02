#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2013 Angelos Tzotsos
# Copyright (c) 2013 The Open Source Geospatial Foundation.
# Licensed under the GNU LGPL version >= 2.1.
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

import sys
import re

def usage():
    """Provide usage instructions"""
    return '''
    diskspace_calc.py log_path/disk_usage.log log_path/tmp_usage.log log_path/disk_usage_calc.log log_path/disk_usage_plot.png
'''

if len(sys.argv) != 5:
    print usage()
    sys.exit(1)

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

du_list=[]
name_list=[]

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
	except ValueError:
	    current_df = 0
	    current_df_script = ""
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
    
    try:
	current_df = int(tmp_d[5])
	current_df_script = tmp_d[2]
    except ValueError:
	current_df = 0
	current_df_script = ""
    try:
	current_tmp = int(tmp_t[3])
	current_tmp_script = tmp_t[2]
    except ValueError:
	current_tmp = 0
	current_tmp_script = ""

    if (current_tmp_script != current_df_script):
	calc_log.write("installation script name missmatch\n")
	sys.exit(1)
    
    df_diff = current_df - previous_df
    tmp_diff = current_tmp - previous_tmp
    final_du = df_diff - tmp_diff
    log_msg = current_df_script + " " + str(final_du) + "\n"
    calc_log.write(log_msg)
    du_list.append(final_du)
    name_list.append(current_df_script)

calc_log.close()

try:
    import numpy as np
    import matplotlib.pyplot as plt
        
    N = len(du_list)
    ind = np.arange(N)
    width = 1
    
    fig, ax = plt.subplots(figsize=(30,18))
    rects1 = ax.bar(ind, du_list, width, facecolor='#777777')
    
    ax.set_ylabel('Size in MBs')
    ax.set_title('Disk Usage per installation script')
    ax.set_xticks(ind+0.5)
    ax.set_ylim(-200, 1000)
    ax.xaxis.grid(True, zorder=0)
    ax.yaxis.grid(True, zorder=0)
    
    ax.set_xticklabels( name_list, rotation='vertical' )
    fig.autofmt_xdate()
    plt.savefig(sys.argv[4])
    
except ValueError:
    sys.exit(1)
else:
    sys.exit(1)
