class Province < ApplicationRecord
  has_many :municipalities
  has_many :cases, through: :municipalities

  default_scope { order(position: :asc) }
end
