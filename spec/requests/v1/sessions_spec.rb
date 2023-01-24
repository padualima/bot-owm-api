# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "V1::Sessions", type: :request do
  describe "GET /authorize" do
    it "returns http success" do
      get "/authorize"
      expect(response).to have_http_status(:success)
    end

    it "return a mesasge data with string" do
      get "/authorize"

      expect(response.parsed_body).to include_json({ data: { message: a_kind_of(String) } })
    end

    it "return a mesasge data with valid authorize_url" do
      code_verifier = Helpers.generate_code_verifier
      code_challenge = Helpers.generate_code_challenge
      authorize_url = Helpers.generate_authorize_url(code_verifier, code_challenge)

      allow(Clients::Twitter::Utils::PKCE).to receive(:code_verifier).and_return(code_verifier)
      allow(Clients::Twitter::Utils::PKCE).to receive(:code_challenge).and_return(code_challenge)

      get "/authorize"

      expect(response.parsed_body["data"]["message"]).to eql(authorize_url)
    end
  end
end
