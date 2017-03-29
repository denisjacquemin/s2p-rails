# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $("#change_school").click '.this_school', (event) ->
    event.preventDefault()
    $('#selected_school_id').val(event.target.getAttribute('data-school-id'))
    $("#change_school_form").submit()
