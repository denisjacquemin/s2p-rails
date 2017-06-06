if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  $(document).on 'turbolinks:load', ->
    $("#change_school").click '.this_school', (event) ->
      event.preventDefault()
      $('#selected_school_id').val(event.target.getAttribute('data-school-id'))
      $("#change_school_form").submit()
