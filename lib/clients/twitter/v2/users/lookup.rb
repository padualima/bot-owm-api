# frozen_string_literal: true

module Clients
  module Twitter
    module V2
      module Users
        class Lookup < Base
          def me
            call(method: :get, endpoint: "users/me")
          end
        end
      end
    end
  end
end
