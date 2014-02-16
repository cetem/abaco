module OutflowsHelper

  def kind_selector_for_outflow
    Outflow::KIND.except(:refunded).map do |k, v|
      [t("view.outflows.kind.#{k}"), v]
    end
  end

  def show_outflow_kind(outflow)
    link_to t("view.outflows.kind.#{outflow.kind_symbol}"),
      outflows_path(filter: outflow.kind_symbol)
  end

  def convert_dates_to_interval(start, finish)
    output = l(start.to_date, format: :long)
    output << ' - '
    output << l(finish.to_date, format: :long)

    output
  end

  def seconds_to_rounded_time(seconds, rounded_in_seconds)
    hours_part = 60 / (rounded_in_seconds.to_f / 60)
    worked_hours = seconds.to_f / 3600
    hours = worked_hours.truncate
    minutes = ((worked_hours - hours) * hours_part).round * rounded_in_seconds

    if minutes == 60
      hours += 1
      minutes = 0
    end

    hours += minutes.to_f / 3600

    hours.round(2).hours
  end

  def hours_in_words(hours)
    seconds = hours * 3600
    hours = seconds_to_rounded_time(seconds, 1.minute) / 3600
    minutes = (hours - hours.to_i) * 60

    t('related_hours', hours: hours.to_i, minutes: minutes.to_i)
  end

  def show_pay_shifts_button(id, start, finish, amount)
    link_args = [
      t('view.outflows.shifts.pay'),
      pay_shifts_outflows_path(
        id: id, from: start.to_date, to: finish.to_date,
        total_to_pay: amount, upfronts: 0
      )
    ]
    link_options = { class: 'btn btn-primary',
      data: { method: :patch, remote: true, pay_shifts_button: true,
      disable_with: t('view.outflows.shifts.wait_paying') } }

    link_to *(link_args + [link_options])
  end

  def change_operator_field_errors(obj)
    obj.errors.add(:auto_operator_name, obj.errors[:operator_id].join(', '))
    obj.errors[:operator_id].clear
  end
end
