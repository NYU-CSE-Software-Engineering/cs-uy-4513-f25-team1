require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  describe "GET /projects/:project_id/tasks/new" do
    before do
      stub_const("Task::STATUS_OPTIONS", [ "not_started", "in_progress", "done" ])
    end

    it "responds with 200 and renders the new template" do
      project = Project.create!(name: "Test Project")
      get new_project_task_path(project)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /projects/:project_id/tasks" do
    before do
      stub_const("Task::STATUS_OPTIONS", [ "not_started", "in_progress", "done" ])
    end

    context "with valid params" do
      it "creates a new Task under a project and redirects with 303 back to the project's new task page" do
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

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(new_project_task_path(project))
      end
    end

    context "with invalid params" do
      it "does not create a Task, returns 422, and sets a flash alert" do
        project = Project.create!(name: "Test Project")

        invalid_params = { task: { title: "", status: "not_started" } }

        expect {
          post project_tasks_path(project), params: invalid_params
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
