class MunicipalitiesController < ApplicationController
  def show
    respond_to do |format|
      format.rss do
        @municipality = Municipality.friendly.find(params[:id])
        latest = Case.last
        if stale?(etag: latest.updated_at, last_modified: latest.updated_at)
          @cases = @municipality.cases.where("new_reports > ?", 0).where("day > ?", Date.new(2020,5,23)).order(day: :desc)
        end
      end
    end
  end
end
