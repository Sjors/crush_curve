class AddUniqueConstraints < ActiveRecord::Migration[6.0]
  def up
    # Remove existing duplicated
    ids = Case.select("MIN(id) as id").group(:municipality_id,:day).collect(&:id)
    Case.where.not(id: ids).destroy_all

    add_index :municipalities, :cbs_id, unique: true
    add_index :cases, [:municipality_id, :day], unique: true
  end
end
