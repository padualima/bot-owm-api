require 'api_constraints'

class ActionDispatch::Routing::Mapper
  def draw(version)
    instance_eval(File.read(Rails.root.join("config/routes/#{version}.rb")))
  end
end

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  draw :v1

  root "v1/sessions#authorize"
end
