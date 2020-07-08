class CreateSafariSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :safari_subscriptions do |t|
      t.string :device_token, null: true
      t.string :auth_token, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
