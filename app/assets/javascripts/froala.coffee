if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->
  $('#wysiwyg, #school_send_code_template').froalaEditor(
    key: 'gknlfgqifxyG5hcj1=='
    language: 'fr'
    heightMin: 300
    toolbarButtons: ['undo', 'redo',  '|', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript',  '|', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'insertHR', 'insertLink', 'insertTable', 'clearFormatting', 'selectAll']
  )
