# frozen_string_literal: true

module V1
  class TweetsController < ApiController
    def create
      input = tweet_params.to_h
      input[:location_name] = input.delete(:name) if input.key?(:name)

      # TODO: use serializer
      Tweet::CreateWithWeatherInformation
        .call(**input, api_token: @api_token)
        .on_success { |result| render_json({ tweets: { text: result[:tweet].text } }) }
        .on_failure { |result| render_json(result[:message], :unprocessable_entity) }
    end

    private

    def tweet_params
      params.require(:location).permit(:lat, :lon, :name)
    end
  end
end
