if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  $(document).on 'propertychange change click keyup input paste', '.counter-input', (e) ->
    InputFieldFormBuilderCounter.update_counter(e.target)
  InputFieldFormBuilderCounter.update_counter('.counter-input')
  $(document).on 'propertychange change click keyup input paste oninput', '.counter-input-wtarget', (e) ->
    InputFieldCounter.update_counter(e.target)
  InputFieldCounter.update_counter('.counter-input-wtarget')

@InputFieldFormBuilderCounter =
  update_counter: (el) ->
    element = $(el)
    targetSelector = element.parent().find('.counter')
    max = element.attr('maxLength')
    if targetSelector != undefined and max != undefined
      $(targetSelector).text parseInt(max) - parseInt(element.val().length)
    return


@InputFieldCounter =
  update_counter: (el) ->
    element = $(el)
    targetSelector = element.data('target')
    max = element.attr('maxLength')
    if targetSelector != undefined and max != undefined
      $(targetSelector).text parseInt(max) - parseInt(element.val().length)
    return