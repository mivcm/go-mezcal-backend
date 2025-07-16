class Api::V1::ContactMessagesController < ApplicationController
  before_action :authorize_admin, only: [:index, :show, :mark_as_read, :destroy]

  # Public endpoint for creating contact messages
  def create
    contact_message = ContactMessage.new(contact_message_params)
    
    if contact_message.save
      # Optionally send email notification to admin
      # ContactMailer.new_message_notification(contact_message).deliver_later
      
      render json: {
        message: 'Mensaje enviado correctamente. Nos pondremos en contacto contigo pronto.',
        id: contact_message.id
      }, status: :created
    else
      render json: { 
        errors: contact_message.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  # Admin endpoint to list all contact messages
  def index
    messages = ContactMessage.recent
    
    # Filter by read status if provided
    if params[:read].present?
      messages = messages.where(read: params[:read] == 'true')
    end
    
    # Filter by email if provided
    if params[:email].present?
      messages = messages.where('email ILIKE ?', "%#{params[:email]}%")
    end
    
    # Pagination
    per_page = params[:per_page]&.to_i || 20
    per_page = [per_page, 100].min # Max 100 per page
    page = params[:page]&.to_i || 1
    page = [page, 1].max # Minimum page is 1
    
    # Manual pagination
    total_count = messages.count
    total_pages = (total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    messages = messages.offset(offset).limit(per_page)
    
    render json: {
      messages: messages.map { |msg| contact_message_json(msg) },
      pagination: {
        current_page: page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end

  # Admin endpoint to show a specific message
  def show
    contact_message = ContactMessage.find(params[:id])
    render json: contact_message_json(contact_message)
  end

  # Admin endpoint to mark message as read
  def mark_as_read
    contact_message = ContactMessage.find(params[:id])
    contact_message.mark_as_read!
    
    render json: {
      message: 'Mensaje marcado como leído',
      contact_message: contact_message_json(contact_message)
    }
  end

  # Admin endpoint to delete a message
  def destroy
    contact_message = ContactMessage.find(params[:id])
    contact_message.destroy
    
    render json: { message: 'Mensaje eliminado correctamente' }
  end

  # Admin endpoint to get stats
  def stats
    total_messages = ContactMessage.count
    unread_messages = ContactMessage.unread.count
    recent_messages = ContactMessage.where('created_at >= ?', 7.days.ago).count
    
    render json: {
      total_messages: total_messages,
      unread_messages: unread_messages,
      recent_messages: recent_messages,
      read_percentage: total_messages > 0 ? ((total_messages - unread_messages).to_f / total_messages * 100).round(1) : 0
    }
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :phone, :subject, :message)
  end

  def contact_message_json(contact_message)
    {
      id: contact_message.id,
      name: contact_message.name,
      email: contact_message.email,
      phone: contact_message.display_phone,
      subject: contact_message.subject,
      message: contact_message.message,
      short_message: contact_message.short_message,
      read: contact_message.read,
      created_at: contact_message.created_at,
      updated_at: contact_message.updated_at
    }
  end
end
