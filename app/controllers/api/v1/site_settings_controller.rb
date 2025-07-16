class Api::V1::SiteSettingsController < ApplicationController
  before_action :authorize_admin, only: [:update_hero_image]

  def update_hero_image
    site_setting = SiteSetting.find_or_initialize_by(key: 'hero_image')
    if params[:image].present?
        site_setting.image.attach(params[:image])
        site_setting.save!
        render json: {message: 'Imagen actualizada correctamente', url: url_for(site_setting.image)}, status: :ok
    else
        render json: {error: 'No hay imagen para actualizar'}, status: :unprocessable_entity
    end
  end


  def show_hero_image
    site_setting = SiteSetting.find_by(key: 'hero_image')
    if site_setting&.image&.attached?
      render json: {url: url_for(site_setting.image)}, status: :ok
    else
      render json: {error: 'No hay imagen para mostrar'}, status: :not_found
    end
  end
end