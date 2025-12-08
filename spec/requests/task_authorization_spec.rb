require 'rails_helper'

RSpec.describe "Task Authorization", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project) }

  def sign_in(user)
    session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    allow_any_instance_of(ApplicationController).to receive(:find_session_by_cookie).and_return(session)
  end

  describe "manager role requirement for task creation" do
    context "when user is a manager for the project" do
      before do
        create(:collaborator, user: user, project: project, role: "manager")
        sign_in(user)
      end

      it "allows access to new task page" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:ok)
      end

      it "allows creating tasks" do
        valid_params = {
          task: {
            title: "New task",
            description: "Test description"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.to change(Task, :count).by(1)
      end
    end

    context "when user is not a manager for the project" do
      before do
        create(:collaborator, user: user, project: project, role: "editor")
        sign_in(user)
      end

      it "denies access to new task page" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end

      it "denies creating tasks" do
        valid_params = {
          task: {
            title: "New task",
            description: "Test description"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end

    context "when user is not a collaborator" do
      before { sign_in(user) }

      it "denies access to new task page" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end

      it "denies creating tasks" do
        valid_params = {
          task: {
            title: "New task",
            description: "Test description"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_tasks_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end
  end

  describe "project-specific manager check" do
    let(:other_project) { create(:project) }

    before do
      create(:collaborator, user: user, project: project, role: "manager")
      create(:collaborator, user: user, project: other_project, role: "editor")
      sign_in(user)
    end

    it "allows creating tasks in project where user is manager" do
      valid_params = {
        task: {
          title: "New task",
          description: "Test description"
        }
      }

      expect {
        post project_tasks_path(project), params: valid_params
      }.to change(Task, :count).by(1)
    end

    it "denies creating tasks in project where user is not manager" do
      valid_params = {
        task: {
          title: "New task",
          description: "Test description"
        }
      }

      expect {
        post project_tasks_path(other_project), params: valid_params
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(project_tasks_path(other_project))
      expect(flash[:alert]).to eq("Only managers can create tasks.")
    end
  end
end
