class CreateCompetenciesAndGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :competencies_groups, id: false do |t|
      t.belongs_to :competency, index: true
      t.belongs_to :group, index: true
    end
  end
end
