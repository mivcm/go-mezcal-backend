class ApplicationController < ActionController::API
  include ActionController::Cookies
  before_action :set_stripe_key # add this line


  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      @current_user = User.find(decoded['user_id'])
    rescue JWT::DecodeError
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def authorize_admin
    authorize_request
    render json: { error: 'Forbidden' }, status: :forbidden unless @current_user&.admin?
  end

  private
  def set_stripe_key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end
end
