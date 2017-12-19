class School < ApplicationRecord

  has_many :students, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :accounts, dependent: :destroy
  accepts_nested_attributes_for :accounts, allow_destroy: true

  scope :by_ids, ->(ids) { where(id: ids) }

  def send_code_template
    self[:send_code_template] || I18n.t('views.students.sendcode.content')
  end

  def send_code_title_template
    self[:send_code_title_template] || I18n.t('views.students.sendcode.title')
  end

  def has_sms_provision?
    self.sms_provision > 0
  end

  def users
    User.by_school(self.id)
  end

  def admins
    self.users.active_and_invitation_accepted.admin
  end

  def levels
    self.students.order(:level).pluck(:level).uniq.compact
  end

  before_destroy do
    users = User.by_school(self.id)
    users.each do |u|
      User.remove_schools(u.id, [self.id])
    end
  end

  after_create do
    Group.create({name: I18n.t('model.group.all_students'), internal_id: 'all_students', school_id: self.id, updatable: false})
    Group.create({name: I18n.t('model.group.all_writers'), internal_id: 'all_writers', school_id: self.id, updatable: false})
    User.superadmin.update_all(['schools = array_append(schools, ?)', self.id])
  end

  def billing_enable?
    self.payconiq_access_token.present?
  end
end
