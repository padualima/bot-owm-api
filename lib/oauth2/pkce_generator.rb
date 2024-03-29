# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'digest'

module OAuth2
  module PKCEGenerator
    extend self

    def code_verifier = urlsafe_base64(SecureRandom.base64((rand(43..128) * 3) / 4))

    def code_challenge(code_verifier)
      urlsafe_base64(Digest::SHA256.base64digest(code_verifier))
    end

    private

    def urlsafe_base64(base64_str) = base64_str.tr("+/", "-_").tr("=", "")
  end
end
