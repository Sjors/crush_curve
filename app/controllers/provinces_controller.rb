class ProvincesController < ApplicationController
  def index
    @provinces = Province.all
    latest = Case.last
    if stale?(etag: latest.updated_at, last_modified: latest.updated_at)
      @days = Rails.cache.fetch("Case.daily_per_province") { Case.daily_per_province }
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
      @days = Rails.cache.fetch("Case.daily_per_municipality(#{ @province.id })") { Case.daily_per_municipality(@province) }
      render component: 'Province', props: {
        province: @province,
        municipalities: @province.municipalities,
        days: @days
      }
    end
  end
end
