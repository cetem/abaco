class Provider < ActiveRecord::Base
  has_paper_trail
  has_magick_columns name: :string

  validates :name, uniqueness: { message: :detailed_taken }

  has_many :outflows, dependent: :restrict_with_error

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

  def self.search(query)
    query.present? ? magick_search(query) : all
  end
end
