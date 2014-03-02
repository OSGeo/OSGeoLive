export LD_LIBRARY_PATH=/usr/lib/grass64/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/usr/lib/grass64/etc/python:$PYTHONPATH
export GISBASE=/usr/lib/grass64/
export PATH=/usr/lib/grass64/bin/:$GISBASE/bin:$GISBASE/scripts:$PATH
export GIS_LOCK=$$
export GISRC=/home/$USER/.grassrc6
export GISDBASE=/home/$USER/grassdata
export GRASS_TRANSPARENT=TRUE
export GRASS_TRUECOLOR=TRUE
export GRASS_PNG_COMPRESSION=9
export GRASS_PNG_AUTO_WRITE=TRUE

ipython notebook --port=12345 --no-browser --notebook-dir=/home/user/ossim/workspace/geo-notebook --ip='*'