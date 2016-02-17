//----------------------------------------------------------------------------
//  Copyright (C) 2012  The IPython Development Team
//
//  Distributed under the terms of the BSD License.  The full license is in
//  the file COPYING, distributed as part of this software.
//----------------------------------------------------------------------------

// add button to make codecell read-only
"using strict";

IPython.hotkeys["Alt-R"]   = "Toggle read-only";

var readonly_extension = (function() {

    var readonlyKey = { "Alt-R" : function(){toggleReadOnly();} };
    /**
     * Set codecell to read-only 
     * 
     *  @param {Object} cell current notebook cell
     *  @param {Boolean} val is cell read-only
     */
    setReadOnly = function (cell,val) {
        if (val == undefined) {
            val = false;
        }
        if (cell.metadata.run_control == undefined) {
            cell.metadata.run_control = {};
        }
        cell.metadata.run_control.read_only = val;
        cell.read_only = val;
        var prompt = cell.element.find('div.input_area');
        if (val == true) {
            prompt.css("background-color","#ffffff"); 
        } else {
            prompt.css("background-color","#f5f5f5"); 
        }
        cell.code_mirror.setOption('readOnly',val);
        };

    function toggleReadOnly() {
        var cell = IPython.notebook.get_selected_cell();
        if ((cell instanceof IPython.CodeCell)) {
            if (cell.metadata.run_control == undefined){
                cell.metadata.run_control = {};    }
            setReadOnly(cell,!cell.metadata.run_control.read_only);
        }
    };

    function assign_key(cell) {
        var keys = cell.code_mirror.getOption('extraKeys');
        cell.code_mirror.setOption('extraKeys', collect(keys, readonlyKey ));  
    }

    /**
     * Register new extraKeys to codemirror for newly created cell
     *
     * @param {Object} event
     * @param {Object} nbcell notebook cell
     */
    create_cell = function (event,nbcell,nbindex) {
        var cell = nbcell.cell;
        if ((cell instanceof IPython.CodeCell)) { assign_key(cell); }
    };

    /**
    * Add run control buttons to toolbar and initialize codecells
    * 
    */
    IPython.toolbar.add_buttons_group([
                {
                    id : 'read_only_codecell',
                    label : 'Toggle read-only codecell',
                    icon : 'icon-lock',
                    callback : toggleReadOnly
                }
          ]);
    /* loop through notebook and set read-only cells defined in metadata */
    var cells = IPython.notebook.get_cells();
    for(var i in cells){
        var cell = cells[i];
        if ((cell instanceof IPython.CodeCell)) {
            assign_key(cell);
            if (cell.metadata.run_control != undefined) {
                setReadOnly(cell,cell.metadata.run_control.read_only);
            } else { setReadOnly(cell,false); }
        }
    };

    $([IPython.events]).on('create.Cell',create_cell);    
})();
