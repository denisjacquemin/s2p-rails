# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

add_group = (group) ->
  group_id = $(group).find("input:checkbox").val()
  group_name = $(group).find("label").text()
  $('#in_groups').prepend(build_group_row(group_id, group_name))

add_student = (student) ->
  student_id = $(student).find("input:checkbox").val()
  student_name = $(student).find("label").text()
  $('#in_groups').prepend(build_student_row(student_id, student_name))

remove = (group) ->
  console.log('group to be removed')
  group.remove()

build_student_row = (student_id, student_name) ->
  tr    = $("<tr/>")
  $("<input/>", {
      multiple: 'multiple',
      type: 'hidden',
      value: student_id,
      name: 'student[id][]'
    }).appendTo(tr)
  td1   = $("<td/>").appendTo(tr)
  $("<input/>", {
      type:"checkbox",
      id:"student[" + student_id + "]"
    }).appendTo(td1)
  td2   = $("<td/>").appendTo(tr)
  icon  = $("<i/>", {class: "fa fa-user"}).appendTo(td2)
  label = $("<label/>", {
              for: "student[" + student_id + "]",
              text: ' ' + student_name
            }).appendTo(td2)
  return tr

build_group_row = (group_id, group_name) ->
  tr    = $("<tr/>")
  $("<input/>", {
      multiple: 'multiple',
      type: 'hidden',
      value: group_id,
      name: 'group[id][]'
    }).appendTo(tr)
  td1   = $("<td/>").appendTo(tr)
  $("<input/>", {
      type:"checkbox",
      id:"group[" + group_id + "]"
    }).appendTo(td1)
  td2   = $("<td/>").appendTo(tr)
  icon  = $("<i/>", {class: "fa fa-users"}).appendTo(td2)
  label = $("<label/>", {
              for: "group[" + group_id + "]",
              text: group_name
            }).appendTo(td2)
  return tr

submit_with_status = (status) ->
  $('#message_status').val(status)
  $('.edit_message')[0].submit()


remaining_count = ->
  cs = $(this).val().length
  maxlength = $(this).attr('maxLength')
  $('#' + $(this).data('counter')).text parseInt(maxlength) - cs
  return

init_count = (el) ->
  if el.length # test if el exist http://stackoverflow.com/questions/31044/is-there-an-exists-function-for-jquery
    cs = el.val().length
    maxlength = el.attr('maxLength')
    $('#' + el.data('counter')).text parseInt(maxlength) - cs
  return

sent_by_email_message = () ->
  if $('#message_send_by_email').checked
    return "<li>Sera envoyé par email aux parents</li>"
  else
    return "<li>Ne Sera pas envoyé par email aux parents</li>"

$(document).on 'turbolinks:load', ->
  $('#message_manage_group #add').click ->
    add_group group for group in $("#group_list input:checkbox:checked").closest('tr')
    add_student student for student in $("#student_list input:checkbox:checked").closest('tr')
    $("#group_list input:checkbox:checked").attr('checked', false)
  $('#message_manage_group #remove').click ->
    remove group for group in $("#in_groups input:checkbox:checked").closest('tr')
    remove student for student in $("#in_groups input:checkbox:checked").closest('tr')
    $("#in_group input:checkbox:checked").attr('checked', false)
  $('#mtype').change ->
    console.log $('#mtype').val()
    if $('#mtype').val() == 'message'
      $('.alert_mtype').hide()
      $('.message_mtype').show()
    else
      $('.alert_mtype').show()
      $('.message_mtype').hide()
  $('.submit_with_status').click (e) ->
    console.log "$('.submit_with_status').click"
    if $(e.target).data('before-submit-confirm') # if data-confirm is present don't submit form
      bootbox.confirm
        title: $(e.target).data('title')
        message: $(e.target).data('message')
        buttons:
          confirm:
            label: 'Oui'
            className: 'btn-success'
          cancel:
            label: 'Non'
            className: 'btn-danger'
        callback: (result) ->
          if result
            submit_with_status($(e.target).data('status'))
          return
    else
      submit_with_status($(e.target).data('status'))

  $('[data-toggle="popover"]').popover()

  init_count $('#message_title')
  $('#message_title').bind('propertychange change click keyup input paste', remaining_count)
