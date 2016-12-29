$.rails.allowAction = (link) ->
  if link.data('confirmbootbox') == null or link.data('confirmbootbox') == undefined
    return true
  $.rails.showConfirmBootboxDialog link
  false

$.rails.confirmed = (link) ->
  link.data('confirmbootbox', null)
  link.trigger 'click.rails'
  return

#Display the confirmation dialog

$.rails.showConfirmBootboxDialog = (link) ->
  message = link.data('confirmbootbox')
  bootbox.confirm
    title: link.data('title')
    size: "small"
    message: message
    buttons:
      confirm:
        label: 'Oui'
        className: 'btn-success'
      cancel:
        label: 'Non'
        className: 'btn-danger'
    callback: (result) ->
      if result
        console.log 'click on OUI'
        $.rails.confirmed link
        return true
  return true
