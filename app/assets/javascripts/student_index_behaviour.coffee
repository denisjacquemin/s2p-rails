if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  if $('.algolia_students').length


    $('.algolia_students').on 'click', '#toggle_all', (e) ->
      toggleAllScb(this.checked)
      setSelectAllStudent(false)
      updateTotalSelected($('.hits .scb:checked').length)


    $('.algolia_students').on 'click', '#results .scb', (e) ->
      uncheckToggleAll()
      setSelectAllStudent(false)
      updateTotalSelected($('.hits .scb:checked').length)


    $('.algolia_students').on 'click', '#all_students', (e) ->      
      if (e.target.checked)
        uncheckToggleAll()
        toggleAllScb(false)
        uncheckedFacets()
        setSelectAllStudent(true)
        updateTotalSelected($('#TotalStd').text())
      else
        updateTotalSelected(0)


    $('.algolia_students').on 'click', '.ais-RefinementList-checkbox', (e) ->
      uncheckToggleAll()
      setSelectAllStudent(false)
      toggleAllScb(false)
      updateTotalSelected(0)

# 1 handle toggle check all
uncheckToggleAll = () ->
  $('#toggle_all').prop('checked', false)
  return

# 2 handle select row
toggleAllScb = (value) ->
  $('.hits .scb').prop('checked', value)
  if (value)
    $('.hits .div-row').addClass('active')
  else
    $('.hits .div-row').removeClass('active')
  return

# 3 Select all students
setSelectAllStudent = (value) ->
  $('#all_students').prop('checked', value)
  return

# 4 update facets
uncheckedFacets = () ->
  $('.ais-RefinementList-checkbox:checked').click()
  return

updateTotalSelected = (value) ->
  $('#selected').text(value)
  return