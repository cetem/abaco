module Movements::Callbacks
  extend ActiveSupport::Concern

  included do
    before_validation do
      if self.to_account.present?
        self.to_account_id = self.to_account.id if to_account_id.blank?
        self.to_account_type = self.to_account.class.name if to_account_type.blank?
      end

      if self.from_account.present?
        self.from_account_id = self.from_account.id if from_account_id.blank?
        self.from_account_type = self.from_account.class.name if from_account_type.blank?
      end
    end

    after_commit on: :create do
      if with_receipt.to_bool && to_account.present?
        Movement.create!(
          from_account: to_account,
          amount:       amount,
          user_id:      user_id,
          bought_at:    bought_at,
          kind:         :receipt,
          comment:      I18n.t(
            'view.movements.receipt_of',
            id: self.id,
            path: Rails.application.routes.url_helpers.movement_path(self.id),
            kind: I18n.t('view.movements.kind.' + kind.to_s)
          )
        )
      end
    end

    after_commit on: :create, if: ->(m) { m.withdraw_id.present? } do
      Withdraw.delete_withdraw(withdraw_id)
    end
  end
end
