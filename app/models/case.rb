class Case < ApplicationRecord
  belongs_to :municipality

  def yesterday
    Case.where('date(day) = ?', (day - 1.day).to_date).where(municipality: municipality).first
  end

  def self.daily_per_province
    where("day >= ?", CrushCurve::START_DATE + 1.day).distinct.order("date(day) asc").pluck("date(day)").collect {|day|
      {
        date: day.to_date.strftime("%d/%m"),
        cases: Province.all.collect{|province|
          province.cases.where(day: day).sum(:new_reports)
        }
      }
    }
  end

  def self.daily_per_municipality(wave, province)
    range = case wave
      when 1
        where("day >= ?", CrushCurve::FIRST_PATIENT_DATE).where("day < ?", CrushCurve::WAVE_2_START_DATE)
      when 2
        where("day >= ?", CrushCurve::WAVE_2_START_DATE)
      end

    range.where("day >= ?", CrushCurve::START_DATE + 1.day).distinct.order("date(day) asc").pluck("date(day)").collect {|day|
      {
        date: day.to_date.strftime("%d/%m"),
        cases: province.municipalities.collect{|municipality|
          municipality.cases.where(day: day).sum(:new_reports)
        },
        cases_24: province.municipalities.collect{|municipality|
          0
        }
      }
    }
  end

  def self.expire_cache
    Province.all.each do |province|
      [1,2].each do |wave|
        Rails.cache.delete("Case.daily_per_municipality(#{wave},#{province.id})")
      end
    end
  end

end
