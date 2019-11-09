if not Turbolinks.supported
  $(document).ready ->
    ready()

$(document).on 'turbolinks:load', ->
  ready()

ready = () ->
   $('#wysiwyg, #school_send_code_template').trumbowyg({
       lang: 'fr',
       minimalLinks: true,
       btns: [
        ['undo', 'redo'],
        ['emoji'],
        ['foreColor', 'backColor'],
        ['strong', 'em', 'underline', 'del'],
        ['superscript', 'subscript'],
        ['justifyLeft', 'justifyRight'],
        ['table', 'link'],
        ['unorderedList', 'orderedList'],
        ['removeformat']
       ],
       removeformatPasted: false,
       allowTagsFromPaste: [
            'a',
            'b',
            'bdi',
            'bdo',
            'del',
            'em',
            'i',
            'ins',
            's',
            'small',
            'strong',
            'sub',
            'sup',
            'u',
            'ul',
            'ol',
            'li',
            'dl',
            'dt',
            'dd',
            'table',
            'caption',
            'th',
            'tr',
            'td',
            'thead',
            'tbody',
            'tfoot',
            'p',
        ],
       plugins: {
            table: {
                langs: 'fr'
            }
            
        }
    });