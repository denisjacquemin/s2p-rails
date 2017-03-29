$(document).on 'turbolinks:load', ->
  $('.table-filter').on 'keyup', '.filter', (event) ->
    event.preventDefault()
    console.log 'table-filter keyup'

    input = undefined
    filter = undefined
    table = undefined
    tr = undefined
    td = undefined
    i = undefined
    input = event.target
    filter = input.value.toUpperCase()
    table = $(event.target).data('table')
    tr = $(table).find('tr')
    # Loop through all table rows, and hide those who don't match the search query
    i = 0
    while i < tr.length
      j = 0
      tds = $(tr[i]).find('td')
      found = false
      while j < tds.length
        if $(tds[j]).text().toUpperCase().indexOf(filter) > -1
          tr[i].style.display = '' # found
          found = true
          break
        j++
      if !found
        tr[i].style.display = 'none'
      i++

    return
