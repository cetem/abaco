class Transaction < ActiveRecord::Base
  has_paper_trail

  belongs_to :account
  belongs_to :movement

  scope :not_revoked, -> { where(revoked: false) }

  enum kind: %i[credit debit]

  def revoke!
    update!(revoked: true)
  end
end
