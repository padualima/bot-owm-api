# frozen_string_literal: true

module MockTwitterResponse
  def new_tweet_data(text=Faker::Lorem.sentence)
    {
      "data" => {
        "edit_history_tweet_ids"=>[SecureRandom.rand(100000..900000).to_s],
        "id"=>SecureRandom.rand(100000..900000).to_s,
        "text"=>text
      }
    }
  end
  module_function :new_tweet_data
end
