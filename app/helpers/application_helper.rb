module ApplicationHelper
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  # check if current user can access current_school
  def authorize_current_school(current_user, current_school_id)
    unless current_user.schools.include?(current_school_id)
      session[:current_school]  = current_user.schools[0]
      raise Pundit::NotAuthorizedError, "Pas autorisé" 
    end
  end

  # check if current user role can access current screen
  def role_has_access(current_user, current_screen)
    if current_user.user? and ["students"].include?(current_screen)
      raise Pundit::NotAuthorizedError, "Pas autorisé" 
    end
  end
end
