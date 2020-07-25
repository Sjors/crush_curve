class ProvinceTally < ApplicationRecord
  belongs_to :province

  # If cached, it must be expired when new records are added
  def self.daily
    report_day = ProvinceTally.maximum(:report_day)
    where(report_day: report_day).where("day >= ?", CrushCurve::FIRST_PATIENT_DATE).distinct.order("day asc").pluck("day").collect {|day|
      {
        date: day.strftime("%d/%m"),
        cases: Province.all.collect{|province|
          province.province_tallies.where(report_day: report_day, day: day).first.try(:new_cases) || 0
        },
        recent: report_day - 3.days < day
      }
    }
  end

  def self.expire_cache
    Rails.cache.delete("ProvinceTally.daily")
  end
end
