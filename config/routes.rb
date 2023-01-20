require 'api_constraints'

class ActionDispatch::Routing::Mapper
  def draw(version)
    instance_eval(File.read(Rails.root.join("config/routes/#{version}.rb")))
  end
end

Rails.application.routes.draw do
  draw :v1

  # root "articles#index"
end
