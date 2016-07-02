# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

add = (group) ->
  group_id = $(group).find( "input:checkbox").val()
  group_name = $(group).find("label").text()
  build_group_row(group_id, group_name).appendTo($('#in_groups'))

remove = (group) ->
  console.log('group to be removed')
  group.remove()

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
  label = $("<label/>", {
              for: "group[" + group_id + "]",
              text: group_name
            }).appendTo(td2)
  console.log 'adding group' + tr
  return tr

$(document).on 'ready page:load', ->
  $('#message_manage_group #add').click ->
    add group for group in $("#group_list input:checkbox:checked").closest('tr')
    $("#group_list input:checkbox:checked").attr('checked', false)
  $('#message_manage_group #remove').click ->
    remove group for group in $("#in_groups input:checkbox:checked").closest('tr')
    $("#in_group input:checkbox:checked").attr('checked', false)
  $('#mtype').change ->
    console.log $('#mtype').val()
    if $('#mtype').val() == 'message'
      $('.alert_mtype').hide()
      $('.message_mtype').show()
    else
      $('.alert_mtype').show()
      $('.message_mtype').hide()
