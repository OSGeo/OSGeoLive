/* cbe_clip.js $Revision: 0.11 $
 * CBE v4.19, Cross-Browser DHTML API from Cross-Browser.com
 * Copyright (c) 2002 Michael Foster (mike@cross-browser.com)
 * Distributed under the terms of the GNU LGPL from gnu.org
*/
CrossBrowserElement.prototype.autoClip = function(cp, cmd, increment, endListener, dt, dr, db, dl) {
  if (arguments.length <= 4) {
    if (this.clipping) return;
    else this.clipping = true;
    if (increment) this.clipSpeed = increment;
    else if (!this.clipSpeed) this.clipSpeed = 10;
    var unclip = true, w = this.width(), h = this.height(), xcs = Math.abs(this.clipSpeed), ycs = xcs;
    // Get x and y speeds that are proportional to the element's width and height
    if (h > w) ycs *= (h/w);
    else if(w > h) xcs *= (w/h);
    // Setup clip parameters and initial clip position
    if (cmd.toLowerCase() == 'clip') { xcs *= -1; ycs *= -1; unclip = false; this.clip(0, w, h, 0); }
    if (endListener) this.onclipend = endListener;
    switch(cp.toLowerCase()) {
      case 'n': dt = -ycs; dr = 0;  db = 0; dl = 0; if (unclip) {this.clip(h, w, h, 0);} break;
      case 'ne': dt = -ycs; dr = xcs; db = 0; dl = 0; if (unclip) {this.clip(h, 0, h, 0);} break;
      case 'e': dt = 0; dr = xcs; db = 0; dl = 0; if (unclip) {this.clip(0, 0, h, 0);} break;
      case 'se': dt = 0; dr = xcs; db = ycs; dl = 0; if (unclip) {this.clip(0, 0, 0, 0);} break;
      case 's': dt = 0; dr = 0; db = ycs; dl = 0; if (unclip) {this.clip(0, w, 0, 0);} break;
      case 'sw': dt = 0; dr = 0; db = ycs; dl = -xcs; if (unclip) {this.clip(0, w, 0, w);} break;
      case 'w': dt = 0; dr = 0; db = 0; dl = -xcs; if (unclip) {this.clip(0, w, h, w);} break;
      case 'nw': dt = -ycs; dr = 0; db = 0; dl = -xcs; if (unclip) {this.clip(h, w, h, w);} break;
      case 'cen': case 'center': dt = -ycs; dr = xcs; db = ycs; dl = -xcs; if (unclip) {this.clip(h/2, w/2, h/2, w/2);} break;
    }
  }    // end if
  if (this.clipBy(dt, dr, db, dl)) { setTimeout("cbeAll["+this.index+"].autoClip("+null+","+null+","+null+","+null+","+dt+","+dr+","+db+","+dl+")", this.timeout); }
  else {
    this.clipping = false; var listener = this.onclipend;
    if (listener) { this.onclipend = null; cbeEval(listener, this); }
  }
}
CrossBrowserElement.prototype.scrollBy = function(dx, dy) {
  var ct = this.clipTop(), cr = this.clipRight(), cb = this.clipBottom(), cl = this.clipLeft(), w = this.width(), h = this.height();
  // Don't scroll beyond the edge of the element
  if (cl + dx < 0) dx = -cl;
  else if (cr + dx > w) dx = w - cr;
  if (ct + dy < 0) dy = -ct;
  else if (cb + dy > h) dy = h - cb;
  // Clip and move to simulate scrolling
  this.clip(ct + dy, cr + dx, cb + dy, cl + dx);
  this.moveBy(-dx, -dy);
}
CrossBrowserElement.prototype.clipBy = function(dt, dr, db, dl) {
  var ct = this.clipTop();
  var cr = this.clipRight();
  var cb = this.clipBottom();
  var cl = this.clipLeft();
  var w = this.width();
  var h = this.height();
  // Don't clip beyond the existing width and height of the element and don't let top/bottom and left/right coords cross.
  // Top
  if (ct + dt < 0) { ct = 0; dt = 0; }
  else if (ct + dt > cb) { ct = cb; dt = 0; }
  // Right
  if (cr + dr < cl) { cr = cl; dr = 0; }
  else if (cr + dr > w) { cr = w; dr = 0; }
  // Bottom
  if (cb + db < ct) { cb = ct; db = 0; }
  else if (cb + db > h) { cb = h; db = 0; }
  // Left
  if (cl + dl < 0) { cl = 0; dl = 0; }
  else if (cl + dl > cr) { cl = cr; dl = 0; }
  this.clip(ct + dt, cr + dr, cb + db, cl + dl);
  if (dt || dr || db || dl) return true;
  else return false;
}
CrossBrowserElement.prototype.clipArray = function() {
  if (this.ele.style) { var re = /\(|px,?\s?\)?|\s|,|\)/; return this.ele.style.clip.split(re); }
  else return null;
}
CrossBrowserElement.prototype.clipTop = function() {
  var v = 0, a = this.clipArray();
  if (a) v = parseInt(a[1]);
  else if (this.ele.clip) v = this.ele.clip.top;
  return v;
}
CrossBrowserElement.prototype.clipRight = function() {
  var v = this.width(), a = this.clipArray();
  if (a) v = parseInt(a[2]);
  else if (this.ele.clip) v = this.ele.clip.right;
  return v;
}
CrossBrowserElement.prototype.clipBottom = function() {
  var v = this.height(), a = this.clipArray();
  if (a) v = parseInt(a[3]);
  else if (this.ele.clip) v = this.ele.clip.bottom;
  return v;
}
CrossBrowserElement.prototype.clipLeft = function() {
  var v = 0, a = this.clipArray();
  if (a) v = parseInt(a[4]);
  else if (this.ele.clip) v = this.ele.clip.left;
  return v;
}
CrossBrowserElement.prototype.clipWidth = function() {
  var v = this.width(), a = this.clipArray();
  if (a) v = parseInt(a[2]) - parseInt(a[4]);
  else if (this.ele.clip) v = this.ele.clip.width;
  return v;
}
CrossBrowserElement.prototype.clipHeight = function() {
  var v = this.height(), a = this.clipArray();
  if (a) v = parseInt(a[3]) - parseInt(a[1]);
  else if (this.ele.clip) v = this.ele.clip.height;
  return v;
}
CrossBrowserElement.prototype.timeout = 35;
var cbeClipJsLoaded = true;
// End cbe_clip.js
