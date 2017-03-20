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
      filters = ""
      # if user is superadmin filters is ""
      if user.admin?
        # Restrict on user.schools
        schools = @user.schools.reject!(&:blank?)
        unless schools.nil?
          filters = schools.map {|s| "school_id=#{s}"}.join(' OR ')
        end
      elsif user.user?
        # Restrict on user.schools and author_id = user.id
        schools = @user.schools.reject!(&:blank?)
        unless schools.nil?
          filters = '(' + schools.map {|s| "school_id=#{s}"}.join(' OR ') + ') AND '
        end
        filters += "author_id = #{user.id}"
      end
      Rails.logger.info "Filters for #{user.fullname}: #{filters}"
      return filters
    end

end
