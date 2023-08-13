# frozen_string_literal: true

module V1
  class TweetsController < ApiController
    before_action :set_api_token

    def create
      return head :not_found unless @api_token

      input = tweet_params.to_h
      input[:location_name] = input.delete(:name) if input.key?(:name)

      Tweet::CreateWithWeatherInformation
        .call(**input, api_token: @api_token)
        .on_success { |result| render_json({ tweets: { text: result[:tweet].text } }) }
        .on_failure { |result| render_json(result[:message], :unprocessable_entity) }
    end

    private

    def set_api_token
      @api_token = ApiTokenEvent.by_valid.find_by(token: params[:token])
    end

    def tweet_params
      params.require(:location).permit(:lat, :lon, :name)
    end
  end
end
