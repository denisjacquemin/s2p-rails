json.set! :data do
  json.array! @evaluations do |evaluation|
    json.partial! 'evaluations/evaluation', evaluation: evaluation
    json.url  "
              #{link_to 'Show', evaluation }
              #{link_to 'Edit', edit_evaluation_path(evaluation)}
              #{link_to 'Destroy', evaluation, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end