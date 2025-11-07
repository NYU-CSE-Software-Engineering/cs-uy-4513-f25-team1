require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  describe "GET /tasks/new" do
    before do
      stub_const("Task::STATUS_OPTIONS", ["not_started", "in_progress", "done"])
    end

    it "responds with 200 and renders the new template" do
      get "/tasks/new"
      expect(response).to have_http_status(:ok)
    end
  end
end
