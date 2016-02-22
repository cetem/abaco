module OutflowsHelper
  def link_to_operator(outflow)
    if (id = outflow.operator_id)
      link_to outflow.operator_name, operator_path(id)
    else
      '-'
    end
  end

  def kind_selector_for_outflow
    Outflow::KIND.except(:refunded).map do |k, v|
      [t("view.outflows.kind.#{k}"), v]
    end
  end

  def show_outflow_kind(outflow, link_to_kind = true)
    _path = if link_to_kind
              outflows_path(filter: outflow.kind_symbol)
            else
              outflow_path(outflow)
            end

    link_to t("view.outflows.kind.#{outflow.kind_symbol}"), _path
  end

  def convert_dates_to_interval(start, finish)
    [
      l(start.to_date, format: :long),
      l(finish.to_date, format: :long)
    ].join(' - ')
  end

  def hours_in_words(hours)
    seconds = hours * 3600.0

    distance_of_time_in_words(Time.zone.now, seconds.seconds.from_now)
  end

  def show_pay_shifts_button(id, start, finish, amount)
    link_args = [
      t('view.outflows.shifts.pay'),
      pay_shifts_outflows_path(
        operator_id: id, from: start.to_date, to: finish.to_date,
        total_to_pay: amount, upfronts: 0
      )
    ]
    replaceable_link = pay_shifts_outflows_path(
      operator_id: id, from: start.to_date, to: finish.to_date,
      total_to_pay: 'AMOUNT', upfronts: 'UPFRONTS',
      with_incentive: 'INCENTIVE'
    )

    link_options = {
      class: 'btn btn-primary',
      data: {
        method: :patch, remote: true, pay_shifts_button: true,
        disable_with: t('view.outflows.shifts.wait_paying'),
        replaceable_link: replaceable_link
      }
    }

    link_to *(link_args + [link_options])
  end

  def change_operator_field_errors(obj)
    obj.errors.add(:auto_operator_name, obj.errors[:operator_id].join(', '))
    obj.errors[:operator_id].clear
  end

  def show_start_and_finish_paid_shifts(outflow)
    [
      l(outflow.start_shift),
      l(outflow.finish_shift)
    ].join(' => ')
  end
end
