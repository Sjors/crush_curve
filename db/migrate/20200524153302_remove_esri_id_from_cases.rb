class RemoveEsriIdFromCases < ActiveRecord::Migration[6.0]
  def change
    remove_column :cases, :esri_id, :string
  end
end
