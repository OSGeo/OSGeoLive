/* cbe_slide2.js $Revision: 0.11 $
 * CBE v4.19, Cross-Browser DHTML API from Cross-Browser.com
 * Copyright (c) 2002 Michael Foster (mike@cross-browser.com)
 * Distributed under the terms of the GNU LGPL from gnu.org
*/
CrossBrowserElement.prototype.slideCornerBy = function(corner, dX, dY, totalTime, endListener) {
  var targetX, targetY;
  dX = parseInt(dX);
  dY = parseInt(dY);
  switch(corner.toLowerCase()) {
    case 'nw': targetX = this.left() + dX; targetY = this.top() + dY; break;
    case 'sw': targetX = this.left() + dX; targetY = this.top() + this.height() + dY; break;
    case 'ne': targetX = this.left() + this.width() + dX; targetY = this.top() + dY; break;
    case 'se': targetX = this.left() + this.width() + dX; targetY = this.top() + this.height() + dY; break;
    default: alert("CBE: Invalid corner"); return;
  }
  this.slideCornerTo(corner, targetX, targetY, totalTime, endListener)
}
CrossBrowserElement.prototype.slideCornerTo = function(corner, targetX, targetY, totalTime, endListener) {
  if (this.onslidestart) cbeEval(this.onslidestart, this);
  this.xTarget = parseInt(targetX);
  this.yTarget = parseInt(targetY);
  this.slideTime = parseInt(totalTime);
  this.corner = corner.toLowerCase();
  if (endListener) {
    this.autoRemoveListener = true;
    this.addEventListener('slideend', endListener);
  }
  this.stop = false;
  switch(this.corner) {
    case 'nw': this.xA = this.xTarget - this.left(); this.yA = this.yTarget - this.top(); this.xD = this.left(); this.yD = this.top(); break;
    case 'sw': this.xA = this.xTarget - this.left(); this.yA = this.yTarget - (this.top() + this.height()); this.xD = this.left(); this.yD = this.top() + this.height(); break;
    case 'ne': this.xA = this.xTarget - (this.left() + this.width()); this.yA = this.yTarget - this.top(); this.xD = this.left() + this.width(); this.yD = this.top(); break;
    case 'se': this.xA = this.xTarget - (this.left() + this.width()); this.yA = this.yTarget - (this.top() + this.height()); this.xD = this.left() + this.width(); this.yD = this.top() + this.height(); break;
    default: alert("CBE: Invalid corner"); return;
  }
  this.B = Math.PI / ( 2 * this.slideTime );
  var d = new Date( )
  this.C = d.getTime();
  if (!this.moving) this.slideCorner();
}
CrossBrowserElement.prototype.slideCorner = function() {
  var now, seX, seY;
  now = new Date();
  t = now.getTime() - this.C;
  if (this.stop) { this.moving = false; this.stop = false; return; }
  else if (t < this.slideTime) {
    setTimeout("window.cbeAll["+this.index+"].slideCorner()", this.timeout);
    s = Math.sin( this.B * t );
    newX = Math.round(this.xA * s + this.xD);
    newY = Math.round(this.yA * s + this.yD);
    if (this.onslide) cbeEval(this.onslide, this, newX, newY, t);
  }
  else { newX = this.xTarget; newY = this.yTarget; }  
  seX = this.left() + this.width();
  seY = this.top() + this.height();
  switch(this.corner) {
    case 'nw': this.moveTo(newX, newY); this.sizeTo(seX - this.left(), seY - this.top()); break;
    case 'sw': if (this.xTarget != this.left()) { this.left(newX); this.width(seX - this.left()); } this.height(newY - this.top()); break;
    case 'ne': this.width(newX - this.left()); if (this.yTarget != this.top()) { this.top(newY); this.height(seY - this.top()); } break;
    case 'se': this.width(newX - this.left()); this.height(newY - this.top()); break;
    default: this.stop = true;
  }
  this.clip('auto');
  this.moving = true;
  if (t >= this.slideTime) {
    this.moving = false;
    if (this.onslideend) {
      var tmp = this.onslideend;
      if (this.autoRemoveListener) {
        this.autoRemoveListener = false;
        this.removeEventListener('slideend');
      }
      cbeEval(tmp, this);
    }
  }
}
CrossBrowserElement.prototype.parametricEquation = function(exprX, exprY, totalTime, endListener) {
  if (this.onslidestart) cbeEval(this.onslidestart, this);
  this.t = 0;
  this.stop = false;
  this.exprX = exprX;
  this.exprY = exprY;
  if (endListener && window.cbeEventJsLoaded) {
    this.autoRemoveListener = true;
    this.addEventListener('slideend', endListener);
  }
  this.slideTime = parseInt(totalTime);
  var d = new Date( )
  this.C = d.getTime();
  if (!this.moving) this.parametricEquation1();
}
CrossBrowserElement.prototype.parametricEquation1 = function() {
  var now = new Date();
  var et = now.getTime() - this.C;
  this.t += this.tStep;
  t = this.t;
  if (this.stop) { this.moving = false; }
  else if (!this.slideTime || et < this.slideTime) {
    setTimeout("window.cbeAll["+this.index+"].parametricEquation1()", this.timeout);
    var centerX = (this.parentNode.width()/2)-(this.width()/2);
    var centerY = (this.parentNode.height()/2)-(this.height()/2);
    this.xTarget = Math.round((eval(this.exprX) * centerX) + centerX) + this.parentNode.scrollLeft();
    this.yTarget = Math.round((eval(this.exprY) * centerY) + centerY) + this.parentNode.scrollTop();
    if (this.onslide) cbeEval(this.onslide, this, this.xTarget, this.yTarget, et);
    this.moveTo(this.xTarget, this.yTarget);
    this.moving = true;
  }  
  else {
    this.moving = false;
    if (this.onslideend) {
      var tmp = this.onslideend;
      if (this.autoRemoveListener && window.cbeEventJsLoaded) {
        this.autoRemoveListener = false;
        this.removeEventListener('slideend');
      }
      cbeEval(tmp, this);
    }
  }  
}
var cbeSlideRateLinear=0, cbeSlideRateSine=1, cbeSlideRateCosine=2;
CrossBrowserElement.prototype.slideRate = cbeSlideRateSine;
CrossBrowserElement.prototype.tStep = .008;
CrossBrowserElement.prototype.exprX = "";
CrossBrowserElement.prototype.exprY = "";
CrossBrowserElement.prototype.corner = "";     
CrossBrowserElement.prototype.xTarget = 0;     
CrossBrowserElement.prototype.yTarget = 0;     
CrossBrowserElement.prototype.slideTime = 1000;
CrossBrowserElement.prototype.xA = 0;
CrossBrowserElement.prototype.yA = 0;
CrossBrowserElement.prototype.xD = 0;
CrossBrowserElement.prototype.yD = 0;
CrossBrowserElement.prototype.B = 0;
CrossBrowserElement.prototype.C = 0;
CrossBrowserElement.prototype.moving = false;
CrossBrowserElement.prototype.stop = true;
CrossBrowserElement.prototype.timeout = 35;
CrossBrowserElement.prototype.autoRemoveListener = false;
CrossBrowserElement.prototype.onslidestart = null;
CrossBrowserElement.prototype.onslide = null;
CrossBrowserElement.prototype.onslideend = null;
var cbeSlide2JsLoaded = true;
// End cbe_slide2.js
