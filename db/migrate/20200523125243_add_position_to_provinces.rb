class AddPositionToProvinces < ActiveRecord::Migration[6.0]
  def change
    add_column :provinces, :position, :integer
  end
end
