class ExportWorker
  require 'gdrive'

  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(task_name, params)
    case task_name
      when Outflow::MonthlyReport
        date = Date.parse(params['date'])
        GDrive.upload_spreadsheet(
          I18n.t('view.outflows.monthly_by_year', year: date.year),
          Outflow.to_monthly_info(date),
          { month: date.month }
        )
    end
  end
end
