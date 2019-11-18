add = (school) ->
  school_id = $(school).find( "input:checkbox").val()
  school_name = $(school).find("label").text()
  build_school_row(school_id, school_name).appendTo($('#in_schools'))

remove = (school) ->
  console.log('school to be removed')
  school.remove()

build_school_row = (school_id, school_name) ->
  tr    = $("<tr/>")
  $("<input/>", {
      multiple: 'multiple',
      type: 'hidden',
      value: school_id,
      name: 'school[id][]'
    }).appendTo(tr)
  td1   = $("<td/>").appendTo(tr)
  $("<input/>", {
      type:"checkbox",
      id:"school[" + school_id + "]"
    }).appendTo(td1)
  td2   = $("<td/>").appendTo(tr)
  label = $("<label/>", {
              for: "school[" + school_id + "]",
              text: school_name
            }).appendTo(td2)
  console.log 'adding school' + tr
  return tr

$(document).on 'turbolinks:load', ->
  if $('.user-edit').length
    $('#user_manage_school #add').click ->
      add school for school in $("#school_list input:checkbox:checked").closest('tr')
      $("#school_list input:checkbox:checked").attr('checked', false)
    $('#user_manage_school #remove').click ->
      remove school for school in $("#in_schools input:checkbox:checked").closest('tr')
      $("#in_schools input:checkbox:checked").attr('checked', false)

    $('#intlphonenumber').intlTelInput(
        separateDialCode: true
        preferredCountries: ["be", "ma", "fr", "lu", "nl"]
        autoPlaceholder: 'off'
    )
    $('#intlphonenumber').intlTelInput('setNumber', $("#user_phone").val())

    $('#intlphonenumber').change () ->
      $("#user_phone").val($(this).intlTelInput("getNumber"))

    $('#groups').on 'click', '#select_all, #unselect_all', (e) ->
      e.preventDefault()
      $('#' + $(e.target).data('target') + ' input:checkbox') \
        .prop('checked', e.target.id == 'select_all')
      return
    return
