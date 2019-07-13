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
    movement_titles = [
      Movement.human_attribute_name('id'),
      Movement.human_attribute_name('kind'),
      Movement.human_attribute_name('amount'),
      Movement.human_attribute_name('bought_at')
    ]


    csv = []
    csv << [I18n.t('view.movements.shifts.shifts_for', operator: label)]
    csv << [
      Movement.human_attribute_name('id'),
      Movement.human_attribute_name('start'),
      Movement.human_attribute_name('finish'),
      Movement.human_attribute_name('as_admin'),
      I18n.t('view.movements.shifts.hours')
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
      csv << [I18n.t('view.movements.credits_canceled')]
      csv << movement_titles

      csv += credits
      csv << []
    end

    csv << movement_titles
    csv << pay
    csv << []

    if new_upfront
      csv << [I18n.t('view.movements.generated_credit')]
      csv << movement_titles
      csv << new_upfront
    end

    GDrive.upload_spreadsheet_v3(
      I18n.t('view.movements.pay_detail_between', range: params['range']),
      csv,
      { label: label }
    )
  end
end
