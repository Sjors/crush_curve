class ProvincesController < ApplicationController
  before_action :check_stale

  def index
    @provinces = Province.all
    @days = Rails.cache.fetch("Case.daily_per_province") { Case.daily_per_province }
    render component: 'Provinces', props: {
      provinces: @provinces,
      days: @days
    }
  end

  def show
    @province = Province.friendly.find(params[:id])
    @days = Rails.cache.fetch("Case.daily_per_municipality(#{ @province.id })") { Case.daily_per_municipality(@province) }
    render component: 'Province', props: {
      province: @province,
      municipalities: @province.municipalities,
      days: @days
    }, prerender: false
  end

  private

  def check_stale
    latest = Case.all.order(updated_at: :desc).first
    stale?(etag: latest.updated_at, last_modified: latest.updated_at)
  end
end
