require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:manager_user) { User.create!(email_address: 'manager@example.com', username: 'manager', password: 'SecurePassword123') }
  let!(:developer_user) { User.create!(email_address: 'developer@example.com', username: 'developer', password: 'SecurePassword123') }
  let!(:invited_user) { User.create!(email_address: 'invited@example.com', username: 'invited', password: 'SecurePassword123') }
  let!(:project) { Project.create!(name: "Test Project", description: "Test description") }

  let!(:manager_collaborator) { Collaborator.create!(user: manager_user, project: project, role: :manager) }
  let!(:developer_collaborator) { Collaborator.create!(user: developer_user, project: project, role: :developer) }
  let!(:invited_collaborator) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  def valid_task_params(overrides = {})
    {
      task: {
        title: "Write request spec",
        description: "A comprehensive test for the task feature",
        type: "Feature"
      }.merge(overrides)
    }
  end

  describe "GET /projects/:project_id/tasks/new" do
    context "when user is a manager" do
      before { sign_in(manager_user) }

      it "responds with 200 and renders the new template" do
        get new_project_task_path(project)
        expect(response).to have_http_status(:ok)
      end

      it "shows assignee dropdown with developers available for assignment" do
        get new_project_task_path(project)
        expect(response.body).to include(developer_user.username)
        expect(response.body).to include("Assignee (optional)")
      end
    end

    context "when user is a developer" do
      before { sign_in(developer_user) }

      it "redirects with permission denied" do
        get new_project_task_path(project)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end

    context "when user is invited (view-only)" do
      before { sign_in(invited_user) }

      it "redirects with permission denied" do
        get new_project_task_path(project)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end
  end

  describe "POST /projects/:project_id/tasks" do
    context "when user is a manager" do
      before { sign_in(manager_user) }

      context "with valid params" do
        it "creates a new Task and redirects to task show page" do
          expect {
            post project_tasks_path(project), params: valid_task_params
          }.to change(Task, :count).by(1)

          new_task = Task.last
          expect(response).to have_http_status(:see_other)
          expect(response).to redirect_to(project_task_path(project, new_task))
        end

        it "sets status to 'todo' when no assignee is provided" do
          post project_tasks_path(project), params: valid_task_params

          expect(Task.last.status).to eq("todo")
        end

        it "sets status to 'in_progress' when an assignee is provided" do
          post project_tasks_path(project), params: valid_task_params(assignee_id: developer_collaborator.id)

          expect(Task.last.status).to eq("in_progress")
          expect(Task.last.assignee).to eq(developer_collaborator)
        end

        it "allows setting priority" do
          post project_tasks_path(project), params: valid_task_params(priority: "high")

          expect(Task.last.priority).to eq("high")
        end

        it "allows setting due_at" do
          due_date = 1.week.from_now
          post project_tasks_path(project), params: valid_task_params(due_at: due_date)

          expect(Task.last.due_at).to be_within(1.second).of(due_date)
        end

        it "allows setting branch_link" do
          post project_tasks_path(project), params: valid_task_params(branch_link: "https://github.com/org/repo/tree/feature")

          expect(Task.last.branch_link).to eq("https://github.com/org/repo/tree/feature")
        end
      end

      context "with invalid params" do
        it "does not create a Task when title is missing" do
          invalid_params = valid_task_params(title: "")

          expect {
            post project_tasks_path(project), params: invalid_params
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(flash[:alert]).to be_present
        end

        it "does not create a Task when description is missing" do
          invalid_params = valid_task_params(description: "")

          expect {
            post project_tasks_path(project), params: invalid_params
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "does not allow assigning a manager as assignee" do
          invalid_params = valid_task_params(assignee_id: manager_collaborator.id)

          expect {
            post project_tasks_path(project), params: invalid_params
          }.not_to change(Task, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when user is a developer" do
      before { sign_in(developer_user) }

      it "does not create a task and redirects with permission denied" do
        expect {
          post project_tasks_path(project), params: valid_task_params
        }.not_to change(Task, :count)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end

    context "when user is invited (view-only)" do
      before { sign_in(invited_user) }

      it "does not create a task and redirects with permission denied" do
        expect {
          post project_tasks_path(project), params: valid_task_params
        }.not_to change(Task, :count)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("Only managers can create tasks.")
      end
    end
  end

  describe "GET /projects/:project_id/tasks/:id" do
    let!(:task) { Task.create!(title: "Test Task", description: "Test description", status: :todo, project: project) }

    context "when user is a manager or developer" do
      before { sign_in(developer_user) }

      it "responds with 200" do
        get project_task_path(project, task)
        expect(response).to have_http_status(:ok)
      end

      it "displays task details" do
        get project_task_path(project, task)
        expect(response.body).to include(task.title)
        expect(response.body).to include(task.description)
      end

      it "shows completion notice for completed tasks" do
        completed_task = Task.create!(
          title: "Completed Task",
          description: "Done",
          status: :completed,
          project: project,
          completed_at: Time.current
        )
        get project_task_path(project, completed_task)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("cannot be modified")
      end
    end

    context "when user is invited (view-only)" do
      before { sign_in(invited_user) }

      it "redirects with permission denied" do
        get project_task_path(project, task)
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    let!(:task) { Task.create!(title: "Test Task", description: "Test description", status: :todo, project: project) }

    context "when user is a manager or developer" do
      before { sign_in(developer_user) }

      it "updates the task title and redirects to show page" do
        patch project_task_path(project, task), params: { task: { title: "Updated Title" } }
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_task_path(project, task))
        expect(task.reload.title).to eq("Updated Title")
      end

      it "updates the task description" do
        patch project_task_path(project, task), params: { task: { description: "Updated description" } }
        expect(task.reload.description).to eq("Updated description")
      end

      it "updates the task status" do
        patch project_task_path(project, task), params: { task: { status: "in_progress" } }
        expect(task.reload.status).to eq("in_progress")
      end

      it "updates the assignee" do
        patch project_task_path(project, task), params: { task: { assignee_id: developer_collaborator.id } }
        expect(task.reload.assignee).to eq(developer_collaborator)
      end

      it "updates priority" do
        patch project_task_path(project, task), params: { task: { priority: "urgent" } }
        expect(task.reload.priority).to eq("urgent")
      end

      it "updates branch_link" do
        patch project_task_path(project, task), params: { task: { branch_link: "https://github.com/test" } }
        expect(task.reload.branch_link).to eq("https://github.com/test")
      end

      it "does not allow assigning a manager as assignee" do
        patch project_task_path(project, task), params: { task: { assignee_id: manager_collaborator.id } }
        expect(response).to redirect_to(project_task_path(project, task))
        expect(task.reload.assignee_id).to be_nil
      end
    end

    context "when task status is changed to completed" do
      before { sign_in(developer_user) }

      it "sets completed_at timestamp" do
        expect(task.completed_at).to be_nil

        patch project_task_path(project, task), params: { task: { status: "completed" } }

        task.reload
        expect(task.status).to eq("completed")
        expect(task.completed_at).not_to be_nil
      end
    end

    context "when task is already completed" do
      let!(:completed_task) { Task.create!(title: "Completed Task", description: "Done", status: :completed, project: project, completed_at: 1.day.ago) }

      before { sign_in(developer_user) }

      it "does not allow modifications" do
        original_title = completed_task.title

        patch project_task_path(project, completed_task), params: { task: { title: "Attempted Update" } }

        expect(response).to redirect_to(project_task_path(project, completed_task))
        expect(completed_task.reload.title).to eq(original_title)
      end
    end

    context "when user is invited (view-only)" do
      before { sign_in(invited_user) }

      it "does not update the task and redirects with permission denied" do
        patch project_task_path(project, task), params: { task: { title: "Hacked Title" } }
        expect(response).to redirect_to(project_path(project))
        expect(flash[:alert]).to eq("You do not have permission to edit this project.")
        expect(task.reload.title).to eq("Test Task")
      end
    end
  end

  describe "status auto-assignment logic" do
    before { sign_in(manager_user) }

    it "sets status to todo when creating task without assignee" do
      post project_tasks_path(project), params: valid_task_params(assignee_id: nil)
      expect(Task.last.status).to eq("todo")
    end

    it "sets status to in_progress when creating task with assignee" do
      post project_tasks_path(project), params: valid_task_params(assignee_id: developer_collaborator.id)
      expect(Task.last.status).to eq("in_progress")
    end
  end

  describe "assignee validation" do
    before { sign_in(manager_user) }

    it "allows assigning a developer" do
      post project_tasks_path(project), params: valid_task_params(assignee_id: developer_collaborator.id)
      expect(Task.last.assignee).to eq(developer_collaborator)
    end

    it "rejects assigning a manager" do
      expect {
        post project_tasks_path(project), params: valid_task_params(assignee_id: manager_collaborator.id)
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows no assignee (unassigned task)" do
      post project_tasks_path(project), params: valid_task_params(assignee_id: nil)
      expect(Task.last.assignee).to be_nil
    end
  end

  describe "completed task immutability" do
    let!(:completed_task) do
      Task.create!(
        title: "Completed Task",
        description: "This task is done",
        status: :completed,
        project: project,
        completed_at: 1.day.ago
      )
    end

    before { sign_in(developer_user) }

    it "prevents title changes" do
      patch project_task_path(project, completed_task), params: { task: { title: "New Title" } }
      expect(completed_task.reload.title).to eq("Completed Task")
    end

    it "prevents status changes" do
      patch project_task_path(project, completed_task), params: { task: { status: "todo" } }
      expect(completed_task.reload.status).to eq("completed")
    end

    it "prevents assignee changes" do
      patch project_task_path(project, completed_task), params: { task: { assignee_id: developer_collaborator.id } }
      expect(completed_task.reload.assignee_id).to be_nil
    end
  end
end
