# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  # set the focus to the first input in modal
  $('#myModal').on 'shown.bs.modal', () ->
    $('#myModal input[type=text]').filter(':visible:first').focus()
  

  $('#myModal').on 'change', '#all_groups', () ->
    console.log 'changed'
    if $('#all_groups:checked').length > 0
      $('.select_groups').hide()
    else
      $('.select_groups').show()
    return
  $('#myModal').on 'change', '#all_periods', () ->
    console.log 'changed'
    if $('#all_periods:checked').length > 0
      $('.select_periods').hide()
    else
      $('.select_periods').show()
    return
  
  $('#competencies_header').on 'change', '#selected_group', () ->
    Rails.ajax {
      type: "POST"
      url: '/competencies/update_competencies',
      data: 'selected_group_id=' + $('#selected_group').val()
    }
    return

  $('#parameters').on 'change', '.isvalidclass', (e) ->
    Rails.fire($(e.target).closest('form')[0], 'submit')
    return
    
  $('#reports-param-screen').on 'shown.bs.tab', '[data-toggle="tab"]', (e) ->
    console.log 'tab change'
    # e.preventDefault()
    loadurl = $(e.target).data('url')
    if typeof loadurl isnt 'undefined' # do stuff
      Rails.ajax {
        type: "GET"
        url: loadurl
      }
    # $(this).tab('show')
    return

  # specific to compentencies_tab
  if $('#competencies').length
    el = document.getElementById('competencies')
    sortable = Sortable.create(el, {
      dataIdAttr: 'data-id'
      handle: '.handle'
      onSort: (evt) ->
        saveOrder({ orders: sortable.toArray() })
        # itemEl = evt.item
        # console.log 'evt.item: ', evt.item
        # # dragged HTMLElement
        # console.log 'evt.to: ', evt.to
        # # target list
        # console.log 'evt.from: ', evt.from
        # # previous list
        # console.log 'evt.oldIndex: ', evt.oldIndex
        # # element's old index within old parent
        # console.log 'evt.newIndex: ', evt.newIndex
        # # element's new index within new parent
        # console.log 'evt.oldDraggableIndex: ', evt.oldDraggableIndex
        # # element's old index within old parent, only counting draggable elements
        # console.log 'evt.newDraggableIndex: ', evt.newDraggableIndex
        # # element's new index within new parent, only counting draggable elements
        # console.log 'evt.clone: ', evt.clone
        # # the clone element
        # console.log 'evt.pullMode: ', evt.pullMode
        # # when item is in another sortable: `"clone"` if cloning, `true` if moving
        return
    })
    $('#myModal').on 'click', '#select_all, #unselect_all', (e) ->
      e.preventDefault()
      $('#' + $(e.target).data('target') + ' input:checkbox') \
        .prop('checked', e.target.id == 'select_all')
      return
    return
    

saveOrder = (idsOrdered) ->
  console.log idsOrdered
  Rails.ajax {
    type: "POST"
    url: '/competencies/update_orders'
    data: jQuery.param(idsOrdered)
  }

  