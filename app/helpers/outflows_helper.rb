module OutflowsHelper
  
  def kind_selector_for_outflow
    Outflow::KIND.except(:refunded).map do |k, v|
      [t("view.outflows.kind.#{k}"), v]
    end
  end
  
  def show_outflow_kind(outflow)
    t("view.outflows.kind.#{outflow.kind_symbol}")
  end

  def convert_dates_to_interval(start, finish)
    output = l(start.to_date, format: :long)
    output << ' - '
    output << l(finish.to_date, format: :long)
    
    output
  end
  
  def get_operator_upfronts
    @operator_upfronts ? @operator_upfronts.sum(&:amount) : 0
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
    hours = seconds_to_rounded_time(seconds, 15.minutes) / 3600
    minutes = (hours - hours.to_i) * 60
    
    t('related_hours', hours: hours.to_i, minutes: minutes.to_i) 
  end
    
  def show_pay_shifts_link(id, start, finish)
    link_args = [
      t('view.outflows.shifts.pay'),
      pay_shifts_outflows_path(
        id: id, from: start.to_date, to: finish.to_date
      )
    ]
    link_options = { method: :put, class: 'btn btn-primary' }

    if @total >= 0
      link_to *(link_args + [link_options])
    else
      link_to *(link_args + [link_options.merge(
        data: { confirm: t('view.outflows.shifts.confirm') }
      )])
    end
  end
end
