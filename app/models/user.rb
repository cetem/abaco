class User < ActiveRecord::Base
  include Users::MagickColumns
  include Users::Roles
  
  has_paper_trail
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
    :validatable

  # Default order
  default_scope { order("#{table_name}.lastname ASC") }
  
  # Validations
  validates :name, presence: true
  validates :name, :lastname, :email, length: { maximum: 255 }, allow_nil: true,
    allow_blank: true
  
  # Relaciones
  has_many :outflows
  
  def initialize(attributes = nil, options = {})
    super(attributes)
    
    self.role ||= :regular
  end
  
  def to_s
    [self.name, self.lastname].compact.join(' ')
  end
  
  def role
    self.roles.first.try(:to_sym)
  end
  
  def role=(role)
    self.roles = [role]
  end
  
  def self.filtered_list(query)
    query.present? ? magick_search(query) : all
  end
end
