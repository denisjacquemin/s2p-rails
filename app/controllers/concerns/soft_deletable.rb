module SoftDeletable
    extend ActiveSupport::Concern
    #https://stackoverflow.com/questions/12740397/how-to-simplify-the-soft-delete-process-with-ruby-on-rails

    # class AddDeletedAtToUsers < ActiveRecord::Migration
    #     def change
    #       add_column :users, :deleted_at, :datetime
    #     end
    #   end


    included do
      default_scope { where(deleted_at: nil) }
      scope :only_deleted, -> { unscoped.where(table_name+'.deleted_at IS NOT NULL') }
    end
  
    def delete
      update_column :deleted_at, DateTime.now if has_attribute? :deleted_at
    end
  
    # ... ... ...
    # ... OTHERS IMPLEMENTATIONS ...
    # ... ... ...
  
    # def restore!(opts = {})
    #   self.class.transaction do
    #     run_callbacks(:restore) do
    #       # Remove default_scope. "UPDATE ... WHERE (deleted_at IS NULL)"
    #       self.class.send(:unscoped) do
    #         update_column :deleted_at, nil
    #         restore_associated_records if opts[:recursive]
    #       end
    #     end
    #   end
    #   self
    # end
  
    # alias :restore :restore!
  
    # def restore_associated_records
    #   destroyed_associations = self.class.reflect_on_all_associations.select do |association|
    #     association.options[:dependent] == :destroy
    #   end
    #   destroyed_associations.each do |association|
    #     association_data = send(association.name)
    #     unless association_data.nil?
    #       if association_data.deleted_at?
    #         if association.collection?
    #           association_data.only_deleted.each { |record| record.restore(recursive: true) }
    #         else
    #           association_data.restore(recursive: true)
    #         end
    #       end
    #     end
    #     if association_data.nil? && association.macro.to_s == 'has_one'
    #       association_class_name = association.options[:class_name].present? ? association.options[:class_name] : association.name.to_s.camelize
    #       association_foreign_key = association.options[:foreign_key].present? ? association.options[:foreign_key] : "#{self.class.name.to_s.underscore}_id"
    #       Object.const_get(association_class_name).only_deleted.where(association_foreign_key, self.id).first.try(:restore, recursive: true)
    #     end
    #   end
    #   clear_association_cache if destroyed_associations.present?
    # end
  end