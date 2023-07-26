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
end
