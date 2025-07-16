class Api::V1::SiteSettingsController < ApplicationController
  before_action :authorize_admin, only: [:update_image]
  before_action :validate_image_setting, only: [:update_image, :show_image]

  # Generic method to update any image setting
  def update_image
    setting_key = params[:setting_key]
    site_setting = SiteSetting.find_or_initialize_by(key: setting_key)
    
    if params[:image].present?
      begin
        # Validate file type
        unless valid_image_format?(params[:image])
          return render json: { error: 'Formato de imagen no válido. Solo se permiten JPG, PNG, GIF y WEBP.' }, status: :unprocessable_entity
        end
        
        site_setting.image.attach(params[:image])
        site_setting.save!
        
        render json: {
          message: "Imagen de #{setting_display_name(setting_key)} actualizada correctamente",
          url: url_for(site_setting.image),
          setting_key: setting_key
        }, status: :ok
      rescue => e
        Rails.logger.error "Error updating image for #{setting_key}: #{e.message}"
        render json: { error: 'Error al procesar la imagen' }, status: :internal_server_error
      end
    else
      render json: { error: 'No hay imagen para actualizar' }, status: :unprocessable_entity
    end
  end

  # Generic method to show any image setting
  def show_image
    setting_key = params[:setting_key]
    site_setting = SiteSetting.find_by(key: setting_key)
    
    if site_setting&.image&.attached?
      render json: {
        url: url_for(site_setting.image),
        setting_key: setting_key
      }, status: :ok
    else
      render json: { 
        error: "No hay imagen para mostrar en #{setting_display_name(setting_key)}",
        setting_key: setting_key
      }, status: :not_found
    end
  end

  # Legacy methods for backward compatibility
  def update_hero_image
    params[:setting_key] = 'hero_image'
    update_image
  end

  def update_our_philosophy_image
    params[:setting_key] = 'our_philosophy_image'
    update_image
  end

  def show_hero_image
    params[:setting_key] = 'hero_image'
    show_image
  end

  def show_our_philosophy_image
    params[:setting_key] = 'our_philosophy_image'
    show_image
  end

  private

  def validate_image_setting
    valid_settings = %w[hero_image our_philosophy_image]
    setting_key = params[:setting_key]
    
    unless valid_settings.include?(setting_key)
      render json: { error: 'Configuración de imagen no válida' }, status: :bad_request
    end
  end

  def valid_image_format?(image)
    allowed_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    allowed_types.include?(image.content_type)
  end

  def setting_display_name(setting_key)
    case setting_key
    when 'hero_image'
      'hero'
    when 'our_philosophy_image'
      'filosofía'
    else
      setting_key
    end
  end
end