/*
* ----------------------------------------------------------------------------
* Copyright (c) 2013 - Damián Avila
*
* Distributed under the terms of the Modified BSD License.
*
* A little extension to tweet the current cell from the IPython notebook.
* ----------------------------------------------------------------------------
*/

function zeroMessager() {
  var message = $('<div/>').append(
                  $("<p/></p>").addClass('dialog').html(
                    "Please load your cell with content before tweet it!"
                    )
                );

  IPython.dialog.modal({
    title : "Tweet me!",
    body : message,
    buttons : {
        OK : {class: "btn-danger"}
    }
  });
}

function sucessMessager() {
  var message = $('<div/>').append(
                  $("<p/></p>").addClass('dialog').html(
                    "Your selected cell content is being tweeted it right now..."
                    )
                );

  IPython.dialog.modal({
    title : "Tweet me!",
    body : message,
    buttons : {
        OK : {class: "btn-danger"}
    }
  });
}

function wrongMessager() {
  var message = $('<div/>').append(
                  $("<p/></p>").addClass('dialog').html(
                    "Your content is over 140 characters, please make it short..."
                    )
                );

  IPython.dialog.modal({
    title : "Tweet me!",
    body : message,
    buttons : {
        OK : {class: "btn-danger"}
    }
  });
}

function tweetMe(path) {
  var raw_entry = IPython.notebook.get_selected_cell().get_text();
  var entry = raw_entry.split("\n").join(" ");
  if (entry.length == 0) {
    zeroMessager(); 
  }
  if (entry.length > 0 && entry.length <= 140) {
    IPython.notebook.kernel.execute('%bookmark root');
    IPython.notebook.kernel.execute('%cd ' + path);
    IPython.notebook.kernel.execute('%run tweet_helper.py "' + entry + '"');
    IPython.notebook.kernel.execute('%cd -b root');
    sucessMessager();
  }
  if (entry.length > 140) {
    wrongMessager();
  }
}

define(function() {
  return {
    parameters: function setup(param1) {
      IPython.toolbar.add_buttons_group([
        {
        'label'   : 'Tweet your selected cell content',
        'icon'    : 'icon-twitter',
        'callback': function(){tweetMe(param1)},
        'id'      : 'start_tweet_me'
        },
      ]);
      var document_keydown = function(event) {
        if (event.which == 84 && event.altKey) {
          tweetMe(param1);
          return false;
        };
        return true;
      };
      $(document).keydown(document_keydown);
    }
  }
});
