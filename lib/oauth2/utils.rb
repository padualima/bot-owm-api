# frozen_string_literal: true

module OAuth2
  module Utils
    extend self

    def filter_hash_by_keys(opts = {}, allowed_keys = [])
      return opts unless opts.any?

      opts.select { |key, _| key.in?(allowed_keys) }
    end

    def stringify_hash_keys(params = {})
      params.transform_keys(&:to_s)
    end

    def symbolize_hash_keys(params = {})
      params.transform_keys(&:to_sym)
    end
  end
end
