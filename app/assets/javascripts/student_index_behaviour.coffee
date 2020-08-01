if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  if $('.algolia_students').length

    console.log 'ready'

    $('.algolia_students').on 'click', '#toggle_all', (e) ->
      console.log 'click toggle_all'
      toggleAllScb(this.checked)
      setSelectAllStudent(false)
      updateTotalSelected($('.hits .scb:checked').length)


    $('.algolia_students').on 'click', '#results .scb', (e) ->
      console.log 'click #results .scb'
      uncheckToggleAll()
      setSelectAllStudent(false)
      updateTotalSelected($('.hits .scb:checked').length)


    $('.algolia_students').on 'click', '#all_students', (e) ->
      console.log 'click all_students'
      uncheckToggleAll()
      toggleAllScb(false)
      uncheckedFacets()
      setSelectAllStudent(true)
      if (e.target.checked)
        updateTotalSelected($('#TotalStd').text())
      else
        updateTotalSelected(0)


    $('.algolia_students').on 'click', '.ais-RefinementList-checkbox', (e) ->
      console.log 'click ais-RefinementList-checkbox'
      uncheckToggleAll()
      setSelectAllStudent(false)
      toggleAllScb(false)
      updateTotalSelected(0)

# 1 handle toggle check all
uncheckToggleAll = () ->
  console.log 'uncheckToggleAll'
  $('#toggle_all').prop('checked', false)
  return

# 2 handle select row
toggleAllScb = (value) ->
  console.log 'toggleAllScb'
  $('.hits .scb').prop('checked', value)
  if (value)
    $('.hits .div-row').addClass('active')
  else
    $('.hits .div-row').removeClass('active')
  return

# 3 Select all students
setSelectAllStudent = (value) ->
  console.log 'setSelectAllStudent'
  $('#all_students').prop('checked', value)
  return

# 4 update facets
uncheckedFacets = () ->
  console.log 'uncheckedFacets'
  $('.ais-RefinementList-checkbox:checked').click()
  return

updateTotalSelected = (value) ->
  console.log 'updateTotalSelected'
  $('#selected').text(value)
  return