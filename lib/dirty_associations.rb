module DirtyAssociations

    attr_accessor :dirty_associations
  
    def set_dirty_associations(p)
      self.dirty_associations = true
    end
  
    def previous_changed?
      dirty_associations || previous_changes.empty?
    end
end