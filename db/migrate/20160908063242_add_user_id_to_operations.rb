class AddUserIdToOperations < ActiveRecord::Migration[5.0]
  def change
    add_column :operations, :user_id, :integer
    add_index :operations, [:user_id, :date]
  end
end
