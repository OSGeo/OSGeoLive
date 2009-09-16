/* cbe.js
   not part of CBE, only for cbe offline files
   to get the latest cbe, visit cross-browser.com
*/                    

window.cbeBasePath = "../";

function topNavBarEx() {
  document.write("<table width='100%' border='0' cellspacing='0' cellpadding='2'><tr>"
  +"<td height='40' class='clsTitle'><img src='../images/cb_x.gif' align='left' width='32' height='32' hspace='1' vspace='1'>CBE 4</td>"
  +"<td height='40' class='clsSubTitle'>Cross-Browser DHTML API&nbsp;</td>"
  +"</tr></table> "
  +"<div id='idMenuBar' class='clsMenuBar'>"
  +"  <table width='100%' border='0' cellspacing='0' cellpadding='4'><tr><td class='clsNav' height='22' align='left'>"
  +"    &nbsp;<a class='clsAMenu' href='../index.html'>Index</a>&nbsp;|&nbsp;"
  +"    <a class='clsAMenu' target='cbeRefWin' href='../docs/cbe_reference.html' onclick='if(window.cbeDebugJsLoaded){cbeRefWindow(\"../docs/\");return false}' title='CBE Reference Window'>Reference</a>&nbsp;|&nbsp;"
  +"    <a class='clsAMenu' href='javascript:if(window.cbeDebugJsLoaded)cbeDebugWindow()' title='CBE Debug Window'>Debug</a>&nbsp;|&nbsp;"
//  +"    <a class='clsAMenu' href='javascript:if(window.cbeDebugJsLoaded)cbeTileWindows()' title='Tile the CBE Debug and Application Windows'>Tile</a>&nbsp;|&nbsp;"
  +"    <a class='clsAMenu' href='http://www.hftonline.com/forum/forumdisplay.php?forumid=16'>Support Forum</a>&nbsp;|&nbsp;"
  +"    <a class='clsAMenu' href='http://cross-browser.com/'>Cross-Browser.com</a>"
  +"  </td></tr></table>"
  +"</div>");
}

function bottomNavBarEx() {
}
