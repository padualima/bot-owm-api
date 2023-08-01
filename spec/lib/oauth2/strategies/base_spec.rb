# frozen_string_literal: true

require 'rails_helper'
require 'oauth2/strategies/base'

RSpec.describe OAuth2::Strategies::Base do
  let(:client) { double('OAuth2::Client') }
  let(:strategy) { described_class.new(client) }

  describe '#initialize' do
    it 'sets the client instance variable' do
      expect(strategy.instance_variable_get(:@client)).to eq(client)
    end
  end

  describe '#client' do
    it 'returns the client instance variable' do
      expect(strategy.client).to eq(client)
    end
  end
end
