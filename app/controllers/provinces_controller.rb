class ProvincesController < ApplicationController
  before_action :set_wave, :check_stale

  def index
    @provinces = Province.all
    @days = Rails.cache.fetch("ProvinceTally.daily(#{ @wave })") { ProvinceTally.daily(@wave) }
    render component: 'Provinces', props: {
      provinces: @provinces,
      days: @days,
      wave: @wave
    }
  end

  def show
    @province = Province.friendly.find(params[:id])
    @days = Rails.cache.fetch("Case.daily_per_municipality(#{ @wave },#{ @province.id })") { Case.daily_per_municipality(@wave, @province) }
    render component: 'Province', props: {
      province: @province,
      municipalities: @province.municipalities,
      days: @days,
      wave: @wave
    }, prerender: false
  end

  private

  def set_wave
    @wave = params[:wave_id] ? params[:wave_id].to_i : 2
    @wave = 2 if ![1,2].include?(@wave)
  end

  def check_stale
    latest = Case.all.order(updated_at: :desc).first
    stale?(etag: latest.updated_at, last_modified: latest.updated_at)
  end
end
