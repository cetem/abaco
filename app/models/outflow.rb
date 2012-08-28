class Outflow < ActiveRecord::Base
  has_paper_trail
  
  # Constantes
  KIND = {
    upfront: 'u',
    refunded: 'r',
    maintenance: 'm',
    purchase: 'p',
    other: 'o'
  }.with_indifferent_access.freeze
  
  scope :upfronts, where(kind: KIND[:upfront])
  
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

  def self.operator_pay_pending_shifts_between(options = {})
    shifts = OperatorShifts.find(:all, params: { 
      user_pay_pending_shifts_between: {
        user: options[:operator_id],
        start: options[:start],
        finish: options[:finish]
      }
    })
    
    if shifts.size > 0
      start, finish = shifts.first.created_at, shifts.last.created_at
      worked_hours = worked_hours(shifts)
      to_pay = calculate_how_much_money_have_to_pay(
        worked_hours, options[:admin]
      )
      
      {
        hours: worked_hours,
        earns: to_pay,
        count: shifts.size,
        start: start,
        finish: finish
      }
    end
  end

  def refund!
    self.update_attributes(kind: KIND[:refunded])
  end
  
  def self.pay_operator_shifts_and_upfronts(options = {})
    Operator.find(options[:operator_id]).put(
      :pay_shifts_between, start: options[:start], finish: options[:finish]
    )
    
    upfronts.where(operator_id: options[:operator_id]).all?(&:refund!)
  end

  def self.calculate_how_much_money_have_to_pay(hours, admin)
    admin = admin.to_bool if admin.kind_of? String
    operator_type = admin ? 
      'pay_per_administrator_hour' : 
      'pay_per_operator_hour'
    pay_per_hour = Setting.find_by_var(operator_type).value.to_f

    hours * pay_per_hour
  end

  def self.worked_hours(shifts)
    hours = 0
    shifts.map { |s| hours += s.finish.to_time - s.start.to_time } 

    hours / 3600
  end
end
