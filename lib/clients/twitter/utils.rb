# frozen_string_literal: true

module Clients
  module Twitter
    module Utils
      module PKCE
        def self.code_verifier = urlsafe_base64(SecureRandom.base64((rand(43..128) * 3) / 4))

        def self.code_challenge(code_verifier)
          urlsafe_base64(Digest::SHA256.base64digest(code_verifier))
        end

        private

        def self.urlsafe_base64(base64_str) = base64_str.tr("+/", "-_").tr("=", "")
      end
    end
  end
end
