class AddRemoteOperatorsToOperators < ActiveRecord::Migration[4.2]
  def change
    if ENV['TRAVIS'] ||
       Operator.columns.find {|e| e.name == 'id' }.type == :integer

      return true
    end

    workers = RemoteOperator.get(:current_workers)
    missing_operator_id = Movement.unscoped.where.not(operator_id: nil).distinct.pluck(:operator_id)

    (
      missing_operator_id -
      workers.map { |c_w| c_w['id'] }
    ).uniq.each do |user_id|
      workers << RemoteOperator.find(user_id).attributes
    end

    workers.each do |user|
      Operator.create(
        id:   user['abaco_id'],
        name: user['label']
      )

      Movement.where(
        operator_id: user['id']
      ).update_all(
        to_account_id:   operator.id,
        to_account_type: Operator.name
      )
    end
  end
end
