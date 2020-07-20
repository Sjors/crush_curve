class RemoveInhabitantsFromMunicipalities < ActiveRecord::Migration[6.0]
  def up
    remove_column :municipalities, :inhabitants, :integer
    # These don't occur in the RIVM database
    Case.where("day < ?", Date.new(2020,3,13)).destroy_all
  end

  def down
    add_column :municipalities, :inhabitants, :integer
  end
end
