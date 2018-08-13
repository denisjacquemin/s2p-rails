if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  $("#change_school, #schools").click '.this_school', (event) ->
    event.preventDefault()
    $('#selected_school_id').val(event.target.getAttribute('data-school-id'))
    $("#change_school_form").submit()
