class Case < ApplicationRecord
  belongs_to :municipality

  def yesterday
    Case.where('date(day) = ?', (day - 1.day).to_date).where(municipality: municipality).first
  end
end
