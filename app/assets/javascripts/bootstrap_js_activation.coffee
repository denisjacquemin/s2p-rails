# $('.nav').click 'a.tab-link' (e) ->
#   e.preventDefault()
#   $(this).tab('show')

$(document).on 'turbolinks:load', ->
  $('body').on 'mouseenter', '[data-toggle="tooltip"]', (event) ->
    event.preventDefault
    $(this).tooltip('show')
