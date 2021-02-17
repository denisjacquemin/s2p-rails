if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  if $('#evaluations_screen').length
    $('#evaluations_screen').on 'change', '#selected_group', ->
      Rails.ajax {
        type: "POST"
        url: '/evaluations/change_group',
        data: 'group_selected_id=' + $('#selected_group').val()
      }
    $('#evaluations_screen').on 'change', '#selected_period', ->
      Rails.ajax {
        type: "POST"
        url: '/evaluations/change_period',
        data: 'period_selected_id=' + $('#selected_period').val() \
            + '&group_selected_id=' + $('#selected_group').val()
      }
    $('#evaluations_screen').on 'change', '#selected_competency', ->
      Rails.ajax {
        type: "POST"
        url: '/evaluations/change_competency',
        data: 'period_selected_id=' + $('#selected_period').val() \
            + '&group_selected_id=' + $('#selected_group').val() \
            + '&competency_selected_id=' + $('#selected_competency').val()
      }
    $('#evaluations').on 'input', '.quot', (e) ->
      e.preventDefault()
      if !window['saveQuot#' + e.target.id ]
        setTimeout (->
          saveQuot(e)
          return
        ), 2000
        console.log("saveQuot set")
        window['saveQuot#' + e.target.id ] = true
        return
      else
        console.log("saveQuot pending", window['saveQuot#' + e.target.id ])
      return

saveQuot = (e) ->
  console.log("Quot saved")
  Rails.ajax {
      type: "POST"
      url: '/evaluations/save_quot',
      data: 'value=' + e.target.value \
        + '&s-id=' + e.target.getAttribute('data-s-id') \
        + '&e-id=' + e.target.getAttribute('data-e-id') \
        + '&averageable=' + e.target.getAttribute('data-averageable')
  }
  window['saveQuot#' + e.target.id ] = null
  return