/* cbe_debug.js $Revision: 0.11 $
 * CBE v4.19, Cross-Browser DHTML API from Cross-Browser.com
 * Copyright (c) 2002 Michael Foster (mike@cross-browser.com)
 * Distributed under the terms of the GNU LGPL from gnu.org
*/
var cbeIDE=new Object(), cbeDebugObj=new Object(), cbeRefWin=null, cbeRefWinName='cbeRefWin', cbeDebugWin=null, cbeDebugWinName='cbeDebugWindow', cbeDebugSelected=null, cbeMMSL = false;
function cbeMouseMoveStatus() {
  if (cbeMMSL) { document.cbe.removeEventListener('mouseMove', cbeMMStatusListener, false); cbeMMSL = false; }
  else {
    if (window.opera) window.defaultStatus="";
    document.cbe.addEventListener('mouseMove', cbeMMStatusListener, false);
    cbeMMSL = true;
  }
}
function cbeMMStatusListener(e) {
  if (e.cbeTarget) window.status = 'MOUSE:' + '  X: ' + e.pageX + '  Y: ' + e.pageY + '  OBJECT:' + '  ID: ' + e.cbeTarget.id + '  P: ' + e.cbeTarget.parentNode.id + '  L: ' + e.cbeTarget.left() + '  T: ' + e.cbeTarget.top() + '  X: ' + e.cbeTarget.pageX() + '  Y: ' + e.cbeTarget.pageY() + '  Z: ' + e.cbeTarget.zIndex() + '  W: ' + e.cbeTarget.width() + '  H: ' + e.cbeTarget.height() + '  B: ' + e.cbeTarget.background();
}
function cbeMUListener(e) { cbeDebugSetSelected(e.cbeTarget.id); }
function cbeDebugSetSelected(id) {
  if (cbeDebugWin) if (cbeDebugWin.closed) cbeDebugWindow();
  if (id == window.cbeWindowId) cbeDebugSelected = window.cbe;
  else if (id == window.cbeDocumentId) cbeDebugSelected = document.cbe;
  else cbeDebugSelected = cbeGetElementById(id).cbe;
  if (!cbeDebugSelected) cbeDebugSelected = window.cbe;
}
function cbeDebugWindow(sBaseUrl) {
  if (cbeDebugWin) {
    cbeDebugWin.close(); cbeDebugWin = null; document.cbe.removeEventListener('mouseUp', cbeMUListener, false);
    return;
  }
  cbeIDEInit();
  if (!sBaseUrl) { sBaseUrl = window.cbeBasePath ? cbeBasePath : ""; }
  cbeDebugSetSelected(window.cbeWindowId);
  var features = "width="+cbeIDE.dw+",height="+cbeIDE.dh+",scrollbars=1,resizable=1";
  if (document.layers) features += ",screenx="+cbeIDE.dx+",screeny="+cbeIDE.dy;
  else features += ",left="+cbeIDE.dx+",top="+cbeIDE.dy;
  window.cbeDebugWin = window.open(sBaseUrl + "cbe_debug.html", cbeDebugWinName, features);
  cbeDebugWin.resizeTo(cbeIDE.dw, cbeIDE.dh);
  cbeDebugWin.moveTo(cbeIDE.dx,cbeIDE.dy);
  document.cbe.addEventListener('mouseUp', cbeMUListener, false);
  cbeDebugObj.cmdLine = "";
  cbeDebugUpdate();
}
function cbeRefWindow(sBaseUrl) {
  if (window.cbeRefWin) { cbeRefWin.close(); cbeRefWin = null; return; }
  cbeIDEInit();
  if (!sBaseUrl) { sBaseUrl = window.cbeBasePath ? cbeBasePath : ""; }
  var features = "width="+cbeIDE.rw+",height="+cbeIDE.rh+",scrollbars=1,resizable=1";
  if (document.layers) features += ",screenx="+cbeIDE.rx+",screeny="+cbeIDE.ry;
  else features += ",left="+cbeIDE.rx+",top="+cbeIDE.ry;
  window.cbeRefWin = window.open(sBaseUrl + "cbe_reference.html", cbeRefWinName, features);
  cbeRefWin.resizeTo(cbeIDE.rw, cbeIDE.rh);
  cbeRefWin.moveTo(cbeIDE.rx, cbeIDE.ry);
}
function cbeTileWindows() { cbeIDEInit(); cbeDebugWindow(); if (!cbeDebugWin) {cbeDebugWindow();} window.resizeTo(cbeIDE.aw, cbeIDE.ah); window.moveTo(cbeIDE.ax, cbeIDE.ay); }
function cbeIDEInit() {
  cbeIDE.dx = 0; cbeIDE.dy = 0; cbeIDE.dw = 200; cbeIDE.dh = screen.availHeight - 10; // Debug Window
  cbeIDE.rh = Math.round(screen.availHeight / 2); cbeIDE.rw = screen.availWidth - cbeIDE.dw; cbeIDE.rx = 0; cbeIDE.ry = cbeIDE.rh - 10; // Reference Window
  cbeIDE.ax = cbeIDE.dw; cbeIDE.ay = 0; cbeIDE.aw = screen.availWidth - cbeIDE.dw - 10; cbeIDE.ah = screen.availHeight - 10; // Application Window
}
function cbeDebugUpdate() {
  if (cbeDebugWin) { if (!cbeDebugWin.closed) setTimeout("cbeDebugUpdate()", 750); }
  if (cbeDebugObj.cmdLine.length) { var tmp = cbeDebugObj.cmdLine; cbeDebugObj.cmdLine = ""; eval(tmp); }
  cbeDebugObj.id = cbeDebugSelected.id;
  cbeDebugObj.left = cbeDebugSelected.left();
  cbeDebugObj.top = cbeDebugSelected.top();
  cbeDebugObj.zIndex = cbeDebugSelected.zIndex();
  cbeDebugObj.pageX = cbeDebugSelected.pageX();
  cbeDebugObj.pageY = cbeDebugSelected.pageY();
  cbeDebugObj.offsetLeft = cbeDebugSelected.offsetLeft();
  cbeDebugObj.offsetTop = cbeDebugSelected.offsetTop();
  cbeDebugObj.scrollLeft = cbeDebugSelected.scrollLeft();
  cbeDebugObj.scrollTop = cbeDebugSelected.scrollTop();
  cbeDebugObj.width = cbeDebugSelected.width();
  cbeDebugObj.height = cbeDebugSelected.height();
  cbeDebugObj.visibility = cbeDebugSelected.visibility();
  cbeDebugObj.color = cbeDebugSelected.color();
  cbeDebugObj.background = cbeDebugSelected.background();
  cbeDebugObj.childNodes = cbeDebugSelected.childNodes;
  cbeDebugObj.firstChild = cbeDebugSelected.firstChild ? cbeDebugSelected.firstChild.id : null;
  cbeDebugObj.lastChild = cbeDebugSelected.lastChild ? cbeDebugSelected.lastChild.id : null;
  cbeDebugObj.parentNode = cbeDebugSelected.parentNode ? cbeDebugSelected.parentNode.id : null;
  cbeDebugObj.previousSibling = cbeDebugSelected.previousSibling ? cbeDebugSelected.previousSibling.id : null;
  cbeDebugObj.nextSibling = cbeDebugSelected.nextSibling ? cbeDebugSelected.nextSibling.id : null;
}
function cbeDebugMsg(sMsg) { if (cbeDebugWin) { if (!cbeDebugWin.closed) { cbeDebugWin.setMsg(sMsg); } } }
function cbeShowProps(obj, obj_name, showValues) {
  var i = null, win = null, result = "", objType = "", objValue = "&nbsp;";
  if (!obj) { alert("obj is null"); return; }
  if (!obj_name) { if (obj.nodeName) obj_name = obj.nodeName; else obj_name = "this"; }
  result = "<head><title>Property Viewer</title>\n" +"</head>\n" +"<body bgcolor='#bbbbbb'>\n" +"<form>\n" +"<input type='button' value='Close' onclick='window.close()'>\n" +"</form>\n" +"<h3>" + obj_name + " Properties:</h3>\n" +"<table border='1' bgcolor='#eeeeee'><tr><th>Property</th><th>Type</th><th>Value</th></tr>\n";
  for (i in obj) {
    objType = typeof(obj[i]);
    if (showValues) {
      if (objType.indexOf('string') != -1 && obj[i] == "") objValue = "&nbsp;";
      else if (objType.indexOf('object') != -1) objValue = "...";
      else if (objType.indexOf('function') != -1) objValue = "...";
      else if (i.indexOf('HTML') != -1) objValue = "...";
      else if (i.indexOf('erText') != -1) objValue = "...";
      else if (i.indexOf('domain') != -1) objValue = "...";
      else {objValue = obj[i];}
    }
    result += "<tr><td>" + obj_name + "." + i + "</td><td>" + objType + "</td><td>" + objValue + "</td></tr>\n";
  }
  result += "</table><br>" +"<form>\n" +"<input type='button' value='Close' onclick='window.close()'>\n" +"</form>\n" +"</body></html>";
  var features = "width=600,height=440,scrollbars=1,resizable=1";
  if (document.layers) features += ",screenX=0,screenY=0";
  else features += ",left=0,top=0";
  win = window.open("", "PropertyViewerWindow", features); win.document.write(result); win.document.close();
  return false;
}
function cbeShowParentChain(child) {
  var s = "", parent = child;
  while (parent) {
    s += "id: "
      + (parent.id || "null")
      + "   tag: " + (parent.tagName || parent.nodeName || "null")
      + "\n";
    parent = cbeGetParentElement(parent);
  }
  alert(s);
}
var cbeDebugJsLoaded = true;
// End cbe_debug.js
