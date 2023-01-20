require 'rails_helper'

RSpec.describe "V1::Sessions", type: :request do
  describe "GET /authorize" do
    it "returns http success" do
      get "/authorize"
      expect(response).to have_http_status(:success)
    end
  end
end
