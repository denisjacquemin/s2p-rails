# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()
ready = () ->
  if $('#periods_tab').length
    el = document.getElementById('periods_rows')
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
        # return
    )
    saveOrder = (idsOrdered) ->
      console.log idsOrdered
      Rails.ajax
        type: "POST"
        url: '/periods/update_orders'
        data: jQuery.param(idsOrdered)