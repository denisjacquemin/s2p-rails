





$(document).on 'ready', ->
  # uploadButton = $('<button/>').addClass('btn btn-primary').prop('disabled', true).text('Processing...').on('click', ->
  #   $this = $(this)
  #   data = $this.data()
  #   $this.off('click').text('Abort').on 'click', ->
  #     $this.remove()
  #     data.abort()
  #     return
  #   data.submit().always ->
  #     $this.remove()
  #     return
  #   return
  # )

  $('.directUpload').find('input:file').each (i, elem) ->
    console.debug 'init fileupload'
    fileInput = $(elem)
    form = $(fileInput.parents('form:first'))
    submitButton = form.find('input[type="submit"]')
    progressBar = $('<div class=\'progress-bar progress-bar-success\' style=\'width:0%;\'></div>')
    barContainer = $('<div class=\'progress progress-striped active\' role=\'progressbar\' aria-valuemin=\'0\' aria-valuemax=\'100\' aria-valuenow=\'0\'></div>').append(progressBar)
    filesToUpload = $('<div class=\'filesToUpload\'></div>').appendTo(form)
    # fileInput.after barContainer
    fileInput.fileupload
      fileInput: fileInput
      url: form.data('url')
      type: 'POST'
      autoUpload: false
      formData: form.data('form-data')
      paramName: 'file'
      dataType: 'XML'
      replaceFileInput: false
      maxFileSize: 10
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
      # disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent),
      # previewMaxWidth: 100,
      # previewMaxHeight: 100,
      # previewCrop: true
      # add: (e, data) ->
      #   console.log 'add'
      #   console.log form.data('url')
      #   return
        # data.context = $('<div class=\'fileToUpload\'></div>').appendTo(filesToUpload)
        # $.each data.files, (index, file) ->
        #   console.log JSON.stringify data
        #   node = $('<p/>').append($('<span/>').text(file.name))
        #   # if !index
        #   #   node.append('<br>').append uploadButton.clone(true).data(data)
        #   node.appendTo data.context
        #   return
      add: (e, data) ->
        console.log 'start'
        data.context = $('<div class=\'fileToUpload\'></div>').appendTo(filesToUpload)
        $.each data.files, (index, file) ->
          node = $('<p/>').append($('<span/>').text(file.name))
          node.append('<br>').append barContainer.clone(true)
          # if !index
          #   node.append('<br>').append uploadButton.clone(true).data(data)
          node.appendTo data.context
          return
        data.submit()
      processalways: (e, data) ->
        console.log 'processalways'
        currentFile = data.files[data.index]
        if data.files.error and currentFile.error
          # there was an error, do something about it
          console.log currentFile.error
        # index = data.index
        # file = data.files[index]
        # node = $(data.context.children()[index])
        # if file.preview
        #   node.prepend('<br>').prepend file.preview
        # if file.error
        #   node.append('<br>').append $('<span class="text-danger"/>').text(file.error)
        # if index + 1 == data.files.length
        #   data.context.find('button').text('Upload').prop 'disabled', ! !data.files.error
      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        if data.context
          data.context.each ->
            $(this).find('.progress').attr('aria-valuenow', progress).children().first().css 'width', progress + '%'
            return
      done: (e, data) ->
        console.log 'done'
        key = $(data.jqXHR.responseXML).find('Key').text()
        url = '//' + form.data('host') + '/' + key
        # create hidden field
        # input = $('<input />',
        #   type: 'hidden'
        #   name: fileInput.attr('name')
        #   value: url)
        # form.append input
        # submit to backend
        utf8 = form.find( "input[name='utf8']" ).val()
        authenticity_token = form.find( "input[name='authenticity_token']" ).val()
        $.ajax({
          type: "POST",
          url: form.attr('action'),
          data: {
            utf8: utf8,
            authenticity_token: authenticity_token,
            'mfile[file_url]': url,
            format: 'js',
            'mfile[message_id]': $('#message_id').val()
          }
        });


        # $.each data.result.files, (index, file) ->
        # if file.url
        #   link = $('<a>').attr('target', '_blank').prop('href', file.url)
        #   $(data.context.children()[index]).wrap link
        # else if file.error
        #   error = $('<span class="text-danger"/>').text(file.error)
        #   $(data.context.children()[index]).append('<br>').append error
        # return
      fail: (e, data) ->
        console.log 'fail'
        # $.each data.files, (index) ->
        # error = $('<span class="text-danger"/>').text('File upload failed.')
        # $(data.context.children()[index]).append('<br>').append error
        # return
    return
  return

$(document).ready(ready)
$(document).on('page:load', ready)
