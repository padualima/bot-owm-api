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
      opts.delete_if { |key, _| !key.in?(ALLOWED_OPTIONS) } if opts.any?

      add_provider(strategy, **opts)
    end

    def add_provider(strategy, **opts)
      Configuration.instance.providers[strategy.to_sym] = opts
    end
  end
end
