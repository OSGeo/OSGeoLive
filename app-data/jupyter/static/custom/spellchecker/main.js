/*
* ----------------------------------------------------------------------------
* Copyright (c) 2013 - Damián Avila
*
* Distributed under the terms of the Modified BSD License.
*
* A little extension to spell check the selected cell from the IPython notebook.
* ----------------------------------------------------------------------------
*/

function spellCheckerCSS() {
    var link = document.createElement("link");
    link.type = "text/css";
    link.rel = "stylesheet";
    link.href = require.toUrl("./custom/spellchecker/main.css");
    document.getElementsByTagName("head")[0].appendChild(link);
}

function spellChecker(dummy) {
    console.log(dummy);

    spellCheckerCSS();

    var input = IPython.notebook.get_selected_cell().get_text()

    var textarea = $('<textarea/>')
        .attr('rows','15')
        .attr('cols','80')
        .attr('name','source')
        .text(input);

    var dialogform = $('<div/>')
        .append(
            $('<form/>').append(
                $('<fieldset/>').append(
                    $('<label/>')
                    .attr('for','source')
                    .text("Now you can edit the cell content and use " +
                    "the spellchecker support of your browser over it. " +
                    "In Chromium, just focus in the text area and " +
                    "select the text you want to spell check. Then you will " +
                    "be able to use the contextual menu (right click) to get " +
                    "words suggestion and other configuration options (lang). " +
                    "Finally press OK to get the corrected cell content into " +
                    "your selected IPython notebook cell.")
                    )
                    .append($('<br/>'))
                    .append(
                        textarea
                    )
                )
        );

    IPython.dialog.modal({
        title: "Edit and spell check your cell content",
        body: dialogform,
            buttons: {
                "OK": { class : "btn-primary",
                    click: function() {
                       var corr_input = $.trim($(textarea).val());
                       console.log(corr_input);
                       IPython.notebook.get_selected_cell().set_text(corr_input);
                }},
                Cancel: {}
            }
    });

}

define(function() {
  return {
    parameters: function setup(param1) {
      IPython.toolbar.add_buttons_group([
        {
        'label'   : 'Spell check your selected cell content',
        'icon'    : 'icon-check-sign',
        'callback': function(){spellChecker(param1)},
        'id'      : 'start_spellcheck'
        },
      ]);
      var document_keydown = function(event) {
        if (event.which == 83 && event.altKey) {
          spellChecker(param1);
          return false;
        };
        return true;
      };
      $(document).keydown(document_keydown);
    }
  }
});
