class ProvincesController < ApplicationController
  def index
    @provinces = Province.all
    latest = Case.last
    if stale?(etag: latest.updated_at, last_modified: latest.updated_at)
      @days = Case.where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
        {
          date: day.to_date,
          cases: Province.all.collect{|province|
            province.cases.where(day: day).sum(:new_reports)
          }
        }
      }
      render component: 'Provinces', props: {
        provinces: @provinces,
        days: @days
      }
    end
  end

  def show
    @province = Province.friendly.find(params[:id])
    latest = Case.last
    if stale?(etag: latest.updated_at, last_modified: latest.updated_at)
      @days = Case.where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
        {
          date: day.to_date.strftime("%d/%m") ,
          cases: @province.municipalities.collect{|municipality|
            municipality.cases.where(day: day).sum(:new_reports)
          }
        }
      }
      render component: 'Province', props: {
        municipalities: @province.municipalities,
        days: @days
      }
    end
  end
end
