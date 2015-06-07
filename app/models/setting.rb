class Setting < ActiveRecord::Base
  has_paper_trail

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

  def self.price_for_admin
    find_by(var: 'pay_per_administrator_hour').value.to_f
  end

  def self.price_for_operator
    find_by(var: 'pay_per_operator_hour').value.to_f
  end
end
