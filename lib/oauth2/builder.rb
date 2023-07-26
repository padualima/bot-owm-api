# frozen_string_literal: true

module OAuth2
  class Builder
    ALLOWED_OPTIONS = %i[client_id client_secret url authorize_url token_url redirect_uri]

    def self.configure(&block)
      new(&block)
    end

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def provider(strategy, **opts)
      add_provider(strategy, **Utils.filter_hash_by_keys(opts, ALLOWED_OPTIONS))
    end

    def add_provider(strategy, **opts)
      Configuration.instance.providers[strategy.to_sym] = opts
    end
  end
end
