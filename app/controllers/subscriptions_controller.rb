class SubscriptionsController < ApplicationController
  before_action :get_auth_token
  before_action :get_municipality
  before_action :get_safari_subscription

  def add
    # Ignore if already subscribed
    if @safari_subscription.subscriptions.where(municipality: @municipality).count == 0
      @safari_subscription.subscriptions.create(municipality: @municipality)
    end
    render json: {message: 'ok'}, status: 200
  end

  def remove
    # Ignore not subscribed
    @safari_subscription.subscriptions.where(municipality: @municipality).destroy_all
    render json: {message: 'ok'}, status: 200
  end

  private

  def get_auth_token
    unless request.authorization.present? && request.authorization.start_with?("Basic")
      render json: { message: 'Bad request' }, status: :unprocessable_entity
      return
    end
    @auth_token = request.authorization.split(" ")[1]
  end

  def get_safari_subscription
    @safari_subscription = SafariSubscription.find_by!(auth_token: @auth_token)
  end

  def get_municipality
    @municipality = Municipality.find(params[:municipality_id])
  end

end
