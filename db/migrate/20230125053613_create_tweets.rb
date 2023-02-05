class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :api_token_event, null: false, foreign_key: true
      t.string :uid, null: false
      t.string :text, null: false

      t.timestamps
    end
  end
end
