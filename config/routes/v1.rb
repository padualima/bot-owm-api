scope module: :v1, defaults: { format: :json }, constraints: ApiConstraints.new(version: 1, default: true) do
  get '/authorize', to: 'sessions#authorize'
  # get 'auths/:provider/callback', to: 'sessions#create'
end


