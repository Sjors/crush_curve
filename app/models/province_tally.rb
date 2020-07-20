class ProvinceTally < ApplicationRecord
  belongs_to :province

  def self.daily
    where("day >= ?", CrushCurve::FIRST_PATIENT_DATE).distinct.order("day asc").pluck("day").collect {|day|
      {
        date: day.strftime("%d/%m"),
        cases: Province.all.collect{|province|
          province.province_tallies.where("day = ?", day).first.try(:new_cases) || 0
        },
        recent: 3.days.ago < day
      }
    }
  end

  def self.expire_cache
    Rails.cache.delete("ProvinceTally.daily")
  end
end
