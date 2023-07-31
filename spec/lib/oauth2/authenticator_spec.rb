# frozen_string_literal: true

require 'spec_helper'
require 'oauth2/authenticator'

RSpec.describe OAuth2::Authenticator do
  let(:id) { 'client_id' }
  let(:secret) { 'client_secret' }
  let(:mode) { :basic_auth }
  let(:authenticator) { described_class.new(id, secret, mode) }

  describe '#initialize' do
    it 'raises an ArgumentError if id is missing' do
      expect { described_class.new(nil, secret, mode) }
        .to raise_error(ArgumentError, /The attribute `id` is missing./)
    end

    it 'raises an ArgumentError if secret is missing' do
      expect { described_class.new(id, nil, mode) }
        .to raise_error(ArgumentError, /The attribute `secret` is missing./)
    end

    it 'raises an ArgumentError if mode is missing' do
      expect { described_class.new(id, secret, nil) }
        .to raise_error(ArgumentError, /The attribute `mode` is missing./)
    end

    it 'creates an instance with valid attributes' do
      expect { authenticator }.not_to raise_error
    end
  end

  describe '#apply!' do
    let(:params) { {} }
    let(:headers) { {} }

    context 'when mode is :basic_auth' do
      it 'applies basic authentication to headers' do
        authenticator.apply!(params, headers)
        expect(headers['Authorization'])
          .to eq("Basic #{Base64.urlsafe_encode64("#{id}:#{secret}")}")
      end
    end

    context 'when mode is not :basic_auth' do
      let(:mode) { :invalid_mode }

      it 'raises NotImplementedError' do
        expect { authenticator.apply!(params, headers) }.to raise_error(NotImplementedError)
      end
    end
  end
end
