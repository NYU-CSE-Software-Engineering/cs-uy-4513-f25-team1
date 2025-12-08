require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:manager_collaborator) { create(:collaborator, user: user, project: project, role: "manager") }

  def sign_in(user)
    session_obj = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    allow_any_instance_of(ApplicationController).to receive(:find_session_by_cookie).and_return(session_obj)
    allow_any_instance_of(ActionController::Base).to receive(:session).and_return({ user_id: user.id })
  end

  describe "GET /projects/:project_id/tasks" do
    before { sign_in(user) }

    it "responds with 200 and displays tasks" do
      create(:task, project: project)
      get project_tasks_path(project)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /projects/:project_id/tasks/new" do
    before { sign_in(user) }

    context "when user is a manager" do
      before { manager_collaborator }

      it "responds with 200 and renders the new template" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is not a manager" do
      it "redirects with alert message" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        follow_redirect!
        expect(response.body).to include("Only managers can create tasks")
      end
    end
  end

  describe "POST /projects/:project_id/tasks" do
    before { sign_in(user) }

    context "when user is a manager" do
      before { manager_collaborator }

      context "with valid params" do
        it "creates a new Task and redirects to tasks index" do
          valid_params = {
            task: {
              title: "Write request spec",
              description: "Test description",
              priority: "High",
              due_at: 1.week.from_now,
              branch_link: "https://github.com/repo/branch"
            }
          }

          expect {
            post project_tasks_path(project), params: valid_params
          }.to change(Task, :count).by(1)

          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(project_tasks_path(project))

          task = Task.last
          expect(task.title).to eq("Write request spec")
          expect(task.description).to eq("Test description")
          expect(task.priority).to eq("high")
          expect(task.status).to eq("todo")
        end

        it "auto-sets status to 'In Progress' when assignee is present" do
          collaborator = create(:collaborator, project: project)
          valid_params = {
            task: {
              title: "Assigned task",
              description: "Test description",
              assignee: collaborator.id
            }
          }

          post project_tasks_path(project), params: valid_params

          task = Task.last
          expect(task.status).to eq("in_progress")
          expect(task.assignee).to eq(collaborator.id)
        end

        it "auto-sets status to 'Todo' when assignee is not present" do
          valid_params = {
            task: {
              title: "Unassigned task",
              description: "Test description"
            }
          }

          post project_tasks_path(project), params: valid_params

          task = Task.last
          expect(task.status).to eq("todo")
          expect(task.assignee).to be_nil
        end
      end

      context "with invalid params" do
        it "does not create a Task, returns 422, and sets a flash alert" do
          invalid_params = { task: { title: "", description: "" } }

          expect {
            post project_tasks_path(project), params: invalid_params
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when user is not a manager" do
      it "does not create a Task and redirects with alert" do
        valid_params = {
          task: {
            title: "Write request spec",
            description: "Test description"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        follow_redirect!
        expect(response.body).to include("Only managers can create tasks")
      end
    end
  end
end
