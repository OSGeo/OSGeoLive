/* cbe_util.js $Revision: 0.14 $
 * CBE v4.19, Cross-Browser DHTML API from Cross-Browser.com
 * Copyright (c) 2002 Michael Foster (mike@cross-browser.com)
 * Distributed under the terms of the GNU LGPL from gnu.org
*/
// visit function returns: 0 == stop, 1 == continue, 2 == skip subtree
function cbeTraverseTree(order, startNode, visitFunction, data) {
  cbeTraversePreOrder(startNode, 0, 0, visitFunction, data);
}
function cbeTraversePreOrder(node, level, branch, vFn, data) {
  var ret = vFn(node,level,branch,data);
  if (!ret) return 0;
  if (ret == 1 && node.firstChild) {
    var child = node.firstChild;
    while (child) {
      if (!level) ++branch;
      if (!cbeTraversePreOrder(child,level+1,branch,vFn,data)) return 1;
      child = child.nextSibling;
    }
  }
  return 1;
}
var cbeImageCount=0;
var cbeImageObj = new Array();
var cbeImageName = new Array();
function cbeNewImage(imgName, imgUrl, imgWidth, imgHeight) {
  var imgObj;
  if (arguments.length == 4) imgObj = new Image(imgWidth,imgHeight);
  else imgObj = new Image();
  imgObj.src = imgUrl;
  imgObj.id = imgObj.name = imgName;
  cbeImageObj[cbeImageCount] = imgObj;
  cbeImageName[cbeImageCount++] = imgName;
  return imgObj;
}
function cbeSetImage(tagImg, preloadedImg) {
  var t, p;
  if (typeof(tagImg)=='string') t = cbeGetImageByName(tagImg);
  else t = tagImg;
  if (typeof(preloadedImg)=='string') p = cbeGetImageByName(preloadedImg);
  else p = preloadedImg;
  t.src = p.src;
}
function cbeGetImageByName(imgName) {
  var i, j;
  if (document.images[imgName]) return document.images[imgName];
  if (is.nav4) {
    for (i = 0; i < cbeAll.length; i++) {
      if (cbeAll[i].ele.document) {
        for (j = 0; j < cbeAll[i].ele.document.images.length; j++) {
          if (imgName == cbeAll[i].ele.document.images[j].name) return cbeAll[i].ele.document.images[j];
        }
      }
    }
  }
  for (i = 0; i < cbeImageName.length; i++) {
    if (cbeImageName[i] == imgName) return cbeImageObj[i];
  }
  return null;
}
function cbeGetFormByName(frmName) {
  var i, j;
  if (document.forms[frmName]) return document.forms[frmName];
  if (is.nav4) {
    for (i = 0; i < cbeAll.length; i++) {
      if (cbeAll[i].ele.document) {
        for (j = 0; j < cbeAll[i].ele.document.forms.length; j++) {
          if (frmName == cbeAll[i].ele.document.forms[j].name) return cbeAll[i].ele.document.forms[j];
        }
      }
    }
  }
  return null;
}
// cookie implementations based on code from Netscape Javascript Guide
function cbeSetCookie(name, value, expire, path) {
  document.cookie = name + "=" + escape(value) + ((!expire) ? "" : ("; expires=" + expire.toGMTString())) + "; path=/";
}
function cbeGetCookie(name) {
  var value=null, search=name+"=";
  if (document.cookie.length > 0) {
    var offset = document.cookie.indexOf(search);
    if (offset != -1) {
      offset += search.length;
      var end = document.cookie.indexOf(";", offset);
      if (end == -1) end = document.cookie.length;
      value = unescape(document.cookie.substring(offset, end));
    }
  }
  return value;
}
function cbeGetURLArguments() {
  var idx = location.href.indexOf('?');
  var params = new Array();
  if (idx != -1) {
    var pairs = location.href.substring(idx+1, location.href.length).split('&');
    for (var i=0; i<pairs.length; i++) {
      nameVal = pairs[i].split('=');
      params[i] = nameVal[1];
      params[nameVal[0]] = nameVal[1];
    }
  }
  return params;
}
function cbePad(str, finalLen, padChar, left) {
  if (left) { for (var i=str.length; i<finalLen; ++i) str = padChar + str; }
  else { for (var i=str.length; i<finalLen; ++i) str += padChar; }
  return str;
}  
function cbeHexString(n, digits, prefix) {
  var p = '', n = Math.ceil(n);
  if (prefix) p = prefix;
  n = n.toString(16);
  for (var i=0; i < digits - n.length; ++i) {
    p += '0'; 
  }
  return p + n;
}
function cbeRadians(deg) { return deg * (Math.PI / 180); }
function cbeDegrees(rad) { return rad * (180 / Math.PI); }
function cbeAddDragResizeListener(cbe) {
  cbe.addEventListener('dragStart', cbeDragResizeStartListener);
  cbe.addEventListener('drag', cbeDragResizeListener);
}
function cbeRemoveDragResizeListener(cbe) {
  cbe.removeEventListener('dragStart', cbeDragResizeStartListener);
  cbe.removeEventListener('drag', cbeDragResizeListener);
}
function cbeDragResizeStartListener(e) {
  if (e.offsetX > (e.cbeCurrentTarget.width() - 20) && e.offsetY > (e.cbeCurrentTarget.height() - 20)) {
    e.cbeCurrentTarget.isResizing = true;
  }
  else e.cbeCurrentTarget.isResizing = false;
}
function cbeDragResizeListener(e) {
  if (e.cbeCurrentTarget.isResizing) e.cbeCurrentTarget.resizeBy(e.dx, e.dy);
  else e.cbeCurrentTarget.moveBy(e.dx, e.dy);
}
var cbeUtilJsLoaded = true;
// End cbe_util.js
