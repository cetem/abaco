class ReportsController < ApplicationController
  before_action :authenticate_user!

  def monthly_info
    if params[:reports] && (date = params[:reports][:date]).present?
      date = Time.parse(date)
      csv = Outflow.to_monthly_info(date)
      filename = [
        'Movements-Reports-for-',
        I18n.l(date, format: :to_month),
        '.csv'
      ].join

      send_data csv, filename: filename, type: 'text/csv'
    end
  end
end
