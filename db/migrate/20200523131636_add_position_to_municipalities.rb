class AddPositionToMunicipalities < ActiveRecord::Migration[6.0]
  def change
    add_column :municipalities, :position, :integer
  end
end
