//----------------------------------------------------------------------------
//  Copyright (C) 2012  The IPython Development Team
//
//  Distributed under the terms of the BSD License.  The full license is in
//  the file COPYING, distributed as part of this software.
//----------------------------------------------------------------------------

// convert current notebook to html by calling "ipython nbconvert" and open static html file in new tab
"using strict";
   
nbconvertPrintView = function(){
    var kernel = IPython.notebook.kernel;
    var name = IPython.notebook.notebook_name;
    
    if (IPython.version[0] == "2") {
        var path = IPython.notebook.notebookPath();
        if (path.length > 0) { path = path.concat('/'); }
    } else {
        var path = "";
    }
    
    var command = 'import os; os.system(\"ipython nbconvert --to html ' + name + '\")';
    function callback(out_type, out_data)
        { 
        var url = '/files/' + path + name.split('.ipynb')[0] + '.html';
        var win=window.open(url, '_blank');
        win.focus();
        }
    kernel.execute(command, { shell: { reply : callback } });
};

IPython.toolbar.add_buttons_group([
    {
        id : 'doPrintView',
        label : 'Create static print view',
        icon : 'icon-print',
        callback : nbconvertPrintView
    }
]);


