// cbedi1.js

document.write("<link rel='stylesheet' type='text/css' href='cbedi1_abs.css'>");
document.write("<"+"script type='text/javascript' src='../cbe_core.js'></"+"script>");
document.write("<"+"script type='text/javascript' src='../cbe_event.js'></"+"script>");
document.write("<"+"script type='text/javascript' src='../cbe_slide.js'></"+"script>");

var app;

function windowOnload() {
  app = new cbeDI1(
    64,   // header height
    32,   // footer height
    125,  // column 1 width
    10,   // vertical margin
    40,   // horizontal margin
    2,    // inner margin
    700   // menu slide time
  );
  window.cbe.addEventListener("resize", winResizeListener, false);
  window.cbe.addEventListener("scroll", winScrollListener, false);
}

function winResizeListener() {
  app.paint();
}

function winScrollListener() {
  var
    mm = cbeGetElementById('fmenuMarker').cbe,
    mu = cbeGetElementById('floatingMenu').cbe;
  mu.slideTo(mm.offsetLeft(), mm.offsetTop() + document.cbe.scrollTop(), app.tm);
}

function cbeDI1(hdrHeight, ftrHeight, col1Width, vMargin, hMargin, iMargin, slideTime) {
  // Properties
  this.hh = hdrHeight;
  this.fh = ftrHeight;
  this.cw = col1Width;
  this.vm = vMargin;
  this.hm = hMargin;
  this.im = iMargin;
  this.tm = slideTime;
  // Methods
  this.paint = function() {
    var dy, mu, mm,
      hd = cbeGetElementById('header').cbe,
      ft = cbeGetElementById('footer').cbe,
      c1 = cbeGetElementById('col1').cbe,
      c2 = cbeGetElementById('col2').cbe,
      cm = cbeGetElementById('col2Marker').cbe,
      ch = document.cbe.height()-this.hh-this.fh-(2*this.vm)-(2*this.im);
    c1.resizeTo(this.cw, ch);
    c2.resizeTo((document.cbe.width()-(2*this.hm))-c1.width()-this.im, ch);
    dy = cm.offsetTop() + cm.height() - ch;
    if (dy > 0) { ch += dy; }
    hd.resizeTo(document.cbe.width()-(2*this.hm), this.hh);
    hd.moveTo(this.hm, this.vm);
    hd.show();
    c1.resizeTo(this.cw, ch);
    c1.moveTo(this.hm, this.hh+this.vm+this.im);
    c1.show();
    c2.resizeTo(hd.width()-c1.width()-this.im, c1.height());
    c2.moveTo(c1.width()+this.hm+this.im, c1.top());
    c2.show();
    ft.resizeTo(hd.width(), this.fh);
    ft.moveTo(this.hm, c1.top()+c1.height()+this.im);
    ft.show();
    var
      mm = cbeGetElementById('fmenuMarker').cbe,
      mu = cbeGetElementById('floatingMenu').cbe;
    mu.resizeTo(this.cw-(2*mm.offsetLeft()), mu.height());
    mu.moveTo(mm.offsetLeft(), -mu.height());
    mu.show();
    mu.slideTo(mm.offsetLeft(), mm.offsetTop() + document.cbe.scrollTop(), this.tm);
  } // end paint() method

  // Constructor Code
  this.paint();

} // end class cbeDI1
