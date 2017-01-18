$(document).on 'turbolinks:load', ->
  language =
    fr:
      button: 'Botão'
      text: 'Texto'
      checkbox: 'Checkbox'
      checkboxGroup: 'Groupe de checkbox'
      dateField: 'Data'
      header: 'Cabeçalho'
      paragraph: 'Parágrafo'
      hidden: 'Campo oculto'
      select: 'Menu suspenso'
      getStarted: 'Glissez un élément de droite dans cette zone.'
      editorTitle: 'Elementos de formulário'
      radioGroup: 'Grupo de rádio'
      textArea: 'Área de texto'
      viewXML: 'Exibir XML'
  formBuilder = $('#formbuilder-wrap').formBuilder({
    messages: language['fr'],
    dataType: 'json',
    showActionButtons: false,
    formData: $('#message_formdata').val()
  }).data('formBuilder')
  $(".form-builder-save").click (e) ->
    e.preventDefault()
    save_form(formBuilder.formData)
    alert(formBuilder.formData)

save_form = (form_json) ->
  form = $('#message_update_form')
  utf8 = form.find( "input[name='utf8']" ).val()
  authenticity_token = form.find( "input[name='authenticity_token']" ).val()
  $.ajax({
    type: "POST",
    url: form.attr('action'),
    data: {
      utf8: utf8,
      authenticity_token: authenticity_token,
      'message[formdata]': form_json,
      format: 'js',
      _method: form.find( "input[name='_method']" ).val()
    }
  });
