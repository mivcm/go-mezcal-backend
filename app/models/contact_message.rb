class ContactMessage < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { minimum: 5, maximum: 200 }
  validates :message, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :phone, length: { maximum: 20 }, allow_blank: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read: false) }

  # Instance methods
  def mark_as_read!
    update!(read: true)
  end

  def full_name
    name
  end

  def display_phone
    phone.present? ? phone : 'No proporcionado'
  end

  def short_message
    message.length > 100 ? "#{message[0..97]}..." : message
  end
end
