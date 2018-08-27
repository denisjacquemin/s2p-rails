if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()


ready = () ->

  $(document).bind 'drop dragover', (e) ->
    e.preventDefault()
    return

  $('.dropzone').bind 'dragover', (e) ->
    $('.dropzone').addClass('dragover')

  $('.dropzone').bind 'dragleave', (e) ->
    $('.dropzone').removeClass('dragover')


  $('.attachinary-input').attachinary
    disableWith: 'Téléchargement...'
    indicateProgress: false
    dropZone: $('.dropzone')
    invalidFormatMessage: 'Format de fichier invalide (uniquement jpg, png, gif et pdf)'
    template: """
        <div id="thumbnails">
          <% for(var i=0; i<files.length; i++){ %>
            <div class="col-lg-3 col-md-4 col-xs-6 thumb">
              <a class="thumbnail" target="_blank" href="<%= $.cloudinary.url(files[i].public_id) %>">
                <img
                  src="<%= $.cloudinary.url(files[i].public_id, { "version": files[i].version, "format": 'jpg', "crop": 'fill', "width": 200, "height": 200 }) %>"
                  alt="" width="200" height="200"
                  class="img-responsive" />
              </a>
                <a href="#" class="remove-photo" data-remove="<%= files[i].public_id %>">Effacer</a>
            </div>
          <% } %>
        </div>
      """
  # $('.attachinary-input').bind 'fileuploaddone', (event, data) ->
  #   console.log 'fileuploaddone : ' + data
  #   fileInput = $(this)
  #   form = $(fileInput.parents('form:first'))
  #   save_photos(form)
  $('.attachinary-input').bind 'attachinary:fileadded', (event, data) ->
    console.log 'fileadded'
  $('.attachinary-input').bind 'attachinary:fileremoved', (event, data) ->
    console.log 'fileremoved'
    $('.maximumreached').hide()
    #save_photos $('#message_add_photo')
  $('.attachinary-input').bind 'fileuploadfail', (event, data) ->
    console.log 'fileuploadfail'
    console.log data
    console.log 'size ' + data.total
    message = data.errorThrown
    numberOfFiles = data.attachinary.files.length + data.originalFiles.length
    if (data.messages.uploadedBytes == 'Uploaded bytes exceed file size')
      message = "Taille maximale d'une image dépassée (max 10Mb)."
    if (numberOfFiles > data.attachinary.maximum)
      message = 'Le maximum de ' + data.attachinary.maximum + ' fichiers est atteint'
      $('.progress').invisible()
      $('.maximumreached').show()
    # console.log 'fileuploadfail'
    # console.log 'originalFiles.length: ' + data.originalFiles.length
    # console.log 'attachinary.maximum: ' + data.attachinary.maximum
    # console.log data
    $.snackbar({content: message, style: 'error', timeout: 10000});
  $('.attachinary-input').bind 'fileuploadprogressall', (event, data) ->
    console.log 'in fileuploadprogressall'
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('.progress').visible().attr('aria-valuenow', progress).children().first().css 'width', progress + '%'
    if progress == 100
      $('.progress').invisible()
      #setTimeout ->
        #save_photos $('#message_add_photo')
      #, 1200
    return



    # key = $(data.jqXHR.responseXML).find('Key').text()
    # url = '//' + form.data('host') + '/' + key
    # create hidden field
    # input = $('<input />',
    #   type: 'hidden'
    #   name: fileInput.attr('name')
    #   value: url)
    # form.append input
    # submit to backend
    # utf8 = form.find( "input[name='utf8']" ).val()
    # authenticity_token = form.find( "input[name='authenticity_token']" ).val()
    # photos_metadata = form.find( "input[name='message[photos][]']" )[1].value
    # $.ajax({
    #   type: "POST",
    #   url: form.attr('action'),
    #   data: {
    #     utf8: utf8,
    #     authenticity_token: authenticity_token,
    #     'message[photos]': photos_metadata,
    #     format: 'js',
    #     _method: form.find( "input[name='_method']" ).val()
    #   }
    # });


save_photos = (form) ->
  console.log 'save_photos'
  utf8 = form.find( "input[name='utf8']" ).val()
  authenticity_token = form.find( "input[name='authenticity_token']" ).val()
  photos_metadata = form.find( "input[name='message[photos][]']" )[1].value
  $.ajax({
    type: "POST",
    url: form.attr('action'),
    data: {
      utf8: utf8,
      authenticity_token: authenticity_token,
      'message[photos]': photos_metadata,
      format: 'js',
      _method: form.find( "input[name='_method']" ).val()
    }
  });
