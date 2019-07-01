json.set! :data do
  json.array! @competencies do |competency|
    json.partial! 'competencies/competency', competency: competency
    json.url  "
              #{link_to 'Show', competency }
              #{link_to 'Edit', edit_competency_path(competency)}
              #{link_to 'Destroy', competency, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end