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

  def cancelled(day)
    cbs_id == "GM1979" && day.to_date < Date.new(2021,1,7) ||
    ["GM0003", "GM0010", "GM0024", "GM0788"].include?(cbs_id) && day.to_date >= Date.new(2021,1,7) ||
    ["GM0824", "GM0865", "GM0757", "GM0855"].include?(cbs_id) && day.to_date == Date.new(2021,1,7)
  end
end
