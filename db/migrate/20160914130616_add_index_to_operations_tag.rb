class AddIndexToOperationsTag < ActiveRecord::Migration[5.0]
  def change
    add_index :operations, :tag
  end
end
