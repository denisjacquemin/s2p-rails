$('a.tab-link').click (e) ->
  e.preventDefault()
  $(this).tab('show')
