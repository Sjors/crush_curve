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

  def self.daily_per_municipality(province)
    where("day >= ?", CrushCurve::START_DATE + 1.day).distinct.order("date(day) asc").pluck("date(day)").collect {|day|
      {
        date: day.to_date.strftime("%d/%m"),
        cases: province.municipalities.collect{|municipality|
          municipality.cases.where(day: day).sum(:new_reports)
        },
        cases_24: province.municipalities.collect{|municipality|
          0
        },
        municipality_cancelled:  province.municipalities.collect{|municipality|
          municipality.cancelled(day)
        }
      }
    }
  end

  def self.expire_cache
    Province.all.each do |province|
      Rails.cache.delete("Case.daily_per_municipality(#{province.id})")
    end
  end

end
