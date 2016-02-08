class CreateSuperAdminService
  def call
    user = User.find_or_create_by!(email: Rails.application.secrets.super_admin_email) do |user|
        user.password = Rails.application.secrets.super_admin_password
        user.firstname = Rails.application.secrets.super_admin_firstname
        user.lastname = Rails.application.secrets.super_admin_lastname
        user.superadmin!
      end
  end
end
