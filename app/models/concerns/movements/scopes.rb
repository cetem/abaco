module Movements::Scopes
  extend ActiveSupport::Concern

  included do
    scope :not_revoked, -> { where(revoked: false) }
    scope :credits, -> { where(kind: kinds.slice(:upfront, :to_favor).values) }
    scope :to_operators, -> { where(
      "(#{table_name}.to_account_type = 'Operator' AND #{table_name}.to_account_id IS NOT NULL)"
    ) }
    scope :for_operator, -> (operator) { where(to_account_type: 'Operator', to_account_id: operator) }
    scope :for_provider, -> (provider) { where(to_account_type: 'Provider', to_account_id: provider) }
    scope :filtered_by, -> (q) { q.present? ? where(kind: kinds[q]) : all }
    scope :at_month, -> (date) { where(bought_at: date.beginning_of_month..date.end_of_month) }
  end
end
