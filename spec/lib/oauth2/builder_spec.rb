# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Builder do
  let(:options) { { client_id: 'abc123', client_secret: 'secret', url: 'http://example.com' } }

  before { OAuth2::Configuration.instance.providers.clear }

  describe '.configure' do
    it 'creates a new instance of OAuth2::Builder' do
      expect(described_class).to receive(:new)
      described_class.configure {}
    end
  end

  describe '#initialize' do
    it { expect { |block| described_class.new(&block) }.to yield_control }
  end

  describe '#provider' do
    it 'adds the provider configuration to the providers hash' do
      opts = options.dup
      described_class.new { provider(:my_provider, **opts) }

      providers = OAuth2::Configuration.instance.providers
      expect(providers[:my_provider]).to eq(options)
    end

    it 'only allows specific options to be included in the provider configuration' do
      opts = options.dup
      opts[:invalid_option] = 'foo'
      described_class.new { provider(:my_provider, **opts)}

      providers = OAuth2::Configuration.instance.providers
      expect(providers[:my_provider]).to eq(options)
      expect(providers[:my_provider][:invalid_option]).to be_nil
    end
  end

  describe '#add_provider' do
    it 'adds the provider configuration to the providers hash' do
      opts = options.dup
      described_class.new.send(:add_provider, :my_provider, **opts)

      providers = OAuth2::Configuration.instance.providers
      expect(providers[:my_provider]).to eq(options)
    end
  end
end
