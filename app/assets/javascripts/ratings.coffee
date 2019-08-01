if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  if $('#rating_screen').length
    $('#rating_screen').on 'change', '#selected_group, #selected_competency', ->
      Rails.ajax
        type: "POST"
        url: 'ratings/students',
        data: 'current_group_selected_id=' + $('#selected_group').val() + '&current_competency_selected_id=' + $('#selected_competency').val()
    $('#ratings_table').on 'input', '.rating', (e) ->
      e.preventDefault()
      Rails.ajax
        type: "POST"
        url: 'ratings/save',
        data: 'current_group_selected_id=' + $('#selected_group').val() + '&current_competency_selected_id=' + $('#selected_competency').val() + '&value=' + e.target.value + '&s-id=' + e.target.getAttribute('data-s-id') + '&p-id=' + e.target.getAttribute('data-p-id') + '&el_id=' + e.target.id
    $('#ratings_table').on 'click', '.comment', (e) ->
      # rid = $(event.target).data('#target-r-id').val()

      $('#editCommentModal .modal-body #comment').val($(rid).data('r-comment');
      $('#editCommentModal #target-r-id').val($(event.target).closest('.comment').data('r-id'));
      $("#editCommentModal").modal('show');
    $('#rating_screen').on 'submit', '#comment_form', (e) -> 
      e.preventDefault()
      e.stopPropagation()
      rid = $('#target-r-id').val()
      Rails.ajax
        type: "POST"
        url: 'ratings/save_comment',
        data: 'current_group_selected_id=' + $('#selected_group').val() + '&current_competency_selected_id=' + $('#selected_competency').val() + '&comment=' + $('#comment').val() + '&s-id=' + $('#' + rid).data('s-id') + '&p-id=' + $('#' + rid).data('p-id') + '&el_id=' + rid
      console.log 'submit comment'

      
      

    