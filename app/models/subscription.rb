class Subscription < ApplicationRecord
  belongs_to :municipality
  belongs_to :safari_subscription

  def notify(title, body, url_args)
    if safari_subscription
      safari_subscription.notify(title, body, url_args)
    end
  end

end
