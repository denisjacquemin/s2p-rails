json.set! :data do
  json.array! @rating_years do |rating_year|
    json.partial! 'rating_years/rating_year', rating_year: rating_year
    json.url  "
              #{link_to 'Show', rating_year }
              #{link_to 'Edit', edit_rating_year_path(rating_year)}
              #{link_to 'Destroy', rating_year, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end