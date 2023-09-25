scope module: :v1, defaults: { format: :json }, constraints: ApiConstraints.new(version: 1, default: true) do
  scope module: :sessions do
    get 'authorize'
  end

  get 'auths/:provider/callback',
    to: 'sessions#callback',
    as: :callback,
    constraints: TwitterCallbackConstraints.new

  resources :tweets, only: %i[index create]
end


