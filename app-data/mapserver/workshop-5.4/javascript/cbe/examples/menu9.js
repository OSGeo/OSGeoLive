// CBE Cascading Drop-down Menu
// copyright (c) 2002 Mike Foster
// get CBE at cross-browser.com
// CBE and cbeDropdownMenu are licensed under the LGPL

// v1.5 30Oct02 - bug fix for when label with no box is the last label
// v1.4 29Oct02 - added support for main labels with no boxes
// v1.3 01Oct02 - utilizes the update to CBE v4.15 which allows object methods to be used as event listeners
// v1.2 27Aug02 - now licensed under LGPL
// v1.1 20Aug02 - added optional parameters to the paint() method, for re-painting on win resize
// v1.0 17Aug02 - initial release

var
  cbeMenu,
  mnuMarker,
  downgrade = true,
  ua = navigator.userAgent.toLowerCase();
  
if (
  ua.indexOf('msie') != -1 && parseInt(navigator.appVersion) >= 4  // IE4 up
  || ua.indexOf('gecko') != -1                                     // Gecko
  || ua.indexOf('konqueror') != -1                                 // Konquerer
  || window.opera                                                  // Opera
) {  
  document.write("<link rel='stylesheet' type='text/css' href='menu9_abs.css'>");
  document.write("<script type='text/javascript' src='../cbe_core.js'></script>");
  document.write("<script type='text/javascript' src='../cbe_event.js'></script>");
  downgrade = false;
}

function windowOnload() {
  mnuMarker = cbeGetElementById('mnuMarker').cbe;
  cbeMenu = new cbeDropdownMenu(
    mnuMarker.pageX(), mnuMarker.pageY(), // coord of first label
    75, 20,                               // label width and height
    120,                                  // box width
    18,                                   // item height
    2,                                    // item left padding
    '#336699',                            // background color
    '#00cccc',                            // text color
    '#00cccc',                            // hover background color
    '#336699'                             // hover text color
  );
  window.cbe.addEventListener('resize', winResizeListener, false);
}

function winResizeListener() {
  cbeMenu.paint(mnuMarker.pageX(), mnuMarker.pageY());
}

// begin class cbeDropdownMenu

function cbeDropdownMenu(mnuX, mnuY, lblW, lblH, boxW, itmH, itmPad, bgColor, txtColor, hvrBColor, hvrTColor) {

  // Properties

  this.mnuX = mnuX;
  this.mnuY = mnuY;
  this.lblW = lblW;
  this.lblH = lblH;
  this.boxW = boxW;
  this.itmH = itmH;
  this.itmPad = itmPad;
  this.bgColor = bgColor;  
  this.txtColor = txtColor; 
  this.hvrBColor = hvrBColor;
  this.hvrTColor = hvrTColor;
  this.lblCount = 0;
  this.lblActive = null;
  
  // Methods

  this.paint = function(mnuX, mnuY) { // this is the only public method
    if (arguments.length > 0) this.mnuX = mnuX;
    if (arguments.length > 1) this.mnuY = mnuY;
    var lbl = null; // of type Element
    var box = null; // of type CBE
    var mX = this.mnuX;
    this.lblCount = 0;
    do {
      ++this.lblCount;
      lbl = cbeGetElementById('label' + this.lblCount)
      if (lbl) {
        with (lbl.cbe) {
          color(this.txtColor);    
          background(this.bgColor);
          zIndex(2002);
          resizeTo(this.lblW, this.lblH);
          moveTo(mX, this.mnuY);
          show();
        }
        if (lbl.cbe.nextSibling && lbl.cbe.nextSibling.id.indexOf('label')==-1) box = lbl.cbe.nextSibling;
        else box = null;
        lbl.cbe.childBox = box;
        lbl.cbe.parentLabel = null;
        if (box) this.paintBox(box, lbl.cbe, mX, this.mnuY + lbl.cbe.height());
        mX += lbl.cbe.width();
      }
    } while(lbl);
    --this.lblCount;
  }

  this.paintBox = function(box, parent, x, y) {
    var mx=0, my=4, itmCount=0;
    box.background(this.bgColor);
    box.width(this.boxW);
    box.moveTo(x, y);
    box.zIndex(2002);
    var itm = box.firstChild;
    while (itm) {
      if (itm.id.indexOf('i') != -1) {
        itm.color(this.txtColor);
        itm.background(this.bgColor);
        itm.resizeTo(this.boxW - 6, this.itmH);
        itm.moveTo(mx + this.itmPad, my);
        itm.show();
        my += itm.height();
        ++itmCount;
      }
      else {
        itm.previousSibling.childBox = itm;
        itm.previousSibling.parentLabel = parent;
        this.paintBox(itm, itm.previousSibling, mx + itm.parentNode.width() - 4, my - itm.previousSibling.height());
      }
      itm = itm.nextSibling;
    }
    box.height(itmCount * this.itmH + 8);
  }

  this.mousemoveListener = function(e) {
    if (
      this.lblActive &&
      (e.cbeTarget != this.lblActive.childBox &&
      e.cbeTarget != this.lblActive &&
      e.cbeTarget.parentNode != this.lblActive.childBox)
    ) {
      if (this.lblActive.childBox) this.lblActive.childBox.hide();
      this.lblActive.color(this.txtColor);
      this.lblActive.background(this.bgColor);
      this.lblActive = this.lblActive.parentLabel;
    }
    else if (e.cbeTarget.childBox || e.cbeTarget.id.indexOf('label')!=-1) {
      e.cbeTarget.color(this.hvrTColor);
      e.cbeTarget.background(this.hvrBColor);
      this.lblActive = e.cbeTarget;
      if (this.lblActive.childBox) this.lblActive.childBox.show();
    }
  }
  
  // Constructor Code

  this.paint();
  document.cbe.addEventListener('mousemove', this.mousemoveListener, false, this);

} // end class cbeDropdownMenu

