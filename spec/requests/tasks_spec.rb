require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  before(:context) do
    Project.create!(name: "Test project") unless Project.find_by(id: 1)
  end

  describe "GET /projects/1/tasks/new" do
    it "returns http success" do
      get "/projects/1/tasks/new"
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST /projects/1/tasks" do
    it "returns http success" do
      post "/projects/1/tasks"
      expect(response).to have_http_status(:success)
    end
  end
end
