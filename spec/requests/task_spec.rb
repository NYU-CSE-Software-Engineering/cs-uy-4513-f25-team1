require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', username: 'tester', password: 'SecurePassword123') }
  let!(:invited_user) { User.create!(email_address: 'invited@example.com', username: 'invited', password: 'SecurePassword123') }
  let!(:project) { Project.create!(name: "Test Project", description: "Test description") }

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  describe "GET /projects/:project_id/tasks/new" do
    context "when user is a manager or developer" do
      before do
        Collaborator.create!(user: user, project: project, role: :manager)
        sign_in(user)
      end

      it "responds with 200 and renders the new template" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is invited (view-only)" do
      before do
        Collaborator.create!(user: invited_user, project: project, role: :invited)
        sign_in(invited_user)
      end

      it "redirects with permission denied" do
        get new_project_task_path(project)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
      end
    end
  end

  describe "POST /projects/:project_id/tasks" do
    context "when user is a manager or developer" do
      before do
        Collaborator.create!(user: user, project: project, role: :manager)
        sign_in(user)
      end

      context "with valid params" do
        it "creates a new Task under a project and redirects with 303 back to the project's new task page" do
          valid_params = {
            task: {
              title:  "Write request spec",
              status: "To Do"
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
          invalid_params = { task: { title: "", status: "To Do" } }

          expect {
            post project_tasks_path(project), params: invalid_params
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when user is invited (view-only)" do
      before do
        Collaborator.create!(user: invited_user, project: project, role: :invited)
        sign_in(invited_user)
      end

      it "does not create a task and redirects with permission denied" do
        valid_params = {
          task: {
            title: "Attempted task",
            status: "To Do"
          }
        }

        expect {
          post project_tasks_path(project), params: valid_params
        }.not_to change(Task, :count)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
      end
    end
  end

  describe "GET /projects/:project_id/tasks/:id/edit" do
    let!(:task) { Task.create!(title: "Test Task", status: "To Do", project: project, user: user) }

    context "when user is a manager or developer" do
      before do
        Collaborator.create!(user: user, project: project, role: :developer)
        sign_in(user)
      end

      it "responds with 200" do
        get edit_project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is invited (view-only)" do
      before do
        Collaborator.create!(user: invited_user, project: project, role: :invited)
        sign_in(invited_user)
      end

      it "redirects with permission denied" do
        get edit_project_task_path(project, task)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    let!(:task) { Task.create!(title: "Test Task", status: "To Do", project: project, user: user) }

    context "when user is a manager or developer" do
      before do
        Collaborator.create!(user: user, project: project, role: :developer)
        sign_in(user)
      end

      it "updates the task" do
        patch project_task_path(project, task), params: { task: { title: "Updated Title" } }
        expect(response).to have_http_status(:see_other)
        expect(task.reload.title).to eq("Updated Title")
      end
    end

    context "when user is invited (view-only)" do
      before do
        Collaborator.create!(user: invited_user, project: project, role: :invited)
        sign_in(invited_user)
      end

      it "does not update the task and redirects with permission denied" do
        patch project_task_path(project, task), params: { task: { title: "Hacked Title" } }
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
        expect(task.reload.title).to eq("Test Task")
      end
    end
  end
end
