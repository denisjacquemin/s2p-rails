if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  current_user_count = parseInt($('#current_user_new_announcement_counter').val())
  current_value = 24
  if current_user_count < current_value
    setTimeout ( ->
      $('#new_announcement_menu_icon').css('color', 'red')
      $('#new_announcements_menu_item').addClass('animated tada')
    ), 2000
    setTimeout ( ->
      $('#new_announcement_menu_icon').css('color', 'white')
      $('#new_announcement_menu_icon, #new_announcements_menu_item').addClass('new-announcements')
    ), 3000


  $('#whatsnew').click (e) ->
    e.preventDefault
    $('#modal').modal('show')
    $('#modal .modal-title').text('Quoi de neuf?')
    $('#modal .modal-body').load('/help/whatsnew')
    if $('#new_announcements_menu_item').hasClass('new-announcements')
      $.ajax {
        type: "POST",
        url: '/users/newannouncementsviewed/' + current_value,
      }
    $('#new_announcement_menu_icon, #new_announcements_menu_item').removeClass('new-announcements')
    false
  false
