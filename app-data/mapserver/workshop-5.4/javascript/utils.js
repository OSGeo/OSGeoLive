function decode(string) 
{
  return unescape(string.replace(/\+/g, " "));
}

/*
** This function parses comma-separated name=value argument pairs from
** the query string of the URL. It stores the name=value pairs in 
** properties of an object and returns that object. 
*/
function getargs() {
  var args = new Object();
  var query = location.search.substring(1);   // Get query string.
  var pairs = query.split("&");               // Break at ampersand.
  for(var i = 0; i < pairs.length; i++) {
    var pos = pairs[i].indexOf('=');          // Look for "name=value".
    if (pos == -1) continue;                  // If not found, skip.
    var argname = pairs[i].substring(0,pos);  // Extract the name.
    var value = pairs[i].substring(pos+1);    // Extract the value.
    args[argname] = decode(value);            // Store as a property.
  }
  return args;                                // Return the object.
}

/*
** Various functions to set form elements once they've been displayed.
*/
function set_checkbox(element, value)
{
  if(element.value == value) {
    element.checked = true;
    return true;
  }

  return false;
}

function set_checkbox_multiple(element, values)
{
  element.checked = false;
  for(var j=0; j<values.length; j++) {
    if(element.value == values[j])
      element.checked = true;
  }
}

function set_radio(element, value) 
{ 
  for(var i=0; i<element.length; i++) {
    if(element[i].value == value) {
      element[i].checked = true;
      return true;
    }
  }

  return false;
}

function set_radio_multiple(element, values)
{
  for(var i=0; i<element.length; i++) {    
    for(var j=0; j<values.length; j++) {
      if(element[i].value == values[j])
	element[i].checked = true;
    }
  }
}

function set_select(element, value) 
{
  for(var i=0;i<element.length;i++) {
    if((element.options[i].value == value) || (element.options[i].text == value)) {
      element.options[i].selected = true;
      return true;
    }
  }

  return false;
}

function set_select_multiple(element, values)
{
  for(var k = 0; k < values.length; k++) {
    for(var j = ((element.length)-1); j >=0 ; j--) {	
      if(element.options[j].value == values[k])
	element.options[j].selected = true;
    }
  }
}