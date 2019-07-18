if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  if $('#rating_screen').length
    $('#rating_screen').on 'change', '#selected_group, #selected_competency', ->
      console.log 'select change'
      Rails.ajax
        type: "POST"
        url: 'ratings/students',
        data: 'current_group_selected_id=' + $('#selected_group').val() + '&current_competency_selected_id=' + $('#selected_competency').val()
    $('#ratings_table').on 'input', '.rating', (e) ->
      console.log 'save rating'
      Rails.ajax
        type: "POST"
        url: 'ratings/save',
        data: 'current_group_selected_id=' + $('#selected_group').val() + '&current_competency_selected_id=' + $('#selected_competency').val() + '&value=' + e.target.value + '&s-id=' + e.target.getAttribute('data-s-id') + '&p-id=' + e.target.getAttribute('data-p-id')
    