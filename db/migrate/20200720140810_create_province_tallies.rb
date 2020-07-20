class CreateProvinceTallies < ActiveRecord::Migration[6.0]
  def change
    create_table :province_tallies do |t|
      t.datetime :day, null: false
      t.references :province, null: false, foreign_key: true
      t.integer :new_cases, null: false

      t.timestamps
    end
  end
end
