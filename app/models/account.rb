class Account < ActiveRecord::Base
  include PgSearch::Model

  has_paper_trail

  pg_search_scope :unicode_search,
    against: [:name],
    ignoring: :accents,
    using: {
      tsearch: { prefix: false },
      trigram: { threshold: 0.2 }
    }

  validates :name, uniqueness: { message: :detailed_taken }
  validates :name, presence: true

  enum multi_use: {
    default_cashbox: 'default_cashbox'
  }

  has_many :transactions

  def to_s
    name
  end
  alias :label :to_s

  def as_json(options = {})
    default_options = {
      only: [:id],
      methods: [:label]
    }

    super(default_options.merge(options || {}))
  end

  def balance
    transactions.not_revoked.credit.sum(:amount) - transactions.not_revoked.debit.sum(:amount)
  end

  def self.search(query)
    query.present? ? unicode_search(query) : all
  end
end
