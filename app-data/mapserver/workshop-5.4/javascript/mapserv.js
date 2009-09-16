// Support functions for advanced web clients using the
// MapServer. Original coding 02-25-2000. - SDL -
//
// Re-write for MapServer 3.6+ and DHTML standardization July 2002. - SDL -

// Global variables
var Interface = 'java';

var DrawOnLayerChange = false;
var DrawOnChange = false;
var QueryOnChange = false;

var MapServer = ""; // these need to be set/initialized by the application
var QueryServer = "";
var PrintServer = "";

var ReferenceXY = new Array(-1, -1);
var ImageBox = new Array(-1,-1,-1,-1);
var ImageXY = new Array(-1, -1);
var MapXY = new Array(-1, -1);

var PixelsPerInch = 72; // these can be overridden, defaults are for meters
var InchesPerMapUnit = 39.3701;

// Class definitions
function Layer(name, longname, group, status, image, metadata) {
  this.name = name; 
  this.longname = longname;
  this.group = group;
  this.status = status;
  this.image = image;
  this.metadata = metadata;
}

new Layer(0);

function Mapserv(name, mapfile, minx, miny, maxx, maxy, width, height)
{
  this.mode = 'map';

  this.name = name; // name of applet or image
  this.url = '';

  this.layers = new Array();
  this.layerlist = '';

  this.mapfile = mapfile;
  this.queryfile = mapfile;

  this.extent = new Array(minx, miny, maxx, maxy);
  
  this.queryextent = new Array(-1, -1, -1, -1);
  this.querypoint = new Array(-1, -1);

  this.width = width;
  this.height = height;

  this.options = '';
  this.queryoptions = '';

  this.referencemap = null;
  
  this.cellsize = AdjustExtent(this.extent, this.width, this.height);
  this.defaultextent = this.extent;

  this.zoomsize = 2;
  this.zoomdir = 0; // pan to start

  this.minscale = -1;
  this.maxscale = -1;

  this.pansize = .8;

  this.box = true; // allow box drawing (or not)
}

function Mapserv_boxon() {
  this.box = true; // dhtml interfaces will use this
  if(Interface == "java") eval("document." + this.name + ".boxon()");
  else eval("window." + this.name + ".boxon()");
}

function Mapserv_boxoff() {
  this.box = false; // dhtml interfaces will use this
  if(Interface == "java") eval("document." + this.name + ".boxoff()");
  else eval("window." + this.name + ".boxoff()");
}

function Mapserv_layersoff() 
{
  for(var i=0; i<this.layers.length; i++)
    this.layers[i].status = false;
}

function Mapserv_getlayerindex(name)
{
  for(var i=0; i<this.layers.length; i++)
    if(this.layers[i].name == name) return(i);

  return(-1);
}

function Mapserv_getlayerstatus(name)
{
  for(var i=0; i<this.layers.length; i++)
    if(this.layers[i].name == name) return(this.layers[i].status);

  return(false);	
}

function Mapserv_setlayerstatus(name, status)
{
  for(var i=0; i<this.layers.length; i++)
    if(this.layers[i].name == name) this.layers[i].status = status;
}

function Mapserv_buildlayers() 
{
  // rebuild layer list
  this.layerlist = '';
  for(var i=0; i<this.layers.length; i++) {
    if(this.layers[i].status) {
      if(this.layerlist == '') 
        this.layerlist = this.layers[i].name;
      else
        this.layerlist += "+" + this.layers[i].name;      
    }
  }
}
  
function Mapserv_togglelayers(element)
{
  if(element.type == 'checkbox') {
    for(var i=0; i<this.layers.length; i++) {
      if(this.layers[i].name == element.value) {
	if(element.checked)
          this.layers[i].status = true;
        else
          this.layers[i].status = false;
	break;
      }
    }
  } else {
    if(element.length == 0) return; // nothing to do

    if(element[0].type == 'checkbox' || element[0].type == 'radio') {
      // check each defined layer against the form element
      for(var i=0; i<this.layers.length; i++) {
        for(var j=0; j<element.length; j++) {
	  if(this.layers[i].name == element[j].value) {
            if(element[j].checked) 
              this.layers[i].status = true;
	    else
              this.layers[i].status = false;
            break;
          }
        }
      }
    }

    if(element.type == 'select-one' || element.type == 'select-multiple') {
      // check each defined layer against the form element
      for(var i=0; i<this.layers.length; i++) {
        for(var j=0; j<element.length; j++) {
	  if(this.layers[i].name == element.options[j].value || this.layers[i].name == element.options[j].name) {
            this.layers[i].status = element.options[j].selected;
            break;
          }
        }
      }
    }

    // need code for a select list
  }

  this.buildlayers(); // re-build the layer list
  
  if(DrawOnLayerChange) {
    var oldmode = this.mode; // just in case we're in a query mode
    this.mode = 'map';
    this.draw();
    this.mode = oldmode;
  }
}

