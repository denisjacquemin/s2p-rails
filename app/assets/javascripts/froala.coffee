$(document).on 'turbolinks:load', ->
  $('#wysiwyg, #school_send_code_template').froalaEditor(
    key: 'gknlfgqifxyG5hcj1=='
    language: 'fr'
    heightMin: 300
    toolbarButtons: ['undo', 'redo',  '|', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript',  '|', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'insertHR', 'insertLink', 'insertTable', 'clearFormatting', 'selectAll']
  )
