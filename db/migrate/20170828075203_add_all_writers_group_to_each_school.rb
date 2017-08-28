class AddAllWritersGroupToEachSchool < ActiveRecord::Migration[5.0]
  def up
    School.find_each do |school|
      Group.create({name: I18n.t('model.group.all_writers'), internal_id: 'all_writers', school_id: school.id, updatable: false})
    end
  end

  def down
    School.find_each do |school|
      Group.where(internal_id: 'all_writers').delete_all
    end
  end
end
