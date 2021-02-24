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
      parentTR = $(e.target).closest('tr')
      id = parentTR.attr('id')
      if !window['saveQuot#' + id ]
        console.log 'saving: ' + 'saveQuot#' + id
        setTimeout (->
          saveQuot(parentTR)
          return
        ), 2000
        window['saveQuot#' + id ] = true
        return
      return
    $('#evaluations').on 'show.bs.collapse', '#averages', (e) ->
      Rails.ajax {
        type: "POST"
        url: '/evaluations/load_averages',
        data: 'period_selected_id=' + $('#selected_period').val() \
            + '&group_selected_id=' + $('#selected_group').val() \
            + '&competency_selected_id=' + $('#selected_competency').val()
      }
    $('#evaluations').on 'input', '.average-comment', (e) ->
      e.preventDefault()
      el = $(e.target)
      
      if !window['saveAverageComment#' + el.data('s-id') ]
        setTimeout (->
          saveAverageComment(el)
          return
        ), 2000
        window['saveAverageComment#' + el.data('s-id') ] = true
        return
      return
    
    $('#evaluations').on 'hidden.bs.collapse', '#averages', (e) ->
      $('#averages_table .panel-body').empty()

saveAverageComment = (el) ->
  comment = el.val()
  sid = el.data('s-id')

  Rails.ajax {
      type: "POST"
      url: '/evaluations/save_average_comment',
      data: 'period_selected_id=' + $('#selected_period').val() \
          + '&group_selected_id=' + $('#selected_group').val() \
          + '&competency_selected_id=' + $('#selected_competency').val() \
          + '&s-id=' + sid \
          + '&comment=' + comment
  }
  window['saveAverageComment#' + el.data('s-id') ] = null
  return
    
saveQuot = (tr) ->
  
  value = tr.find('.quot-value')
  comment = tr.find('.quot-comment').val()
  averageable = tr.find('.quot-averageable')[0].checked

  Rails.ajax {
      type: "POST"
      url: '/evaluations/save_quot',
      data: 'value=' + value.val() \
        + '&comment=' + comment \
        + '&averageable=' + averageable \
        + '&c-id=' + $('#selected_competency').val() \
        + '&p-id=' + $('#selected_period').val() \
        + '&s-id=' + value.data('s-id') \
        + '&e-id=' + value.data('e-id')
  }
  window['saveQuot#' + tr.attr('id') ] = null
  console.log 'saved: ' + 'saveQuot#' + tr.attr('id')
  return