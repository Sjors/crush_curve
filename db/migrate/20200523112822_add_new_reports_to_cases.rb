class AddNewReportsToCases < ActiveRecord::Migration[6.0]
  def change
    add_column :cases, :new_reports, :integer
  end
end