function Mapserv_applybox(minx, miny, maxx, maxy) 
{
  var temp = new Array(4);

  temp[0] = this.extent[0] + this.cellsize*minx;
  temp[1] = this.extent[3] - this.cellsize*maxy;
  temp[2] = this.extent[0] + this.cellsize*maxx;	
  temp[3] = this.extent[3] - this.cellsize*miny;

  this.extent = temp;
 
  this.cellsize = AdjustExtent(this.extent, this.width, this.height);

  if(this.minscale != -1 && this.getscale() < this.minscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.minscale);
  }
  if(this.maxscale != -1 && this.getscale() > this.maxscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.maxscale);
  }
}

function Mapserv_applyzoom(x,y)
{
  var dx, dy;
  var mx, my;
  var x, y;
  var zoom;

  if(this.zoomdir == 1 && this.zoomsize != 0)
    zoom = this.zoomsize;
  else if(this.zoomdir == -1 && this.zoomsize != 0)
    zoom = 1/this.zoomsize;
  else
    zoom = 1;

  dx = this.extent[2] - this.extent[0];
  dy = this.extent[3] - this.extent[1];
  mx = this.extent[0] + this.cellsize*x; // convert *click* to map coordinates
  my = this.extent[3] - this.cellsize*y;

  this.extent[0] = mx - .5*(dx/zoom);
  this.extent[1] = my - .5*(dy/zoom);
  this.extent[2] = mx + .5*(dx/zoom);
  this.extent[3] = my + .5*(dy/zoom);

  this.cellsize = AdjustExtent(this.extent, this.width, this.height);

  if(this.minscale != -1 && this.getscale() < this.minscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.minscale);
  }
  if(this.maxscale != -1 && this.getscale() > this.maxscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.maxscale);
  }
}

function Mapserv_applyreference(x,y)
{
  var mx, my;
  var dx, dy;

  if(!this.referencemap) return;

  dx = this.extent[2] - this.extent[0];
  dy = this.extent[3] - this.extent[1];
  mx = this.referencemap.extent[0] + this.referencemap.cellsize*x;
  my = this.referencemap.extent[3] - this.referencemap.cellsize*y;

  this.extent[0] = mx - .5*dx;
  this.extent[1] = my - .5*dy;
  this.extent[2] = mx + .5*dx;
  this.extent[3] = my + .5*dy;

  this.cellsize = AdjustExtent(this.extent, this.width, this.height);
}

function Mapserv_applyquerybox(minx, miny, maxx, maxy) 
{
  var temp = new Array(4);

  // convert to map coordinates
  // temp[0] = this.extent[0] + this.cellsize*minx;
  // temp[1] = this.extent[3] - this.cellsize*maxy;
  // temp[2] = this.extent[0] + this.cellsize*maxx;	
  // temp[3] = this.extent[3] - this.cellsize*miny;

  // leave in pixel coordinates
  temp[0] = minx;
  temp[1] = miny;
  temp[2] = maxx;
  temp[3] = maxy;

  this.queryextent = temp;
}

function Mapserv_applyquerypoint(x,y)
{
  var dx, dy;

  // convert to map coordinates
  // dx = this.extent[2] - this.extent[0];
  // dy = this.extent[3] - this.extent[1];
  // this.querypoint[0] = this.extent[0] + this.cellsize*x;
  // this.querypoint[1] = this.extent[3] - this.cellsize*y;

  // leave in pixel coordinates
  this.querypoint[0] = x;
  this.querypoint[1] = y;
}

function Mapserv_query()
{  
  // point or box based queries 
  this.url = QueryServer +
            '?mode=' + this.mode +
            '&map=' + this.queryfile +
	    '&imgext=' +  this.extent.join('+') +
            '&imgxy=' +  this.querypoint.join('+') +            
            '&imgbox=' + this.queryextent.join('+') +
            '&imgsize=' + this.width + '+' + this.height +
	    '&layers=' + this.layerlist +
	    this.queryoptions;

  return;
}

