class AddNotifiedToCases < ActiveRecord::Migration[6.0]
  def change
    add_column :cases, :notified, :boolean, default: false, null: false
  end
end
