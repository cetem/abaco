class ExportWorker
  require 'gdrive'

  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(task_name, params)
    case task_name
      when Movement::MonthlyReport
        date = Date.parse(params['date'])
        Gdrive.upload_spreadsheet_v3(
          I18n.t('view.movements.monthly_by_year', year: date.year),
          Movement.to_monthly_info(date),
          { month: date.month }
        )
    end
  end
end
