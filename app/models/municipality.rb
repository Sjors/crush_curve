class Municipality < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :province
  has_many :cases, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy

  default_scope { order(position: :asc) }

  def as_json(options = nil)
    super({ only: [:id, :slug] }.merge(options || {})).merge({
      name: name,
      short_name: name.truncate(10)
    })
  end
end
