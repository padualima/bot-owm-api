ApiTokenGenerator = -> (access_token) { BCrypt::Password.create(access_token) }
