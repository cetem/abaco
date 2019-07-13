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
  end
end
