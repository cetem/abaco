class Setting < ActiveRecord::Base
  has_paper_trail

  # Atributos accesibles
  attr_accessible :lock_version, :value, :var, :title

  # Callbacks
  before_save :assign_var_from_title
  
  # Validations
  validates :title, :value, presence: true
  validates :var, uniqueness: true

  def to_s
    self.title
  end

  def assign_var_from_title
    self.var = self.title.downcase.split.join('_')
  end
end
