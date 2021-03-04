class AddDateToEvaluations < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluations, :date, :datetime
  end
end
