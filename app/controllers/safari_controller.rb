class SafariController < ApplicationController
  def log
    render json: {message: 'ok'}, status: 200
  end

  # POST /push/v2/pushPackages/web.nl.pletdecurve
  def package
    # Browser should supply an id that we'll use a auth_token
    auth_token = params[:auth_token]
    if auth_token.nil? ||  auth_token.length != 64 || auth_token[/\H/]
      render json: { message: 'Bad request' }, status: :unprocessable_entity
      return
    end

    # The browser may or may not download the same package twice
    @safari_subscription = SafariSubscription.find_or_create_by(auth_token: auth_token)
    path = SafariSubscription.generate_package!(@safari_subscription.auth_token)
    send_file path, :type => 'application/zip',
                :disposition => 'attachment',
                :filename => "pushPackage.zip"
  end

  # This is called after #package
  def register
    unless request.authorization.split(" ").length == 2
      render json: { message: 'Bad request' }, status: :unprocessable_entity
      return
    end
    auth_token = request.authorization.split(" ")[1]
    @safari_subscription = SafariSubscription.find_by(auth_token: auth_token)

    if !@safari_subscription.device_token.nil?
      # This shouldn't happen
      render json: { message: 'Bad request' }, status: :unprocessable_entity
      return
    end

    @safari_subscription.update device_token: params[:device_token]

    render json: {message: 'ok'}, status: 200
  end

  def deregister
    # Don't worry about the auth_token
    SafariSubscription.where(device_token: params[:device_token]).destroy_all
    render json: {message: 'ok'}, status: 200
  end

end
