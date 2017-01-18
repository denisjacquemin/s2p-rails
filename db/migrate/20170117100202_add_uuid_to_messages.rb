class AddUuidToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :uuid, :uuid

    reversible do |change|
      change.up do
        Message.all.each do |s|
          if s.uuid.nil?
            s.uuid = SecureRandom.uuid
            s.save
          end
        end
      end
    end

  end
end
