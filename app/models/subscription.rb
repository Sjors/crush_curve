class Subscription < ApplicationRecord
  belongs_to :municipality
  belongs_to :safari_subscription
end
