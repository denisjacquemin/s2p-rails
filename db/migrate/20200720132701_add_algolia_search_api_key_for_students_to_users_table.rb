class AddAlgoliaSearchApiKeyForStudentsToUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :algolia_search_api_key_for_students, :string
  end
end
