module ReportsHelper
  def detailed_inventive_hours(incentive)
    [
      content_tag(:span, incentive.operator_hours, class: 'badge'),
      '+',
      content_tag(:span, incentive.admin_hours, class: 'badge badge-inverse'),
      '=',
      content_tag(:span, incentive.hours, class: 'badge badge-info')
    ].join(' ')
  end
end
