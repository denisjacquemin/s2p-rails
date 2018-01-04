# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

add_group = (group) ->
  group_id = $(group).find("input:checkbox").val()
  group_name = $(group).find("label").text()
  if (!$('#in_groups').find('input[value="' + group_id + '"]').length)
    $('#in_groups').prepend(build_group_row(group_id, group_name))

add_student = (student) ->
  student_id = $(student).find("input:checkbox").val()
  student_name = $(student).find("label").text()
  if (!$('#in_groups').find('input[value="' + student_id + '"]').length)
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
  td1   = $("<td/>", {class: 'nowrap'}).appendTo(tr)
  $("<input/>", {
      type:"checkbox",
      id:"student[" + student_id + "]"
    }).appendTo(td1)
  td2   = $("<td/>", {class: 'fullwidth'}).appendTo(tr)
  icon  = $("<i/>", {class: "fa fa-user", style: "margin-right: 5px;"}).appendTo(td2)
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
  td1   = $("<td/>", {class: 'nowrap'}).appendTo(tr)
  $("<input/>", {
      type:"checkbox",
      id:"group[" + group_id + "]"
    }).appendTo(td1)
  td2   = $("<td/>", {class: 'fullwidth'}).appendTo(tr)
  icon  = $("<i/>", {class: "fa fa-users", style: "margin-right: 5px;"}).appendTo(td2)
  label = $("<label/>", {
              for: "group[" + group_id + "]",
              text: group_name
            }).appendTo(td2)
  return tr

submit_with_status = (status) ->
  $('#message_status').val(status)
  $('#change_status').val(true)
  $('.edit_message')[0].submit()

sent_by_email_message = () ->
  if $('#message_send_by_email').checked
    return "<li>Sera envoyé par email aux parents</li>"
  else
    return "<li>Ne Sera pas envoyé par email aux parents</li>"


if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

load_billing_students = () ->
  $.ajax
    url: '/messages/billed_students_list'
    data: { id: $('#message_id').val()}
    success: (html) ->
      $('#differentprice').html html
      return

ready = () ->

  $('a.tab-link.save-form').click (e) ->
    e.preventDefault()
    active_tab = $(e.target).attr('href')
    $('<input>').attr({
        type: 'hidden',
        value: active_tab,
        name: 'active_tab'
    }).appendTo($('#new_message'))
    $('#new_message').submit()


  $('#datetimepickerduedate').datetimepicker
    locale: 'fr'
    format: 'DD/MM/YYYY'

  if $('#message_include_payment:checked').length
    $('#payment_form').show()
    $('#payment_doc').hide()

  $('#message_include_payment').change ->
    if $('#message_include_payment:checked').length
      $('#payment_form').show()
      $('#payment_doc').hide()
    else
      $('#payment_form').hide()
      $('#payment_doc').show()

  if $('input[type=radio][name="message[billing_type]"]:checked').val() == '1'
    load_billing_students()

  $('input[type=radio][name="message[billing_type]"]').change ->
    if @value == '0'
      $('#differentprice').addClass('hidden')
      $('#sameprice').removeClass('hidden')
    else if @value == '1'
      $('#sameprice').addClass('hidden')
      $('#differentprice').removeClass('hidden')
      load_billing_students()
    return
  $('#message_manage_group #add').click ->
    add_group group for group in $("#group_list input:checkbox:checked").closest('tr')
    add_student student for student in $("#student_list input:checkbox:checked").closest('tr')
    $("#group_list input:checkbox:checked").attr('checked', false)
    $("#student_list input:checkbox:checked").attr('checked', false)
  $('#message_manage_group #remove').click ->
    remove group for group in $("#in_groups input:checkbox:checked").closest('tr')
    remove student for student in $("#in_groups input:checkbox:checked").closest('tr')
    $("#in_group input:checkbox:checked").attr('checked', false)
  $('#mtype').change ->
    if $('#mtype').val() == 'message'
      $('.alert_mtype').hide()
      $('.save-form').show()
      $('.message_mtype').show()
      $('.send_by_sms_container').hide()
    else
      $('.alert_mtype').show()
      $('.message_mtype').hide()
      $('.save-form').hide()
      $('.send_by_sms_container').show()
  $('.submit_with_status').click (e) ->
    e.preventDefault()
    anchor = $(this).closest('a')
    status = anchor.data('status')
    if anchor.data('before-submit-confirm') # if data-confirm is present don't submit form
      bootbox.confirm
        title: anchor.data('title')
        message: anchor.data('message')
        buttons:
          confirm:
            label: 'Oui'
            className: 'btn-success'
          cancel:
            label: 'Non'
            className: 'btn-danger'
        callback: (result) ->
          if result
            submit_with_status(status)
          return
    else
      submit_with_status(status)


  $('[data-toggle="popover"]').popover()
