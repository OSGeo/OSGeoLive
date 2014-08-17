// we want strict javascript that fails
// on ambiguous syntax
"using strict";

// do not use notebook loaded  event as it is re-triggerd on
// revert to checkpoint but this allow extesnsion to be loaded
// late enough to work.
//

$([IPython.events]).on('app_initialized.NotebookApp', function(){


    /**  Use path to js file relative to /static/ dir without leading slash, or
     *  js extension.
     *  Link directly to file is js extension.
     *
     *  first argument of require is a **list** that can contains several modules if needed.
     **/

    // require(['custom/noscroll']);
    // require(['custom/clean_start'])
    // require(['custom/toggle_all_line_number'])
    //require(['custom/publishing/gist_it']);
    require(['custom/publishing/nbconvert_button']);
	require(['custom/publishing/nbconvert_toslide']); 
    require(['custom/publishing/printview_button']);
    require(['custom/usability/hide_input']);
	//require(['custom/usability/codefolding/codefolding.js'])
	//require(['/static/custom/usability/codefolding/codefolding.js'])
 

    /**
     *  Link to entrypoint if extesnsion is a folder.
     *  to be consistent with commonjs module, the entrypoint is main.js
     *  here youcan also trigger a custom function on load that will do extra
     *  action with the module if needed
     **/
     require(['custom/slidemode/main'],function(slidemode){
    //     // do stuff
     })
     require(['custom/livereveal/main'],function(livereveal){
       // livereveal.parameters('theme', 'transition', 'fontsize', static_prefix);
       //   * theme can be: simple, sky, beige, serif, solarized
       //   (you will need aditional css for default, night, moon themes).
       //   * transition can be: linear, zoom, fade, none
       //   (aditional transitions are cube, page, concave, default).
       //   * fontsize is in % units, ie. you can choose 140% or 200%
       livereveal.parameters('simple', 'zoom', '140%');
       console.log('Live reveal extension loaded correctly');
     });
	 
	 require(["nbextensions/toc"], function (toc) {
	 console.log('Table of Contents extension loaded');
	 toc.load_extension();
	 // If you want to load the toc by default, add:
	 // $([IPython.events]).on("notebook_loaded.Notebook", toc.table_of_contents);
	 });
	 
	 require(["nbextensions/gist"], function (gist_extension) {
	     console.log('gist extension loaded');
	     gist_extension.load_extension();
	 });
         require(['custom/spellchecker/main'],function(spellchecker){
       // spellchecker.parameters('just a dummy argument to pass if necessary');
       spellchecker.parameters('dummy');
       console.log('Spellcheck extension loaded correctly');
     });

       // require(['custom/usability/clipboard_dragdrop']);
});
