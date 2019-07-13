module MovementsHelper
  def accounts_prefixes
    @accounts_prefixes ||= {
      'Provider' => '(P)',
      'Operator' => '(O)',
      'Box' => '(C)'
    }
  end

  def link_to_account(account)
    if account
      text = [
        accounts_prefixes[account.type],
        account
      ].join(' ')[0..25]

      link_to(
        text,
        account,
        title: account.class.model_name.human,
        data: {
          show_tooltip: true
        }
      )
    end
  end

  def kind_selector_for_movement
    Movement.kinds.except(:refunded, :upfront_r, :to_favor_r).keys.map do |k|
      [t("view.movements.kind.#{k}"), k]
    end
  end

  def show_movement_kind(movement, link_to_kind = true)
    _path = if link_to_kind
              movements_path(filter: movement.kind)
            else
              movement_path(movement)
            end

    link_to t("view.movements.kind.#{movement.kind}"), _path
  end

  def convert_dates_to_interval(start, finish)
    [
      l(start.to_date, format: :long),
      l(finish.to_date, format: :long)
    ].join(' - ')
  end

  def hours_in_words(hours)
    return '-' if hours.zero?
    seconds = hours * 3600.0

    distance_of_time_in_words(Time.zone.now, seconds.seconds.from_now)
  end

  def show_pay_shifts_button(id, start, finish, amount)
    link_args = [
      t('view.movements.shifts.pay'),
      pay_shifts_movements_path(
        operator_id: id, from: start.to_date, to: finish.to_date,
        total_to_pay: amount, upfronts: 0
      )
    ]
    replaceable_link = pay_shifts_movements_path(
      operator_id: id, from: start.to_date, to: finish.to_date,
      total_to_pay: 'AMOUNT', upfronts: 'UPFRONTS',
      with_incentive: 'INCENTIVE'
    )

    link_options = {
      class: 'btn btn-primary',
      data: {
        method: :patch, remote: true, pay_shifts_button: true,
        disable_with: t('view.movements.shifts.wait_paying'),
        replaceable_link: replaceable_link
      }
    }

    link_to *(link_args + [link_options])
  end

  def show_start_and_finish_paid_shifts(movement)
    [
      l(movement.start_shift),
      l(movement.finish_shift)
    ].join(' => ')
  end

  def retroactive_amount(shifts, operator_diff, admin_diff)
    shifts.operator.hours.to_f  * operator_diff.abs +
      shifts.admin.hours.to_f  * admin_diff.abs
  end

  def count_with_hours(data)
    "(#{data.count.to_i}) #{hours_in_words(data.hours.to_f)}"
  end

  def show_movement_account(way, movement)
    account = movement.send("#{way}_account")
    return unless account

    link_to(
      [account.class.model_name.human, account].join(': '),
      account
    )
  end

  def movement_account_types(selected_type=nil)
    @account_types ||= begin
                         desc = ::Account.descendants
                         desc = [Operator, Provider, Box] if desc.empty?
                         desc
                       end

    @account_types.map do |klass|
      disabled = selected_type.present? && selected_type != klass.to_s
      [klass.model_name.human, klass.to_s, disabled: disabled]
    end
  end
end
