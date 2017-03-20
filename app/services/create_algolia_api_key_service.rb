class CreateAlgoliaApiKeyService
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def generate_key
    # Generate Api Key with filters on schools ids
    # see doc at https://www.algolia.com/doc/api-client/ruby/api-keys/#generate-key
    api_key = Algolia.generate_secured_api_key Rails.application.secrets.algolia_search_api_key, {'filters'=> build_filters(@user)}
    @user.update_column(:algolia_search_api_key, api_key)
  end

  private
    def build_filters(user)
      if user.superadmin?
        # No restriction
        return ""
      elsif user.admin?
        # Restrict on user.schools
        return @user.schools.reject!(&:blank?).map {|s| "school_id=#{s}"}.join(' OR ')
      elsif user.user?
        # Restrict on user.schools and author_id = user.id
        filters = '(' + @user.schools.map {|s| "school_id=#{s}"}.join(' OR ') + ')'
        filters += " AND author_id = #{user.id}"
        return filters
      end
    end

end
