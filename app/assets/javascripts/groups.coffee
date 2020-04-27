# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

add = (student) ->
  student_id = $(student).find( "input:checkbox").val()
  student_fullname = ""
  $(student).find('.n').map (i, el) ->
    student_fullname += $(el).text() + ' '
  classroom = $(student).find(".classroom").text()
  $('#in_group').prepend(build_student_row(student_id, student_fullname, classroom))

remove = (student) ->
  console.log('student to be removed')
  student.remove()

build_student_row = (student_id, student_fullname, classroom) ->
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
  label = $("<label/>", {
              for: "student[" + student_id + "]",
              text: student_fullname
            }).appendTo(td2)
  td3   = $("<td/>").appendTo(tr)
  classroom = $("<label/>", {
              for: "student[" + student_id + "]",
              text: classroom
            }).appendTo(td3)
  return tr

$(document).on 'turbolinks:load', ->
  $('.buttons #add').click ->
    add student for student in $("#student_list input:checkbox:checked").closest('tr')
    $("#student_list input:checkbox:checked").attr('checked', false)
  $('.buttons #remove').click ->
    remove student for student in $("#in_group input:checkbox:checked").closest('tr')
    $("#in_group input:checkbox:checked").attr('checked', false)
