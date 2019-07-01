json.set! :data do
  json.array! @ratings do |rating|
    json.partial! 'ratings/rating', rating: rating
    json.url  "
              #{link_to 'Show', rating }
              #{link_to 'Edit', edit_rating_path(rating)}
              #{link_to 'Destroy', rating, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end