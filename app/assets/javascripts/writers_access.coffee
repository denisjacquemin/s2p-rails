if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  console.log 'ready'
  if $('#writers_access').length
    $('#writers_access').on 'change', '#selected_user', ->
      Rails.ajax {
        type: "POST"
        url: '/reports/change_user',
        data: 'user_selected_id=' + $('#selected_user').val()
      }
      return
    $('#writers_access').on 'show.bs.collapse', '.group-panel', (e) ->
      Rails.ajax {
        type: "POST"
        url: '/reports/load_competencies_table',
        data: 'user_selected_id=' + $('#selected_user').val() \
            + '&group_selected_id=' + $(e.target).attr('id')
      }