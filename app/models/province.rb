class Province < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :municipalities
  has_many :cases, through: :municipalities
  has_many :province_tallies

  default_scope { order(position: :asc) }

end
