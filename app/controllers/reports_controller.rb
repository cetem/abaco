class ReportsController < ApplicationController
  before_action :authenticate_user!

  def monthly_info
    require 'gdrive'

    if params[:reports] && (date = params[:reports][:date]).present?
      date = Date.parse(date)

      GDrive.upload_spreadsheet(
        I18n.t('view.outflows.monthly_by_year', year: date.year),
        Outflow.to_monthly_info(date),
        { month: date.month }
      )
      render :monthly_info, notice: ':+1:'
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

  def retroactive_between
    @operator_amount = Setting.price_for_operator
    @admin_amount = Setting.price_for_admin

    if params[:interval]
      interval = params[:interval]
      start, finish = [interval[:from], interval[:to]].sort

      if start.present? && finish.present?
        @new_operator_amount = interval[:operator_amount].to_f
        @new_admin_amount = interval[:admin_amount].to_f
        @operators_shifts = Outflow.operators_shifts_between(start, finish)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
