# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Utils do
  describe '.filter_hash_by_keys' do
    it 'returns hash filtered by allowed keys' do
      subject = described_class
        .filter_hash_by_keys({ opts_a: '1234', opts_b: '5678' }, %i[opts_a])

      expect(subject).to eq({ opts_a: '1234' })
    end

    it 'returns empty hash if `opts` is an empty Hash' do
      subject = described_class.filter_hash_by_keys({}, %i[opts_a])

      expect(subject).to eq({})
      expect(subject).to be_empty
    end

    it 'returns empty hash if not defined `allowed_keys`' do
      opts = { opts_a: '1234', opts_b: '5678' }

      subject = described_class.filter_hash_by_keys(opts)

      expect(subject).to eq({})
      expect(subject).to be_empty
    end
  end

  describe '.stringify_hash_keys' do
    let(:params) { { param_1: '1234', param_2: '5678' } }

    subject { described_class.stringify_hash_keys(params) }

    it 'returns with transform keys' do
      expect(subject).to eq(params.transform_keys(&:to_s))
    end
  end

  describe '.symbolize_hash_keys' do
    let(:params) { { 'param_1' => '1234', 'param_2' => '5678' } }

    subject { described_class.symbolize_hash_keys(params) }

    it 'returns with transform keys' do
      expect(subject).to eq(params.transform_keys(&:to_sym))
    end
  end

  describe '#build_oauth2_client' do
    let(:provider) { :twitter }
    let(:provider_opts) do
      {
        client_id: 'example_client_id',
        client_secret: 'example_client_secret',
        authorize_url: 'example_authorize_url',
        token_url: 'example_token_url'
      }
    end
    let(:configuration_instance) { instance_double(OAuth2::Configuration, providers: { provider.to_sym => provider_opts }) }

    before do
      allow(OAuth2::Configuration).to receive(:instance).and_return(configuration_instance)
    end

    it 'returns an instance of OAuth2::Client' do
      client = described_class.build_oauth2_client(provider)
      expect(client).to be_an_instance_of(OAuth2::Client)
    end

    it 'sets the correct client_id and client_secret' do
      client = described_class.build_oauth2_client(provider)
      expect(client.id).to eq(provider_opts[:client_id])
      expect(client.secret).to eq(provider_opts[:client_secret])
    end

    it 'sets the provider options correctly' do
      client = described_class.build_oauth2_client(provider)
      expect(client.options[:authorize_url]).to eq(provider_opts[:authorize_url])
      expect(client.options[:token_url]).to eq(provider_opts[:token_url])
    end

    it 'does not modify the original provider_opts' do
      described_class.build_oauth2_client(provider)
      expect(provider_opts).to eq({
        client_id: 'example_client_id',
        client_secret: 'example_client_secret',
        authorize_url: 'example_authorize_url',
        token_url: 'example_token_url'
      })
    end
  end
end
