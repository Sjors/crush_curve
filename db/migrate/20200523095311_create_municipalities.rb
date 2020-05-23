class CreateMunicipalities < ActiveRecord::Migration[6.0]
  def change
    create_table :municipalities do |t|
      t.references :province, null: false, foreign_key: true
      t.string :cbs_id, null: false
      t.string :name, null: false
      t.integer :inhabitants, null: false

      t.timestamps
    end
  end
end
