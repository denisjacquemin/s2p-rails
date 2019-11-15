json.set! :data do
  json.array! @rating_comments do |rating_comment|
    json.partial! 'rating_comments/rating_comment', rating_comment: rating_comment
    json.url  "
              #{link_to 'Show', rating_comment }
              #{link_to 'Edit', edit_rating_comment_path(rating_comment)}
              #{link_to 'Destroy', rating_comment, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end