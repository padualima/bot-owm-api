# frozen_string_literal: true

require 'rails_helper'
require 'oauth2/pkce_generator'

RSpec.describe OAuth2::PKCEGenerator do
  describe '#code_verifier' do
    it 'generates a code verifier' do
      code_verifier = described_class.code_verifier
      expect(code_verifier).to match(/\A[a-zA-Z0-9_-]{43,128}\z/)
    end

    it 'generates different code verifiers each time' do
      code_verifier1 = described_class.code_verifier
      code_verifier2 = described_class.code_verifier
      expect(code_verifier1).not_to eq(code_verifier2)
    end
  end

  describe '#code_challenge' do
    it 'generates a code challenge from a code verifier' do
      code_verifier = 'example_code_verifier'
      expected_code_challenge =
        Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier)).tr("=", "")
      code_challenge = described_class.code_challenge(code_verifier)
      expect(code_challenge).to eq(expected_code_challenge)
    end
  end

  describe '#urlsafe_base64' do
    it 'encodes Base64 string to URL-safe Base64' do
      base64_str = "abc+/="
      expected_urlsafe_base64 = "abc-_"
      urlsafe_base64 = described_class.send(:urlsafe_base64, base64_str)
      expect(urlsafe_base64).to eq(expected_urlsafe_base64)
    end
  end
end
