class CreateCases < ActiveRecord::Migration[6.0]
  def change
    create_table :cases do |t|
      t.references :municipality, null: false, foreign_key: true
      t.integer :esri_id, null: false
      t.datetime :day, null: false
      t.integer :reports
      t.integer :hospitalizations
      t.integer :deaths

      t.timestamps
    end
  end
end
