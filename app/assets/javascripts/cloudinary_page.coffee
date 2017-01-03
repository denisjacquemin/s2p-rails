$(document).on 'turbolinks:load', ->
  $('.attachinary-input').attachinary
    disableWith: 'Téléchargement'
    invalidFormatMessage: 'Format d\'image invalide'
    template: """
        <ul>
          <% for(var i=0; i<files.length; i++){ %>
            <div class="col-lg-3 col-md-4 col-xs-6 thumb">
                <a class="thumbnail" href="#">
                <img
                  src="<%= $.cloudinary.url(files[i].public_id, { "version": files[i].version, "format": 'jpg', "crop": 'fill', "width": 300, "height": 300 }) %>"
                  alt="" width="300" height="300"
                  class="img-responsive" />
                </a>
                <a href="#" data-remove="<%= files[i].public_id %>">Effacer</a>
            </div>
          <% } %>
        </ul>
      """
