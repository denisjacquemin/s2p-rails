var ready;
ready = function() {
  $.each( flashMessages, function(key, value){
    console.log('value: ' + value + ' key: ' + key)
    $.snackbar({content: value, style: key, timeout: 10000});
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);


function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    url = url.toLowerCase(); // This is just to avoid case sensitiveness
    name = name.replace(/[\[\]]/g, "\\$&").toLowerCase();// This is just to avoid case sensitiveness for query parameter name
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}
