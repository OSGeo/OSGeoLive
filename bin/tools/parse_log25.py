#!/usr/bin/python
# -*- coding: utf-8 -*-
#############################################################################
#
# Purpose: The script is used to check the log file
#
#############################################################################
# Copyright (c) 2013 Brian Hamlin - darkblueb
# Copyright (c) 2013-2018 The Open Source Geospatial Foundation.
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
#############################################################################
import sys,  os
import re

def usage():
    """Provide usage instructions"""
    return '''
    parse_log25.py log_path/chroot-build.log log_parse_out.csv dbname 
    
'''
import sys,re

##------------------------------------------------------------------
if len(sys.argv) > 1 and sys.argv[1] is not None:
  tLogFile = sys.argv[1]
else:
  tLogFile = 'osgeolive/chroot-build.log'
##-------
if len(sys.argv) > 2 and sys.argv[2] is not None:
  tLogParseOutF = sys.argv[2]
else:
  tLogParseOutF = '/var/log/osgeolive/log_parse_out.csv'
##--------
if len(sys.argv) > 3 and sys.argv[3] is not None:
  tDBname = sys.argv[3]
else:
  tDBname = 'user'
  #tDBname = os.system('whoami')
##--------

try:
  tLogFH = open( tLogFile, 'r+')
except Exception, E:
  print str(E)
  sys.exit(1)
  
##---------

try:
  tParseOutFH = open( tLogParseOutF, 'w')
except Exception, E:
  print str(E)
  sys.exit(1)

##--------------
##  globals

tScriptBlocksA = []
tPkgs_New = []
tPkgs_Extra = []
tPkgs_Rem = []

tLineBuf = []
tCurBlockName = None

tCnt = 0
bStartBlock = False
bInHdrBlock = False
bInFinishBlk = False
bInPkgsNewBlk  = False
bInPkgsExBlk  = False

for tLine in tLogFH.readlines():
  tCnt += 1
  resM_Hdr = re.search( '^[=]{64}$', tLine )
  resM_BlkTitle = re.search( '^Starting \"([\-a-zA-Z0-9_]+)\.sh', tLine )
  resM_BlkEnd = re.search( '^Finished ',  tLine )
  resM_PkgNew = re.search( '^The following NEW packages will be installed', tLine)
  resM_PkgEx = re.search( '^The following extra packages will be installed', tLine)
  resM_PkgRemove = re.search( '^Removing ([\-a-zA-Z0-9_]+) ...', tLine)
  resM_StartFinalStats = re.search( '^Regenerating manifest',  tLine )

  if resM_BlkEnd is not None and tCurBlockName is not None:
    tCurBlockName = None
    continue

  if resM_PkgRemove is not None  and  tCurBlockName is not None:
    resM_hack = re.search( ' ([\-a-zA-Z0-9_]+) ', tLine)
    tRemElem = resM_hack.group(0)
    tRemElem = tRemElem[1:-1]
    tPkgs_Rem.append( tRemElem )
    #--print '\t'.join( [tCurBlockName,'REMOVE', tRemElem] )
    tParseOutFH.write(  '\t'.join( [tCurBlockName,'REMOVE', tRemElem] )  + '\n' )
    continue

  if resM_BlkTitle is not None:
    tCurBlockName = tLine[10:-9]
    tScriptBlocksA.append( tCurBlockName )
    continue

  if resM_PkgEx is not None:
    ##-- chroot starter breaks the pattern.. so check for that too
    if tCurBlockName is None:
      continue
    bInPkgsExBlk = True
    #print '  EXTRA'
    continue
  else:
    if tLine[0:2] != '  ':
      bInPkgsExBlk = False
      #print '  --'
    elif bInPkgsExBlk == True  and  tLine[0:2] == '  ':
      tSomePkgs = tLine[2:-1].split(' ')
      for n in tSomePkgs:
        tPkgs_Extra.append(n)
        #--print '\t'.join( [tCurBlockName,'EXTRA',n] )
        tParseOutFH.write(  '\t'.join( [tCurBlockName,'EXTRA',n] )  + '\n'  )
        
    
  if resM_PkgNew is not None:
    ##-- chroot starter breaks the pattern.. so check for that too
    if tCurBlockName is None:
      continue
    bInPkgsNewBlk = True
    #print '  NEW'
    continue
  else:
    if tLine[0:2] != '  ':
      bInPkgsNewBlk = False
      #print '  --'
    elif bInPkgsNewBlk == True  and  tLine[0:2] == '  ':
      tSomePkgs = tLine[2:-1].split(' ')
      for n in tSomePkgs:
        tPkgs_New.append(n)
        #--print '\t'.join( [tCurBlockName,'NEW',n] )
        tParseOutFH.write(   '\t'.join( [tCurBlockName,'NEW',n] )  + '\n'  )
    
  if resM_Hdr is not None:
    if bStartBlock == False and bInFinishBlk == False:
      bStartBlock = True
      bInHdrBlock = True
      continue
    elif bStartBlock == True:
      if bInHdrBlock == True:
        bInHdrBlock = False
        continue
      elif bInFinishBlk == False:
        bInFinishBlk = True
        continue
      elif bInFinishBlk == True:
        bInFinishBlk = False

        ##-- clean up a block here
        tCurBlockName = None
        tPkgs_New = []
        tPkgs_Extra = []
        tPkgs_Rem = []
        
        continue
      else:
        #print tLine
        #print 'PROBLEM'  -- should not happen
        tParseOutFH.write( '\t'.join( [tCurBlockName,'PARSE_PROBLEM',n] )  + '\n' )

  if bInFinishBlk == True:
    continue

  if resM_StartFinalStats is not None:
      #t2 = 2
      continue
      

tLogFH.close()
tParseOutFH.close()

##-------
## Part II  Postgres Database
try:
    import psycopg2
    gConn = psycopg2.connect("dbname=%s"%(tDBname))
    gCurs = gConn.cursor()
except Exception, E:
    print str(E)
    sys.exit(0)


try:
  tParseInFH = open( tLogParseOutF, 'r')
except Exception, E:
  print str(E)
  sys.exit(1)

##---------------
tSQL = '''
drop table if exists raw_parse0 cascade;
'''

try:
    gCurs.execute(tSQL)
except Exception, E:
    print str(E)
##---------------

tSQL = '''
create table raw_parse0 (script_name text, action text, pkg_name text);
'''

try:
    gCurs.execute(tSQL)
except Exception, E:
    print str(E)
##---------------

try:
    gCurs.copy_from(   tParseInFH,  'raw_parse0',  sep='\t''' )
except Exception, E:
    print str(E)
##---------------

tParseInFH.close()

gConn.commit()
gConn.close()



# more hacks
#  remove the last two lines from the saved output
#  psql
#  > create database pkgs1;
#  > \c pkgs1
#  pkgs1=# create table raw_parse (script_name text, action text, pkg_name text);
#  pkgs1=# copy raw_parse from '/home/user/out1.csv' with CSV delimiter E'\t';
#  pkgs1=# select pkg_name from raw_parse group by pkg_name having every(action <> 'REMOVE') order by pkg_name;
#
# --

#      try:
#gCurs.execute( tSQL )
#    except Exception, E:
#        print str(E)
#        return False
      
#      gDB.commit()

#print 'DONE'
#print tScriptBlocksA

