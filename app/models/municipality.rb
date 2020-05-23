class Municipality < ApplicationRecord
  belongs_to :province
  has_many :cases
end
