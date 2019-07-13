module Users::Search
  extend ActiveSupport::Concern

  included do
    include PgSearch

    pg_search_scope :unicode_search,
      against: [:name, :lastname, :email],
      ignoring: :accents,
      using: {
        tsearch: { prefix: false },
        trigram: { threshold: 0.5 }
      }
  end

  module ClassMethods
    def filtered_list(query)
      query.present? ? unicode_search(query) : all
    end
  end
end
