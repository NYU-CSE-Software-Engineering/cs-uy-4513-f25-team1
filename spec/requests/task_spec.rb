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

  describe "POST /tasks" do
    before do
      stub_const("Task::STATUS_OPTIONS", ["not_started", "in_progress", "done"])
    end

    context "with valid params" do
      it "creates a new Task under a project and redirects with 303 to that project's tasks" do
        project = Project.create!(name: "Test Project")

        valid_params = {
          task: {
            title:  "Write request spec",
            status: "not_started"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:see_other) # 303
        expect(response).to redirect_to(project_tasks_path(project))
      end
    end
  end
end