function Mapserv_draw()
{
  var oldmode = this.mode;
  this.mode = 'map';

  if(window.predraw) window.predraw();

  if(this.referencemap) {
    this.referencemap.url = MapServer +
                            '?mode=reference' +
                            '&map=' + this.referencemap.mapfile +
                            '&mapext=' + this.extent.join('+') +
                            '&mapsize=' + this.width + '+' + this.height;
    
   if(Interface == 'java') eval("document." + this.referencemap.name + ".setimage(this.referencemap.url)");
   else eval("window." + this.referencemap.name + ".setimage(this.referencemap.url)"); 
  }

  this.url = MapServer +
       	     '?mode=' + this.mode + 
             '&map=' + this.mapfile +
             '&mapext=' + this.extent.join('+') +
             '&mapsize=' + this.width + '+' + this.height +
	     '&layers=' + this.layerlist +
	     this.options;
  
  if(Interface == 'java') eval("document." + this.name + ".setimage(this.url)");
  else eval("window." + this.name + ".setimage(this.url)");

  if(window.postdraw) window.postdraw();

  // this.queryextent = this.extent;
  this.mode = oldmode;
}

function Mapserv_zoomdefault()
{
  this.mode = map;
  this.extent = this.defaultextent;
  this.cellsize = AdjustExtent(this.extent, this.width, this.height);
  this.draw();
}

function Mapserv_setextent(minx, miny, maxx, maxy)
{
  this.extent[0] = minx;
  this.extent[1] = miny;
  this.extent[2] = maxx;
  this.extent[3] = maxy;

  this.cellsize = AdjustExtent(this.extent, this.width, this.height);

  if(this.minscale != -1 && this.getscale() < this.minscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.minscale);    
  }
  if(this.maxscale != -1 && this.getscale() > this.maxscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.maxscale);
  }
}

function Mapserv_setextentfromradius(x, y, radius)
{
  this.extent[0] = x - radius/2.0;
  this.extent[1] = y - radius/2.0;
  this.extent[2] = x + radius/2.0;
  this.extent[3] = y + radius/2.0;

  this.cellsize = AdjustExtent(this.extent, this.width, this.height);

  if(this.minscale != -1 && this.getscale() < this.minscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.minscale);    
  }
  if(this.maxscale != -1 && this.getscale() > this.maxscale) {
    x = (this.extent[2] + this.extent[0])/2;
    y = (this.extent[3] + this.extent[1])/2;
    this.setextentfromscale(x, y, this.maxscale);
  }
}

function Mapserv_zoomradius(x, y, radius)
{
  this.setextentfromradius(x, y, radius);
  this.draw();
}

function Mapserv_getscale()
{
  var gd, md;

  md = (this.width-1)/(PixelsPerInch*InchesPerMapUnit);
  gd = this.extent[2] - this.extent[0];

  return(gd/md);
}

function Mapserv_setextentfromscale(x, y, scale)
{
  if((this.minscale != -1) && (scale < this.minscale))
    scale = this.minscale;

  if((this.maxscale != -1) && (scale > this.maxscale))
    scale = this.maxscale;

  this.cellsize = (scale/PixelsPerInch)/InchesPerMapUnit;

  this.extent[0] = x - this.cellsize*this.width/2.0;
  this.extent[1] = y - this.cellsize*this.height/2.0;
  this.extent[2] = x + this.cellsize*this.width/2.0;
  this.extent[3] = y + this.cellsize*this.height/2.0;

  this.cellsize = AdjustExtent(this.extent, this.width, this.height);
}

function Mapserv_zoomscale(x, y, scale)
{  
  this.setextentfromscale(x, y, scale);
  this.draw();
}

function Mapserv_zoomin(x,y)
{
  this.zoomdir = 1;
  this.applyzoom(x,y);  
  this.draw();
  if(!DrawOnChange) this.boxon();
  this.zoomdir = 0;
}

function Mapserv_zoomout(x,y)
{
  if(!DrawOnChange) this.boxoff();
  this.zoomdir = -1;
  this.applyzoom(x,y);
  this.draw();
  if(!DrawOnChange) this.boxon();
  this.zoomdir = 0;
}

