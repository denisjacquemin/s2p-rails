class AddCommentToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :comment, :string
  end
end
