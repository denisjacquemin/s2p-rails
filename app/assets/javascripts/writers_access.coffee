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
    $('#writers_access').on 'change', '#wa_selected_group', ->
      Rails.ajax {
        type: "POST"
        url: '/reports/change_wa_group',
        data: 'user_selected_id=' + $('#selected_user').val() \
            + '&group_selected_id=' + $('#wa_selected_group').val()
      }
      return