scope module: :v1, defaults: { format: :json }, constraints: ApiConstraints.new(version: 1, default: true) do
  scope module: :sessions do
    get 'authorize'
  end
  get 'auths/:provider/callback', to: 'session#callback'
  get '/authorize', to: 'sessions#authorize'
  # get 'auths/:provider/callback', to: 'sessions#create'
end


