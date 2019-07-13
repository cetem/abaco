class Operator < Account
  has_many :movements,
    -> { where(to_account_type: 'Operator') },
    foreign_key: :to_account_id

  # Override
  def balance
    movements.not_revoked.to_favor.sum(:amount) - movements.not_revoked.upfront.sum(:amount)
  end

  def self.import_workers(workers)
    workers.map do |worker|
      operator = Operator.find_or_initialize_by(id: worker['abaco_id'])
      operator.name = worker['label']
      operator.save

      operator if operator.previous_changes['id']
    end.compact
  end
end
