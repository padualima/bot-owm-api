class RenameApiTokenEventToApiKey < ActiveRecord::Migration[7.0]
  def change
    rename_table :api_token_events, :api_keys
    rename_column :tweets, :api_token_event_id, :api_key_id
  end
end
