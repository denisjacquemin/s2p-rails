if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  $(document).on 'propertychange change click keyup input paste', '.counter-input', (e) ->
    console.log 'event catched'
    console.log e
    InputFieldCounter.update_counter(e.target)
  InputFieldCounter.update_counter('.counter-input')

@InputFieldCounter =
  update_counter: (el) ->
    element = $(el)
    console.log 'element: ' + el
    targetSelector = element.data('target')
    max = element.attr('maxLength')
    console.log 'targetSelector: ' + targetSelector
    if targetSelector != undefined and max != undefined
      $(targetSelector).text parseInt(max) - parseInt(element.val().length)
    return
