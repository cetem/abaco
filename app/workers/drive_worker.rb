class DriveWorker
  require 'gdrive'

  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(label, params)
    default_finish = '------'

    shifts = params['shifts']
    credits = params['credits']
    new_upfront = params['new_upfront']
    pay = params['pay']

    _yes = I18n.t('label.yes')
    _no = I18n.t('label.no')
    outflow_titles = [
      Outflow.human_attribute_name('id'),
      Outflow.human_attribute_name('kind'),
      Outflow.human_attribute_name('amount'),
      Outflow.human_attribute_name('bought_at')
    ]


    csv = []
    csv << [I18n.t('view.outflows.shifts.shifts_for', operator: label)]
    csv << [
      Outflow.human_attribute_name('id'),
      Outflow.human_attribute_name('start'),
      Outflow.human_attribute_name('finish'),
      Outflow.human_attribute_name('as_admin'),
      I18n.t('view.outflows.shifts.hours')
    ]

    shifts.each do |s|
      start = Time.parse(s['start'])
      finish_present = s['finish'].present?
      finish = finish_present ? Time.parse(s['finish']) : default_finish
      worked_hours = finish_present ? ((finish - start) / 3600).round(2) : 0

      csv << [
        s['id'],
        I18n.l(start, format: :report),
        finish_present ? I18n.l(finish, format: :report) : default_finish,
        s['as_admin'] ? _yes : _no,
        worked_hours
      ]
    end

    csv << []
    if credits
      csv << [I18n.t('view.outflows.credits_canceled')]
      csv << outflow_titles

      csv += credits
      csv << []
    end

    csv << outflow_titles
    csv << pay
    csv << []

    if new_upfront
      csv << [I18n.t('view.outflows.generated_credit')]
      csv << outflow_titles
      csv << new_upfront
    end

    GDrive.upload_spreadsheet(
      I18n.t('view.outflows.pay_detail_between', range: params['range']),
      csv,
      { label: label }
    )
  end
end
