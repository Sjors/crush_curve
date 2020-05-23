class Province < ApplicationRecord
  has_many :municipalities
  has_many :cases, through: :municipalities
end
