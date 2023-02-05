class CreateApiTokenEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :api_token_events do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :token_type, null: false
      t.datetime :expires_in, null: false
      t.string :access_token, null: false
      t.string :scope, null: false
      t.string :refresh_token
      t.string :token, null: false

      t.timestamps
    end
  end
end
