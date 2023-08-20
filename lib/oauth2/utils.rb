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

    def build_oauth2_client(provider)
      provider_opts = OAuth2::Configuration.instance.providers[provider.to_sym].dup

      client_id = provider_opts.delete(:client_id)
      client_secret = provider_opts.delete(:client_secret)

      OAuth2::Client.new(id: client_id, secret: client_secret, **provider_opts)
    end
  end
end