function Mapserv_pan(direction)
{
  if(!DrawOnChange) this.boxoff();
  this.zoomdir = 0;

  if(direction == 'n') {
    x = (this.width-1)/2.0;
    y = 0 - this.height*this.pansize + this.height/2.0;
  } else if(direction == 'nw') {
    x = 0 - this.width*this.pansize + this.width/2.0;
    y = 0 - this.height*this.pansize + this.height/2.0;
  } else if(direction == 'ne') {
    x = (this.width-1) + this.width*this.pansize - this.width/2.0;
    y = 0 - this.height*this.pansize + this.height/2.0;
  } else if(direction == 's') {
    x = (this.width-1)/2.0;
    y = (this.height-1) + this.height*this.pansize - this.height/2.0;
  } else if(direction == 'sw') {
    x = 0 - this.width*this.pansize + this.width/2.0;
    y = (this.height-1) + this.height*this.pansize - this.height/2.0;
  } else if(direction == 'se') {
    x = (this.width-1) + this.width*this.pansize - this.width/2.0;
    y = (this.height-1) + this.height*this.pansize - this.height/2.0;
  } else if(direction == 'e') {
    x = (this.width-1) + this.width*this.pansize - this.width/2.0;
    y = (this.height-1)/2.0;
  } else if(direction == 'w') {
    x = 0 - this.width*this.pansize + this.width/2.0;
    y = (this.height-1)/2.0;
  }
       
  this.applyzoom(x,y);
  this.draw();

  if(!DrawOnChange) this.boxon();
}

new Mapserv(0);

Mapserv.prototype.applybox = Mapserv_applybox; // create instance method
Mapserv.prototype.applyzoom = Mapserv_applyzoom;
Mapserv.prototype.applyreference = Mapserv_applyreference;
Mapserv.prototype.applyquerybox = Mapserv_applyquerybox;
Mapserv.prototype.applyquerypoint = Mapserv_applyquerypoint;
Mapserv.prototype.query = Mapserv_query;
Mapserv.prototype.draw = Mapserv_draw;
Mapserv.prototype.zoomdefault = Mapserv_zoomdefault;
Mapserv.prototype.setextent = Mapserv_setextent;
Mapserv.prototype.setextentfromradius = Mapserv_setextentfromradius;
Mapserv.prototype.zoomradius = Mapserv_zoomradius;
Mapserv.prototype.setextentfromscale = Mapserv_setextentfromscale;
Mapserv.prototype.zoomscale = Mapserv_zoomscale;
Mapserv.prototype.zoomin = Mapserv_zoomin;
Mapserv.prototype.zoomout = Mapserv_zoomout;
Mapserv.prototype.pan = Mapserv_pan;
Mapserv.prototype.buildlayers = Mapserv_buildlayers;
Mapserv.prototype.togglelayers = Mapserv_togglelayers;
Mapserv.prototype.layersoff = Mapserv_layersoff;
Mapserv.prototype.getlayerindex = Mapserv_getlayerindex;
Mapserv.prototype.getlayerstatus = Mapserv_getlayerstatus;
Mapserv.prototype.setlayerstatus = Mapserv_setlayerstatus;
Mapserv.prototype.getscale = Mapserv_getscale;
Mapserv.prototype.boxon = Mapserv_boxon;
Mapserv.prototype.boxoff = Mapserv_boxoff;

// Function definitions
function AdjustExtent(extent, width, height) 
{
  var cellsize = Math.max((extent[2] - extent[0])/(width-1), (extent[3] - extent[1])/(height-1));

  if(cellsize > 0) {
    var ox = Math.max(((width-1) - (extent[2] - extent[0])/cellsize)/2,0);
    var oy = Math.max(((height-1) - (extent[3] - extent[1])/cellsize)/2,0);

    extent[0] = extent[0] - ox*cellsize;
    extent[1] = extent[1] - oy*cellsize;
    extent[2] = extent[2] + ox*cellsize;
    extent[3] = extent[3] + oy*cellsize;
  }	

  return(cellsize);
}

function Extent2Polygon(extent)
{
  var polygon = new Array(10);

  polygon[0] = extent[0];
  polygon[1] = extent[3];
  polygon[2] = extent[2];
  polygon[3] = extent[3];
  polygon[4] = extent[2];
  polygon[5] = extent[1];
  polygon[6] = extent[0];
  polygon[7] = extent[1];
  polygon[8] = extent[0];
  polygon[9] = extent[3];

  return(polygon);
}
