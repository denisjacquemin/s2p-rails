class AddUuidToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :uuid, :uuid

    reversible do |change|
      change.up do
        Student.all.each do |s|
          if s.uuid.nil?
            s.uuid = SecureRandom.uuid
            s.save
          end
        end
      end
    end

  end
end
