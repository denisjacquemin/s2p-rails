class Message < ApplicationRecord
  belongs_to :school, required: false
  has_many :mfiles
  belongs_to :author, class_name: "User"

  enum status: [:draft, :published, :waiting_for_approval, :approval_refused, :approval_accepted ]
  after_initialize :set_default_status, :if => :new_record?

  def set_default_status
   self.status ||= :draft
  end

  def author_fullname
    fullname = ""
    fullname = "#{self.author.firstname} #{self.author.lastname}" if self.author
    return fullname
  end

  def groups_obj
    Group.by_ids(self.groups)
  end

  scope :by_ids, ->(ids) { where(id: ids) }

  def self.add_groups(message_ids, group_ids)
    Message.by_ids(message_ids).update_all(['groups = array_cat(groups, ARRAY[?])', group_ids])
  end

  def self.remove_groups(message_ids, group_ids)
    group_ids.each do |g_id|
      Message.by_ids(message_ids).update_all(['groups = array_remove(groups, ?)', g_id])
    end
  end

end
