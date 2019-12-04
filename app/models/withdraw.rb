class Withdraw
  # Esta clase solo sirve para representar datos
  REDIS_TABLE = 'shared:pending_withdraws'

  def self.all
    ::Redis.new.hgetall(REDIS_TABLE).map do |id, raw_data|
      build_from_redis id, raw_data
    end.sort_by { |w| w.collected_at }
  end

  def self.build_movement(withdraw_id, user_id)
    raw_data = ::Redis.new.hget(REDIS_TABLE, withdraw_id)

    return Movement.new unless raw_data

    withdraw = build_from_redis withdraw_id, raw_data

    Movement.new(
      withdraw_id:     withdraw.id,
      kind:            :withdraw,
      amount:          withdraw.amount,
      to_account_type: Box.name,
      to_account_id:   Box.default_cashbox.first.id,
      bought_at:       Date.today,
      charged_by:      withdraw.charged_by,
      user_id:         user_id,
      comment:         I18n.t(
        'view.withdraws.comment_for_movement',
        time: I18n.l(withdraw.collected_at)
      )
    )
  end

  def self.create_movement(withdraw_id, user_id)
    movement = build_movement(withdraw_id, user_id)

    movement.save

    movement
  end

  def self.delete_withdraw(withdraw_id)
    Redis.new.hdel(REDIS_TABLE, withdraw_id)
  end

  private

  def self.build_from_redis(id, raw_data)
    data = JSON.parse(raw_data)

    OpenStruct.new(
      id:           id,
      charged_by:   data['user'],
      amount:       data['amount'].to_f,
      collected_at: Time.at(data['collected_at'])
    )
  end
end
