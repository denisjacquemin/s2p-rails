if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  $('#whatsnew').click (e) ->
    e.preventDefault
    $('#modal').modal('show')
    $('.modal-title').text('Quoi de neuf?')
    $('.modal-body').load('/help/whatsnew')
    false
  false
