require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  before(:context) do
    if Project.find_by(1)
      return
    end

    Project.create(name: "Test project")
  end

  describe "GET /projects/id/tasks/new" do
    it "returns http success" do
      get "/projects/1/tasks/new"
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST /projects/id/tasks" do
    it "returns http success" do
      post "/projects/1/tasks"
      expect(response).to have_http_status(:success)
    end
  end
end
