if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
  setInterval () ->
    refreshQr()
  , 100000

  formRender = $('#formrender-wrap').formRender({
    #messages: language['fr'],
    dataType: 'json',
    showActionButtons: false,
    formData: $('#formdata').val(),
    notify:
      success: (message) ->
        $('select').prepend("<option value='' selected='selected'></option>")
        $('input[required], textarea[required], select[required]').removeAttr('required').removeAttr('aria-required')
  })

  $('#message_form').submit (e) ->
    checkRequiredFields()
    if $('.missingfield').length > 0
      e.preventDefault()
      return false
    else
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


checkRequiredFields = () ->
  # take care of text field
  textfieldContainers = $('.required').parents('div.fb-text')
  checkboxgroupContainers = $('.required').parents('div.fb-checkbox.form-group')
  textareaContainers = $('.required').parents('div.fb-undefined.form-group')
  selectContainers = $('.required').parents('div.fb-select.form-group')

  isTextFieldEmpty textfieldContainer for textfieldContainer in textfieldContainers

  isCheckboxgroupEmpty checkboxgroupContainer for checkboxgroupContainer in checkboxgroupContainers

  isTextareaEmpty textareaContainer for textareaContainer in textareaContainers
  isSelectEmpty selectContainer for selectContainer in selectContainers

isTextFieldEmpty = (textfieldContainer) ->
  if $(textfieldContainer).find('input').val() == ""
    if $(textfieldContainer).find('.missingfield').length == 0
      $(textfieldContainer).find('label').prepend('<div class="missingfield">Champ Requis</div>')
  else
    if $(textfieldContainer).find('.missingfield').length > 0
      $(textfieldContainer).find('.missingfield').remove()
isCheckboxgroupEmpty = (checkboxgroupContainer) ->
  if $(checkboxgroupContainer).find('input:checked').length == 0
    if $(checkboxgroupContainer).find('.missingfield').length == 0
      $(checkboxgroupContainer).find('label.fb-checkbox-group-label').prepend('<div class="missingfield">Champ Requis</div>')
  else
    if $(checkboxgroupContainer).find('.missingfield').length > 0
      $(checkboxgroupContainer).find('.missingfield').remove()

isTextareaEmpty = (textareaContainer) ->
  if $(textareaContainer).find('textarea').val() == ""
    if $(textareaContainer).find('.missingfield').length == 0
      $(textareaContainer).find('label.fb-textarea-label').prepend('<div class="missingfield">Champ Requis</div>')
  else
    if $(textareaContainer).find('.missingfield').length > 0
      $(textareaContainer).find('.missingfield').remove()

isSelectEmpty = (selectContainer) ->
  if $(selectContainer).find('select').val() == ""
    if $(selectContainer).find('.missingfield').length == 0
      $(selectContainer).find('label.fb-select-label').prepend('<div class="missingfield">Champ Requis</div>')
  else
    if $(selectContainer).find('.missingfield').length > 0
      $(selectContainer).find('.missingfield').remove()

refreshQr = ->
  console.log('refreshQr')
  muuid = $('#muuid')
  $.ajax url: '/messages/refresh_qr/' + muuid.val()
  return
