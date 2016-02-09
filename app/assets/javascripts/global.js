var ready;
ready = function() {
  $.each( flashMessages, function(key, value){
    console.log('value: ' + value + ' key: ' + key)
    $.snackbar({content: value, style: key, timeout: 10000});
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);
