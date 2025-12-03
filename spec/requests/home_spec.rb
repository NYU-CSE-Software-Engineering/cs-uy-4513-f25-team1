require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Jira Lite")
      expect(response.body).to include("Login")
    end
  end

  describe "GET /features" do
    it "returns http success" do
      get "/features"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Features")
      expect(response.body).to include("Kanban Boards")
    end
  end
end
