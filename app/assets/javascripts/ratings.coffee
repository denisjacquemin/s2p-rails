if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  # common between /ratings and /by_student
  if $('#rating_screen, #by_student').length
    $('#ratings_table').on 'input', '.rating', (e) ->
      e.preventDefault()
      console.log 'savingRating: ' + window.savingRating
      if !window['savingRating#' + e.target.id ]
        setTimeout (->
          saveRating(e)
          return
        ), 2000
        console.log("saveRating set")
        window['savingRating#' + e.target.id ] = true
        return
      else
        console.log("saveRating pending")
    $('[data-toggle="popover"]').popover({
      placement: 'top'
      title: 'Commentaire'
      trigger: 'hover'
    })

  if $('#rating_screen, #by_student').length
    $('#rating_screen').on 'change', '#selected_year', ->
      console.log('in change selected_year')
      Rails.ajax {
        type: "POST"
        url: 'ratings/change_year',
        data: 'current_selected_rating_year=' + $('#selected_year').val()
      }

    $('#rating_screen').on 'change', '#selected_group', ->
      console.log('in change selected_group')
      Rails.ajax {
        type: "POST"
        url: 'ratings/change_group',
        data: 'current_group_selected_id=' + $('#selected_group').val() \
          + '&current_selected_rating_year=' + $('#selected_year').val()
      }

    $('#rating_screen').on 'change', '#selected_competency', ->
      console.log('in change selected_competency')
      Rails.ajax {
        type: "POST"
        url: 'ratings/students',
        data: 'current_group_selected_id=' + $('#selected_group').val() \
          + '&current_competency_selected_id=' + $('#selected_competency').val() \
          + '&current_selected_rating_year=' + $('#selected_year').val()
      }
    $('#by_student').on 'submit', '.report_to_pdf_form', (e) ->
      $(e.target .selected_student_id).val($('#selected_student').val())
      $(e.target .selected_group_id).val($('#selected_group').val())
   
saveRating = (e) ->
  console.log("rating saved")
  Rails.ajax {
      type: "POST"
      url: '/ratings/save',
      data: 'current_group_selected_id=' + $('#selected_group').val() \
        + '&current_competency_selected_id=' + e.target.getAttribute('data-c-id') \
        + '&value=' + e.target.value \
        + '&s-id=' + e.target.getAttribute('data-s-id') \
        + '&p-id=' + e.target.getAttribute('data-p-id') \
        + '&ry-id=' + $('#selected_current_rating_year').val() \
        + '&el_id=' + e.target.id
  }
  window['savingRating#' + e.target.id ] = null
  return
