$(document).on 'turbolinks:load', ->
  $('.attachinary-input').attachinary
    disableWith: 'Téléchargement'
    indicateProgress: false
    invalidFormatMessage: 'Format d\'image invalide'
    template: """
        <div id="thumbnails">
          <% for(var i=0; i<files.length; i++){ %>
            <div class="col-lg-3 col-md-4 col-xs-6 thumb">
                <a class="thumbnail" href="#">
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
    save_photos $('#message_add_photo')
  $('.attachinary-input').bind 'fileuploadprogressall', (event, data) ->
    console.log 'in fileuploadprogressall'
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('.progress').visible().attr('aria-valuenow', progress).children().first().css 'width', progress + '%'
    if progress == 100
      setTimeout ->
        save_photos $('#message_add_photo')
        $('.progress').invisible()
      , 1200
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
