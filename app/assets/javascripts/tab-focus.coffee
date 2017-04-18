if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  url = document.location.toString()
  if url.match('#')
    $('.nav-tabs a[href="#' + url.split('#')[1] + '"]').tab 'show'
  #add a suffix
  # Change hash for page-reload
  $('.nav-tabs a').on 'shown.bs.tab', (e) ->
    window.location.hash = e.target.hash
    window.scrollTo(0, 0)
    return
