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

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    before do
      stub_const("Task::STATUS_OPTIONS", [ "not_started", "in_progress", "done" ])
    end

    it "updates the task and redirects to the specified location" do
      project = Project.create!(name: "Test Project")
      task = project.tasks.create!(title: "Test Task", status: "not_started")

      patch project_task_path(project, task), params: {
        task: { status: "in_progress" },
        redirect_to: project_path(project)
      }

      expect(response).to redirect_to(project_path(project))
      expect(task.reload.status).to eq("in_progress")
    end

    it "updates the task and redirects to task show page if no redirect_to param" do
      project = Project.create!(name: "Test Project")
      task = project.tasks.create!(title: "Test Task", status: "not_started")

      patch project_task_path(project, task), params: {
        task: { status: "in_progress" }
      }

      expect(response).to redirect_to(project_task_path(project, task))
      expect(task.reload.status).to eq("in_progress")
    end
  end

  describe "DELETE /projects/:project_id/tasks/:id" do
    it "destroys the requested task" do
      project = Project.create!(name: "Test Project")
      task = project.tasks.create!(title: "Test Task", status: "not_started")

      expect {
        delete project_task_path(project, task)
      }.to change(Task, :count).by(-1)

      expect(response).to redirect_to(project_tasks_path(project))
    end
  end
end
