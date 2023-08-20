# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuth2::Configuration do
  let(:options) { { client_id: 'abc123', client_secret: 'secret', url: 'http://example.com' } }

  before { described_class.instance.providers.clear }

  describe '#initialize' do
    it 'initializes with an empty providers hash' do
      expect(described_class.instance.providers).to eq({})
    end
  end

  describe '#providers' do
    it 'returns the providers hash' do
      config = described_class.instance

      expect(config.providers).to eq({})

      config.providers[:my_provider] = options

      expect(config.providers).to eq({ my_provider: options })
    end
  end

  describe '.instance' do
    it 'returns the same instance of the configuration' do
      config1 = described_class.instance
      config2 = described_class.instance

      expect(config1).to be(config2)
    end
  end
end
