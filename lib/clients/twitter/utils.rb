module Clients
  module Twitter
    module Utils
      module PKCE
        def code_verifier
          urlsafe_base64(SecureRandom.base64((rand(43..128) * 3) / 4))
        end
        module_function :code_verifier

        def code_challenge(code_verifier)
          urlsafe_base64(Digest::SHA256.base64digest(code_verifier))
        end
        module_function :code_challenge

        private

        def urlsafe_base64(base64_str)
          base64_str.tr("+/", "-_").tr("=", "")
        end
        module_function :urlsafe_base64
      end
    end
  end
end
