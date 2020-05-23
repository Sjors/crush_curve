class ProvincesController < ApplicationController
  def index
    @provinces = Province.all
    render component: 'Provinces', props: { provinces: @provinces }
  end
end
