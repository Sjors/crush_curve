class ProvinceTally < ApplicationRecord
  belongs_to :province

  # If cached, it must be expired when new records are added
  def self.daily(wave)

    report_day = ProvinceTally.maximum(:report_day)
    range = case wave
      when 1
        where("day >= ?", CrushCurve::FIRST_PATIENT_DATE).where("day < ?", CrushCurve::WAVE_2_START_DATE)
      when 2
        where("day >= ?", CrushCurve::WAVE_2_START_DATE)
      end
    range.where(report_day: report_day).distinct.order("day asc").pluck("day").collect {|day|
      {
        date: day.strftime("%d/%m"),
        cases: Province.all.collect{|province|
          province.province_tallies.where(report_day: report_day, day: day).first.try(:new_cases) || 0
        },
        cases_24: Province.all.collect{|province|
          (province.province_tallies.where(report_day: report_day, day: day).where("day < report_day").first.try(:new_cases) || 0) -
          (province.province_tallies.where(report_day: report_day - 1.day, day: day).where("day < report_day").first.try(:new_cases) || 0)
        },
        recent: report_day - 7.days < day
      }
    }
  end

  def self.expire_cache
    [1,2].each do |wave|
      Rails.cache.delete("ProvinceTally.daily(#{wave})")
    end
  end
end
