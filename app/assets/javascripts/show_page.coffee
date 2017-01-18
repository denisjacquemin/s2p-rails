$(document).on 'turbolinks:load', ->
  formRender = $('#formrender-wrap').formRender({
    #messages: language['fr'],
    dataType: 'json',
    showActionButtons: false,
    formData: $('#formdata').val()
  })
