class ReportsController < ApplicationController
  before_action :authenticate_user!

  def monthly_info
    if params[:reports] && (date = params[:reports][:date]).present?
      date = Date.parse(date)
      csv = Outflow.to_monthly_info(date)
      filename = [
        'Movements-Reports-for-',
        I18n.l(date, format: :to_month),
        '.csv'
      ].join

      send_data csv, filename: filename, type: 'text/csv'
    end
  end

  def incentives_between
    if (report_dates = params[:reports])
      start, finish = parameterize_to_date_format(report_dates)

      incentives = OperatorShifts.get(
        :best_fortnights_between,
        parameterize_to_date_format(report_dates)
      )
      price_for_admin = Setting.price_for_admin
      price_for_operator = Setting.price_for_operator

      @incentives = incentives.map do |incentive|
        between = incentive['between']
        worked_between = parameterize_to_date_format(
          from: between[0], to: between[1]
        )

        admin_hours = incentive['worked_data']['admin'].to_f
        operator_hours = incentive['worked_data']['operator'].to_f

        to_pay = (
          admin_hours * price_for_admin +
          operator_hours * price_for_operator
        ).round(2)


        OpenStruct.new(
          user: incentive['user']['label'],
          worked_from: worked_between[:from],
          hours: incentive['total_hours'],
          operator_hours: incentive['worked_data']['operator'].to_f,
          admin_hours: incentive['worked_data']['admin'].to_f,
          to_pay: to_pay
        )
      end
    end
  end
end
