class Outflow < ActiveRecord::Base
  has_paper_trail
  
  # Constantes
  KIND = {
    withdraw: 'w',
    upfront: 'u',
    maintenance: 'm',
    other: 'o'
  }.with_indifferent_access.freeze
  
  # Atributos permitidos
  attr_accessible :amount, :comment, :kind, :lock_version, :operator_id,
    :auto_operator_name, :user_id
  
  # Attributos no persistentes
  attr_accessor :auto_operator_name
  
  # Validaciones
  validates :amount, :kind, :user_id, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :operator_id, presence: true, if: :kind_is_upfront?
  validates :comment, presence: true, if: :kind_is_other?
  
  # Relaciones
  belongs_to :user

  ['upfront', 'other'].each do |kind|
    define_method("kind_is_#{kind}?") do
      self.kind == KIND[kind.to_sym]
    end
  end
  
  def kind_symbol
    KIND.invert[self.kind]
  end
end
