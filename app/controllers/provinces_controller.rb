class ProvincesController < ApplicationController
  def index
    @provinces = Province.all
    render component: 'Provinces', props: {
      provinces: @provinces,
      days: Case.where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
        {
          date: day.to_date,
          cases: Province.all.collect{|province|
            province.cases.where(day: day).sum(:new_reports)
          }
        }
      }
    }
  end

  def show
    @province = Province.find(params[:id])
    render component: 'Province', props: {
      municipalities: @province.municipalities,
      days: Case.where("day >= ?", Date.new(2020,4,9)).distinct.order(day: :asc).pluck(:day).collect {|day|
        {
          date: day.to_date.strftime("%d/%m") ,
          cases: @province.municipalities.collect{|municipality|
            municipality.cases.where(day: day).sum(:new_reports)
          }
        }
      }
    }
  end
end
