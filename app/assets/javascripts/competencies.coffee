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
  $('#newCompetencyModal').on 'shown.bs.modal', ()->
    $('#newCompetencyModal input[type=text]').filter(':visible:first').focus()

  $('#reports-param-screen a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    # e.preventDefault()
    loadurl = $(e.target).data('url')
    if typeof loadurl isnt 'undefined' # do stuff 
      Rails.ajax
        type: "GET"
        url: loadurl
    # $(this).tab('show')
    return

  # specific to compentencies_tab
  if $('#competencies').length
    el = document.getElementById('competencies')
    sortable = Sortable.create(el, 
      dataIdAttr: 'data-id'
      handle: '.handle'
      onSort: (evt) ->
        saveOrder({orders: sortable.toArray()})
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
    )
    $('#newCompetencyModal').on 'click', '#select_all, #unselect_all', (e) ->
      e.preventDefault()
      $('#' + $(e.target).data('target') + ' input:checkbox').prop('checked', e.target.id == 'select_all')
      return
    return

saveOrder = (idsOrdered) ->
  console.log idsOrdered
  Rails.ajax
    type: "POST"
    url: '/competencies/update_orders'
    data: jQuery.param(idsOrdered)

  