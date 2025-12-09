require "rails_helper"

RSpec.describe "Task limit", type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', username: 'tester', password: 'SecurePassword123') }
  let!(:project) { Project.create!(name: "Alpha", wip_limit: 2) }

  # Helper to sign in user via POST to session
  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    before { sign_in(user) }

    context "when In Progress is below the task limit" do
      it "updates the task to In Progress and redirects 303 (see_other)" do
        project.tasks.create!(title: "Pre-existing Task 1", status: "In Progress", user: user)
        task = project.tasks.create!(title: "Pre-existing Task 2", status: "To Do", user: user)

        patch project_task_path(project, task),
              params: { task: { status: "In Progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(task.reload.status).to eq("In Progress")
      end
    end

    context "when In Progress has reached the task limit" do
      it "does NOT update and redirects 303 back to edit with an alert" do
        project.tasks.create!(title: "Pre-existing Task A", status: "In Progress", user: user)
        project.tasks.create!(title: "Pre-existing Task B", status: "In Progress", user: user)
        task = project.tasks.create!(title: "Third Task", status: "To Do", user: user)

        patch project_task_path(project, task),
              params: { task: { status: "In Progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(flash[:alert]).to be_present
        expect(task.reload.status).to eq("To Do")
      end
    end
  end

  describe "POST /projects/:project_id/tasks" do
    before { sign_in(user) }

    context "when creating a task as In Progress and below the limit" do
      it "creates the task successfully" do
        project.tasks.create!(title: "Existing Task", status: "In Progress", user: user)

        expect {
          post project_tasks_path(project),
               params: { task: { title: "New Task", status: "In Progress" } }
        }.to change(Task, :count).by(1)

        expect(response).to have_http_status(:see_other)
      end
    end

    context "when creating a task as In Progress and WIP limit reached" do
      it "does NOT create the task and shows an alert" do
        project.tasks.create!(title: "Task A", status: "In Progress", user: user)
        project.tasks.create!(title: "Task B", status: "In Progress", user: user)

        expect {
          post project_tasks_path(project),
               params: { task: { title: "New Task", status: "In Progress" } }
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to include("WIP limit")
      end
    end

    context "when creating a task as To Do (WIP limit doesn't apply)" do
      it "creates the task even if WIP limit is reached" do
        project.tasks.create!(title: "Task A", status: "In Progress", user: user)
        project.tasks.create!(title: "Task B", status: "In Progress", user: user)

        expect {
          post project_tasks_path(project),
               params: { task: { title: "New Task", status: "To Do" } }
        }.to change(Task, :count).by(1)

        expect(response).to have_http_status(:see_other)
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
