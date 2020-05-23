class Municipality < ApplicationRecord
  belongs_to :province
  has_many :cases

  default_scope { order(position: :asc) }

  def as_json(options = nil)
    super({ only: [:id] }.merge(options || {})).merge({
      name: name,
      short_name: name.truncate(10)
    })
  end
end
