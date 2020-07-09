class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :municipality, null: false, foreign_key: true
      t.references :safari_subscription, null: false, foreign_key: true

      t.timestamps
    end
  end
end
