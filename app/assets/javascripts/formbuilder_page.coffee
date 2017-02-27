$(document).on 'turbolinks:load', ->
  language =
    fr:
      text: 'Texte'
      textArea: 'Texte long'
      copy: 'Copier'
      addOption: 'Ajouter Option'
      allFieldsRemoved: 'Tous les champs supprimé.'
      allowSelect: 'Permettre la sélection'
      autocomplete: 'Autocomplete'
      button: 'Bouton'
      cannotBeEmpty: 'Ce champ ne peut être vide'
      checkboxGroup: 'Groupe de case à cocher'
      checkbox: 'Case à cocher'
      checkboxes: 'Cases à cocher'
      className: 'Classe'
      clearAllMessage: 'Are you sure you want to clear all fields?'
      clearAll: 'Effacer'
      close: 'Fermer'
      content: 'Contenu'
      dateField: 'Champ date'
      description: "Texte d'aide"
      descriptionField: 'Description'
      devMode: 'Mode développeur'
      editNames: 'Edition des noms'
      editorTitle: 'Eléments du formulaire'
      editXML: 'Edition XML'
      enableOther: 'Permettre "Autre"'
      enableOtherMsg: "Permettre d'entrer une autre valeur"
      fieldDeleteWarning: false
      fieldVars: 'Field Variables'
      fieldNonEditable: 'This field cannot be edited.'
      fieldRemoveWarning: 'Are you sure you want to remove this field?'
      fileUpload: 'File Upload'
      formUpdated: 'Form Updated'
      getStarted: 'Faire glisser un champ de la colonne de droite dans cette zone'
      header: 'Header'
      hide: 'Edition'
      hidden: 'Hidden Input'
      label: 'Label'
      labelEmpty: 'Field Label cannot be empty'
      limitRole: 'Limit access to one or more of the following roles:'
      mandatory: 'Mandatory'
      maxlength: 'Max Length'
      minOptionMessage: 'This field requires a minimum of 2 options'
      name: 'Name'
      no: 'No'
      number: 'Number'
      off: 'Off'
      on: 'On'
      option: 'Option'
      optional: 'optional'
      optionLabelPlaceholder: 'Label'
      optionValuePlaceholder: 'Value'
      optionEmpty: 'Option value required'
      other: 'Autre'
      paragraph: 'Paragraphe'
      placeholder: 'Placeholder'
      placeholders: {
        value: 'Value'
        label: 'Label'
        text: ''
        textarea: ''
        email: 'Enter you email'
        placeholder: ''
        className: 'space separated classes'
        password: 'Enter your password'
      }
      preview: 'Preview'
      radioGroup: 'Radio Group'
      radio: 'Radio'
      removeMessage: "Effacer l'élément"
      remove: '×'
      required: 'Champ obligatoire'
      richText: 'Rich Text Editor'
      roles: 'Access'
      save: 'Save'
      selectOptions: 'Options'
      select: 'Select'
      selectColor: 'Select Color'
      selectionsMessage: 'Allow Multiple Selections'
      size: 'Size'
      sizes: {
        xs: 'Extra Small'
        sm: 'Small'
        m: 'Default'
        lg: 'Large'
      }
      style: 'Style'
      styles: {
        btn: {
          'default': 'Default'
          danger: 'Danger'
          info: 'Info'
          primary: 'Primary'
          success: 'Success'
          warning: 'Warning'
        }
      },
    subtype: 'Type'
    subtypes: {
      text: [
        'text'
        'password'
        'email'
        'color'
      ]
      button: [
        'button'
        'submit'
      ]
      header: [
        'h1'
        'h2'
        'h3'
      ]
      paragraph: [
        'p'
        'address'
        'blockquote'
        'canvas'
        'output'
      ]
    }
    toggle: 'Toggle'
    warning: 'Warning!'
    viewXML: '</>'
    yes: 'Yes'
  formBuilder = $('#formbuilder-wrap').formBuilder({
    messages: language['fr'],
    # editOnAdd: true,
    dataType: 'json',
    disableFields: ['select','hidden','file','date','button','autocomplete', 'header', 'number', 'radio-group'],
    showActionButtons: false,
    typeUserEvents: {
        'checkbox-group': {
          onadd: (fld) ->
            $('.option-selected, .checkbox-group', fld).prop('checked', false)
            $(fld).on('keyup', '.option-label', (e) ->
              $(this).next().val(e.target.value)
            )
        }
    },
    formData: $('#message_formdata').val()
  }).data('formBuilder')
  $(".form-builder-save").click (e) ->
    e.preventDefault()
    save_form(formBuilder.formData)
  $('.option-label').change (e) ->
    console.log e.target.value
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
