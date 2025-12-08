require "rails_helper"

RSpec.describe "Task limit", type: :request do
  let(:user) { create(:user) }
  let!(:project) { Project.create!(name: "Alpha", wip_limit: 2) }

  def sign_in(user)
    session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    allow_any_instance_of(ApplicationController).to receive(:find_session_by_cookie).and_return(session)
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    before { sign_in(user) }

    context "when in_progress is below the task limit" do
      it "updates the task to in_progress and redirects 303 (see_other)" do
        project.tasks.create!(title: "Pre-existing Task 1", description: "Description 1", status: "In Progress")
        task = project.tasks.create!(title: "Pre-existing Task 2", description: "Description 2", status: "Todo")

        patch project_task_path(project, task),
              params: { task: { status: "In Progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(task.reload.status).to eq("in_progress")
      end
    end

    context "when in_progress has reached the task limit" do
      it "does NOT update and redirects 303 back to edit with an alert" do
        project.tasks.create!(title: "Pre-existing Task A", description: "Description A", status: "In Progress")
        project.tasks.create!(title: "Pre-existing Task B", description: "Description B", status: "In Progress")
        task = project.tasks.create!(title: "Third Task", description: "Description C", status: "Todo")

        patch project_task_path(project, task),
              params: { task: { status: "In Progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(flash[:alert]).to be_present
        expect(task.reload.status).to eq("todo")
      end
    end
  end

  describe "GET /projects/:project_id" do
    before { sign_in(user) }

    it "displays the page" do
      get project_path(project)

      expect(response).to have_http_status(:ok)
    end
  end
end
