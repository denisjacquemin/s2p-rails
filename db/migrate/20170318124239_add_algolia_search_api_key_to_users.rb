class AddAlgoliaSearchApiKeyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :algolia_search_api_key, :string
  end
end
