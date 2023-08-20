# frozen_string_literal: true

require 'base64'

module OAuth2
  class Authenticator
    attr_reader :id, :secret, :mode

    def initialize(id, secret, mode)
      @id = id
      @secret = secret
      @mode = mode

      validate_attributes
    end

    def validate_attributes
      { id: id, secret: secret, mode: mode }.each do |key, value|
        raise ArgumentError, "The attribute `#{key}` is missing." unless value
      end
    end

    def apply!(params, headers)
      case mode.to_sym
      when :basic_auth
        apply_basic_auth(headers)
      else
        raise NotImplementedError
      end
    end

    private

    def apply_basic_auth(headers)
      headers.merge!(basic_auth_header)
    end

    def encode_basic_token = "Basic #{Base64.urlsafe_encode64("#{id}:#{secret}")}"

    def basic_auth_header
      { 'Authorization' => encode_basic_token }
    end
  end
end
