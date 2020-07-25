class AddReportDayToProvinceTallies < ActiveRecord::Migration[6.0]
  def up
    add_column :province_tallies, :report_day, :date
    ProvinceTally.update_all report_day: ProvinceTally.maximum(:day)
  end

  def down
    remove_column :province_tallies, :report_day
  end
end
