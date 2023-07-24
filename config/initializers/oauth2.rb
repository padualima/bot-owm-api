OAuth2::Builder.configure do
  provider :twitter, client_id: ENV['TWITTER_CLIENT_ID'], client_secret: ENV['TWITTER_CLIENT_SECRET']
end
