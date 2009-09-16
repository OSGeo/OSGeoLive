// Global variables
var dBox_Debug=false;

var dBox_BusyMessage='fetching map...';
var dBox_NotBusyMessage='';

// dBox constructor
function dBox(name, width, height, color, thickness) {
  if(dBox_Debug) alert("Constructing dBox named '"+ name +"'.");

  this.name = name;
  this.width = width;
  this.height = height;
  this.color = color;
  this.thickness = thickness;

  this.box = true;
  this.verbose = false;

  this.layer = null; // layers
  this.anchor = null;  
  this.left = this.right = this.top = this.bottom = null;

  this.cursorsize = 9;
  this.jitter = 10;

  this.x1 = this.y1 = this.x2 = this.y2 = -1;
  this.offsetx = this.offsety = 0;
  this.drag = false;

  this.waiting = false; // are we waiting for a new image?
}

// method prototypes
function dBox_initialize() {
  this.anchor = window.cbeGetElementById(this.name + '_anchor').cbe;
  this.layer = window.cbeGetElementById(this.name).cbe;

  this.layer.resizeTo(this.width, this.height);
  this.layer.moveTo(this.anchor.pageX(),this.anchor.pageY());
  this.layer.show();

  this.offsetx = this.layer.left();
  this.offsety = this.layer.top();

  // create the box layers dynamically
  this.left = document.cbe.createElement("DIV");
  if (this.left) {
    this.left.id = 'left';
    this.layer.appendChild(this.left);
    with(this.left.cbe) {
      background(this.color);
    }
  }
  this.right = document.cbe.createElement("DIV");
  if (this.right) {
    this.right.id = 'right';
    this.layer.appendChild(this.right);
    with(this.right.cbe) {      
      background(this.color);
    }
  } 
  this.top = document.cbe.createElement("DIV");
  if (this.top) {
    this.top.id = 'top';
    this.layer.appendChild(this.top);
    with(this.top.cbe) {      
      background(this.color);
    }
  }
  this.bottom = document.cbe.createElement("DIV");
  if (this.bottom) {
    this.bottom.id = 'bottom';
    this.layer.appendChild(this.bottom);
    with(this.bottom.cbe) {      
      background(this.color);
    }
  }

  // set the event handlers for the layer
  this.layer.addEventListener('mouseDown', mousedown_wrapper);
  this.layer.addEventListener('mouseMove', mousemove_wrapper);
  this.layer.addEventListener('mouseUp', mouseup_wrapper);
  this.layer.addEventListener('mouseEnter', mouseenter_wrapper);
  this.layer.addEventListener('mouseExit', mouseexit_wrapper);
  this.layer.addEventListener('drag', drag_wrapper);

  if(dBox_Debug) cbeMouseMoveStatus();
}

function dBox_snyc() {
  this.layer.moveTo(this.anchor.pageX(),this.anchor.pageY());
  this.offsetx = this.layer.left();
  this.offsety = this.layer.top();
}

function dBox_write(imgsrc) {  
  document.writeln("<div id=\"" + this.name + "_anchor\" style=\"position:relative; visibility:visible; width:" + this.width + "px; height:" + this.height + "px; left:0px; top:0px;\">");
  document.writeln("  <img src=\"" + imgsrc + "\" height=\"" + this.height + "\" width=\"" + this.width + "\">");
  document.writeln("</div>"); 
  document.writeln("<div id=\"" + this.name + "\" style=\"position:absolute; visibility:visible; width:100%; height:100%; clip:rect(100%,100%,100%,100%); background:transparent;\">");
  document.writeln("  <img name=\"" + this.name + "_img\" src=\"" + imgsrc + "\" height=\"" + this.height + "\" width=\"" + this.width + "\">");
  document.writeln("</div>\n");
}

function dBox_boxon() {
  this.box = true;
}

function dBox_boxoff() {
  this.box = false;
  this.x1 = this.x2; 
  this.y1 = this.y2;
  this.paint();

  // user MUST provide this handler
  reset_handler(this.name, Math.min(this.x1, this.x2)-this.offsetx, Math.min(this.y1, this.y2)-this.offsety, Math.max(this.x1, this.x2)-this.offsetx, Math.max(this.y1, this.y2)-this.offsety);
}

function dBox_onload() {
  window.status = dBox_NotBusyMessage;

  this.x1 = this.x2 = (this.width - 1)/2 + this.offsetx; // center of image
  this.y1 = this.y2 = (this.height - 1)/2 + this.offsety;

  reset_handler(this.name, this.x1, this.y1, this.x1, this.y1);

  this.sync();
  this.paint();
  this.waiting = false;
}

function dBox_setimage(imgurl) {
  this.waiting = true;
  window.status = dBox_BusyMessage;

  eval("document.images['" + this.name + "'].onload=onload_wrapper");
  eval("document.images['" + this.name + "'].src=imgurl");

  // netscape 6 doesn't invoke the onload method each time (dammit) so we call it manually here
  if(is.nav6) this.onload();
}

function dBox_mousedown(e) {
  this.drag = true;
  this.x1 = this.x2 = e.pageX;
  this.y1 = this.y2 = e.pageY;
}

