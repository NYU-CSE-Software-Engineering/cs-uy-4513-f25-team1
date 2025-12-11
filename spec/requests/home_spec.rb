require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Quadratic")
      expect(response.body).to include("Login")
    end

    it "includes features section" do
      get "/"
      expect(response.body).to include("Features")
      expect(response.body).to include("Project Management")
      expect(response.body).to include("Task Tracking")
    end
  end
end
