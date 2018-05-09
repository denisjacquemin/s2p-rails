module StudentsHelper
  def classroom_label
    if current_school.iscity
      "Rue"
    else
      "Titulaire"
    end
  end

  def level_label
    if current_school.iscity
      "Entité"
    else
      "Année"
    end
  end
end
