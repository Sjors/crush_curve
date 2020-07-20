class ProvinceTally < ApplicationRecord
  belongs_to :province

  def self.daily
    where("day >= ?", CrushCurve::FIRST_PATIENT_DATE).distinct.order("date(day) asc").pluck("date(day)").collect {|day|
      {
        date: day.to_date.strftime("%d/%m"),
        cases: Province.all.collect{|province|
          province.province_tallies.where("date(day) = ?", day).first.try(:new_cases) || 0
        },
        recent: 3.days.ago < day.to_date
      }
    }
  end

  def self.expire_cache
    Rails.cache.delete("ProvinceTally.daily")
  end
end
