class ChangeProvinceTallyDayType < ActiveRecord::Migration[6.0]
  def up
    change_column :province_tallies, :day, :date
  end
end