function dBox_mousemove(e) {
  if(this.drag) {
    this.x2 = e.pageX;
    this.y2 = e.pageY;
    if(!this.box) {      
      this.x1 = this.x2;
      this.y1 = this.y2;
    }
    this.paint();
  }

  if(!this.waiting && this.verbose && window.mousemove_handler) mousemove_handler(this.name,e.pageX-this.offsetx,e.pageY-this.offsety);
}

function dBox_mouseup(e) {
  this.drag = false;

  if(this.box) {
    this.x2 = e.pageX;
    this.y2 = e.pageY;
  
    if((Math.abs(this.x1-this.x2) <= this.jitter) || (Math.abs(this.y1-this.y2) <= this.jitter)) {
      this.x2 = this.x1;
      this.y2 = this.y1;
    }
  } else {
    this.x2 = this.x1;
    this.y2 = this.y1;
  }

  this.paint();

  // user must provide this handler
  setbox_handler(this.name, Math.min(this.x1, this.x2)-this.offsetx, Math.min(this.y1, this.y2)-this.offsety, Math.max(this.x1, this.x2)-this.offsetx, Math.max(this.y1, this.y2)-this.offsety);
}

function dBox_mouseenter(e) {
  if(this.verbose && window.mouseentered_handler) window.mouseentered_handler(this.name);
}

function dBox_mouseexit(e) {
  if(this.verbose && window.mouseexited_handler) window.mouseexited_handler(this.name);
}

function dBox_paint() {    
  var x, y, w, h;

  if(this.x1==this.x2 && this.y1==this.y2) {
    x = this.x1 - this.offsetx;
    y = this.y1 - this.offsety;

    // resize
    this.left.cbe.resizeTo(1,this.cursorsize);
    this.top.cbe.resizeTo(this.cursorsize,1);

    // move
    this.left.cbe.moveTo(x+this.cursorsize/2, y);
    this.top.cbe.moveTo(x, y+this.cursorsize/2);

    // clip
    this.left.cbe.clip(0, 1, this.cursorsize, 0);
    this.top.cbe.clip(0, this.cursorsize, 1, 0);

    // show/hide
    this.left.cbe.show();
    this.top.cbe.show();
    this.right.cbe.hide(); // don't need this with a crosshair
    this.bottom.cbe.hide();    
  } else {
    w = Math.abs(this.x1-this.x2) + this.thickness;
    h = Math.abs(this.y1-this.y2) + this.thickness;
    x = Math.min(this.x1, this.x2) - this.offsetx; // UL corner of box
    y = Math.min(this.y1, this.y2) - this.offsety;

    // resize
    this.left.cbe.resizeTo(this.thickness,h);
    this.right.cbe.resizeTo(this.thickness,h);
    this.top.cbe.resizeTo(w,this.thickness);
    this.bottom.cbe.resizeTo(w,this.thickness);
   
    // move
    this.left.cbe.moveTo(x, y);  
    this.right.cbe.moveTo(x+w, y);  
    this.top.cbe.moveTo(x, y);  
    this.bottom.cbe.moveTo(x, y+h);  

    // clip
    this.left.cbe.clip(0, this.thickness, h, 0);
    this.bottom.cbe.clip(0, this.thickness, h, 0);
    this.top.cbe.clip(0, w, this.thickness, 0);
    this.bottom.cbe.clip(0, w, this.thickness, 0);

    // show
    this.left.cbe.show();  
    this.right.cbe.show();
    this.top.cbe.show();  
    this.bottom.cbe.show();
  }
}

new dBox(0);

dBox.prototype.initialize = dBox_initialize; // create instance method
dBox.prototype.sync = dBox_snyc;
dBox.prototype.write = dBox_write;
dBox.prototype.boxon = dBox_boxon;
dBox.prototype.boxoff = dBox_boxoff;
dBox.prototype.onload = dBox_onload;
dBox.prototype.setimage = dBox_setimage;
dBox.prototype.mousedown = dBox_mousedown;
dBox.prototype.mousemove = dBox_mousemove;
dBox.prototype.mouseup = dBox_mouseup;
dBox.prototype.mouseenter = dBox_mouseenter;
dBox.prototype.mouseexit = dBox_mouseexit;
dBox.prototype.paint = dBox_paint;

// generic event handlers, these call the interface specific versions
function onload_wrapper() {
  eval(this.name + ".onload()");  
}

function mouseup_wrapper(e) {
  eval(e.cbeCurrentTarget.id + ".mouseup(e)");
}

function mousedown_wrapper(e) {
  eval(e.cbeCurrentTarget.id + ".mousedown(e)");
}

function mousemove_wrapper(e) {
  eval(e.cbeCurrentTarget.id + ".mousemove(e)");
}

function mouseenter_wrapper(e) {
  eval(e.cbeCurrentTarget.id + ".mouseenter(e)");
}

function mouseexit_wrapper(e) {
  eval(e.cbeCurrentTarget.id + ".mouseexit(e)");
}

function drag_wrapper(e) { 
  // We want to override the CBE basic drag event handler. We want to allow dragging since we're
  // building zoomboxes, but don't want anything to *actually* move.
}
