if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  if $('#by_student').length
    $('#by_student').on 'change', '#selected_group', ->
      Rails.ajax {
        type: "POST"
        url: '/ratings/change_group',
        data: 'group_selected_id=' + $('#selected_group').val()
      }
  if $('#by_student').length
    $('#by_student').on 'change', '#selected_student', ->
      Rails.ajax {
        type: "POST"
        url: '/ratings/change_student',
        data: 'student_selected_id=' + $('#selected_student').val() \
            + '&group_selected_id=' + $('#selected_group').val()
      }