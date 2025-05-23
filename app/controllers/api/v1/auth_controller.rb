class Api::V1::AuthController < ApplicationController
  def register
    user = User.new(user_params)
    if user.save
      render json: { user: user.as_json(except: [:password_digest]), token: encode_token(user_id: user.id) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { user: user.as_json(except: [:password_digest]), token: encode_token(user_id: user.id) }, status: :ok
    else
      render json: { error: 'Email o contraseña incorrectos' }, status: :unauthorized
    end
  end

  def me
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      user = User.find(decoded['user_id'])
      render json: { user: user.as_json(except: [:password_digest]) }, status: :ok
    rescue
      render json: { error: 'Token inválido o expirado' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
