module Movements::Shifts
  extend ActiveSupport::Concern

  class_methods do
    def shifts_info(shifts)
      operator = shifts['operator']
      operator_hours = operator ? operator['hours'].to_f : 0.0
      admin = shifts['admin']
      admin_hours = admin ? admin['hours'].to_f : 0.0
      hours = operator_hours + admin_hours

      _count = (
        (operator ? operator['count'].to_i : 0) +
        (admin ? admin['count'].to_i : 0)
      )
      amount = (
        operator_hours * Setting.price_for_operator +
        admin_hours * Setting.price_for_admin
      ).round(2)

      suspicious_shifts = operator['suspicious_shifts'] if operator
      if !suspicious_shifts && admin
        suspicious_shifts = admin['suspicious_shifts']
      end

      OpenStruct.new(
        hours: hours, amount: amount, count: _count,
        suspicious_shifts: suspicious_shifts
      )
    end

    def operators_pay_pending_shifts_between(start, finish)
      data = RemoteOperator.get(
        :pay_pending_shifts_for_active_users_between,
        start: start, finish: finish
      )

      data.map do |user_data|
        user = user_data['user']
        _shifts_info = shifts_info(user_data['shifts'])

        OpenStruct.new(
          operator: OpenStruct.new(
            id: user['abaco_id'],
            label: user['label'],
            credit: credit_for_operator(user['abaco_id'])
          ),
          shifts: _shifts_info
        )
      end
    end

    def operators_shifts_between(start, finish)
      data = RemoteOperator.get(
        :shifts_between,
        start: start, finish: finish
      )

      data.map do |user_data|
        user = user_data['user']

        OpenStruct.new(
          operator: OpenStruct.new(user_data['user']),
          shifts:   OpenStruct.new(
            operator: OpenStruct.new(user_data['shifts']['operator']),
            admin:    OpenStruct.new(user_data['shifts']['admin'])
          )
        )
      end
    end


    def pay_operator_shifts_and_upfronts(options = {})
      Movement.transaction do
        begin
          operator_id = options[:operator_id]

          credits = Movement.credits.for_operator(operator_id)
          credits_info = credits.map(&:to_info)
          raise unless credits.all?(&:refund!)

          pay = Movement.create!(
            kind:              :payoff,
            start_shift:       options[:start].to_date,
            finish_shift:      options[:finish].to_date,
            amount:            options[:amount].to_f.abs,
            user_id:           options[:user_id],
            from_account_type: Box.name,
            from_account_id:   Box.default_cashbox.first.id,
            to_account_type:   Operator.name,
            to_account_id:     operator_id,
            with_incentive:    options[:with_incentive],
            bought_at:         Date.today,
            charged_by:        options[:charged_by]
          )

          upfront = options[:upfronts].to_f

          new_upfront = nil
          if !upfront.zero? && !options[:with_incentive]
            comment = I18n.t(
              'view.movements.reajust_of',
              id: pay.id,
              path: Rails.application.routes.url_helpers.movement_path(pay)
            )
            new_upfront = Movement.create!(
              kind:            (upfront < 0 ? :to_favor : :upfront),
              amount:          upfront.abs,
              comment:         comment,
              user_id:         options[:user_id],
              to_account_type: 'Operator',
              to_account_id:   operator_id,
              bought_at:       Date.today,
              charged_by:      options[:charged_by]
            )
          end

          shifts_response = RemoteOperator.find(operator_id).patch(
            :pay_shifts_between, start: options[:start], finish: options[:finish]
          )
          shifts = JSON.load(shifts_response.body)

          DriveWorker.perform_async(
            pay.to_account.to_s,
            {
              shifts: shifts,
              credits: credits_info,
              new_upfront: new_upfront.try(:to_info),
              pay: pay.to_info,
              range: [options[:start].to_date, options[:finish].to_date].join(' => ')
            }
          )
          true
        rescue => e
          ::Bugsnag.notify(e)
          puts e, e.backtrace if ENV['TRAVIS']

          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
