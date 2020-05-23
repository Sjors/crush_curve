class CreateProvinces < ActiveRecord::Migration[6.0]
  def change
    create_table :provinces do |t|
      t.integer :cbs_n
      t.string :name

      t.timestamps
    end
  end
end
