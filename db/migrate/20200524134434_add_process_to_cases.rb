class AddProcessToCases < ActiveRecord::Migration[6.0]
  def change
    add_column :cases, :processed, :bool, null: false, default:  false
  end
end
