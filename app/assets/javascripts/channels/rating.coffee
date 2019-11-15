App.rating = App.cable.subscriptions.create "RatingChannel",
  connected: ->
    document.addEventListener 'input', ((event) ->
      if event.target.matches('.rating')
        @save
      return
    ), false

  disconnected: ->
    document.removeEventListener 'input', @update


  received: (data) ->
    console.log(data, data)


  save: (rating) ->
    @perform 'save', rating: rating

$(document).on 'input', '.rating', (e) ->
    rating = {
      current_group_selected_id: $('#selected_group').val()
      current_competency_selected_id: e.target.getAttribute('data-c-id')
      value: e.target.value
      's-id': e.target.getAttribute('data-s-id')
      'sc-id': $('#current_school_id').val()
      'p-id': e.target.getAttribute('data-p-id')
      'ry-id': $('#selected_current_rating_year').val()
      'el_id': e.target.id
    }
    App.rating.save rating
    e.preventDefault()