class AddSlugToMunicipalities < ActiveRecord::Migration[6.0]
  def change
    add_column :municipalities, :slug, :string
    add_index :municipalities, :slug, unique: true
    Municipality.find_each(&:save)
  end
end
