$(document).on 'turbolinks:load', ->
  formRender = $('#formrender-wrap').formRender({
    #messages: language['fr'],
    dataType: 'json',
    showActionButtons: false,
    formData: $('#formdata').val(),
    notify: {
    success: function(message) {
      $('select').prepend("<option value='' selected='selected'></option>");
    }
  })

  $('#message_form').submit (e) ->
    serializedForm = $('input, textarea, select', this).not( "[name='utf8']").not("[name='formdata']").not( "[name='authenticity_token']").not( "#message_form_formdata").not( "[name='muuid']").not('.btn').serializeArray()


    serializedWithLabel = []
    $.each(serializedForm, (index, data) ->
    #//$("[name='" + data.name + "']")
        label = $("[for='" + data.name.replace('[', '').replace(']', '') + "']").text()
        elem  = data
        elem['label'] = label
        serializedWithLabel.push(elem)
    )
    $('#message_form_formdata').val(JSON.stringify(serializedWithLabel))
