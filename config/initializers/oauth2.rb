OAuth2::Builder.configure do
  provider :twitter,
    client_id: ENV['TWITTER_CLIENT_ID'],
    client_secret: ENV['TWITTER_CLIENT_SECRET'],
    url: ENV['TWITTER_BASE_URL_V2'],
    authorize_options: { url: ENV['TWITTER_AUTHORIZE_URL'] },
    token_options: { url: ENV['TWITTER_TOKEN_URL'] },
    redirect_uri: ENV['TWITTER_CALLBACK_URL']
end
