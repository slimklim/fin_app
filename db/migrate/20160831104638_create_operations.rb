class CreateOperations < ActiveRecord::Migration[5.0]
  def change
    create_table :operations do |t|
      t.decimal :value, null: false, precision: 7, scale: 2
      t.boolean :credit, null: false
      t.date :date, null: false
      t.string :tag
      t.text :comment

      t.timestamps
    end
  end
end
