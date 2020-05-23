class Case < ApplicationRecord
  belongs_to :municipality

  # New records are added daily. If any historical records are changed, those
  # are problaby updated at the same time. If that changes, we need to clear
  # cache after_update as well.
  after_create :expire_cache

  def yesterday
    Case.where('date(day) = ?', (day - 1.day).to_date).where(municipality: municipality).first
  end

  def self.daily_per_province
    where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
      {
        date: day.to_date,
        cases: Province.all.collect{|province|
          province.cases.where(day: day).sum(:new_reports)
        }
      }
    }
  end

  def self.daily_per_municipality(province)
    Case.where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
      {
        date: day.to_date.strftime("%d/%m") ,
        cases: province.municipalities.collect{|municipality|
          municipality.cases.where(day: day).sum(:new_reports)
        }
      }
    }
  end

  private

  def expire_cache
    Rails.cache.delete("Case.daily_per_province")
    Province.all.each do |province|
      Rails.cache.delete("Case.daily_per_municipality(#{province.id})")
    end
  end

end
