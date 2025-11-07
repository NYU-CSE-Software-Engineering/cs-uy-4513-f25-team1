require "rails_helper"

RSpec.describe "Task WIP limit", type: :request do
  before do
    stub_const("Task::STATUS_OPTIONS", %w(not_started in_progress done))
  end

  let!(:project) { Project.create!(name: "Alpha") }

  before do
    allow_any_instance_of(Project).to receive(:wip_limit).and_return(2)
  end

  describe "PATCH /projects/:project_id/tasks/:id" do
    context "when in_progress is below the WIP limit" do
      it "updates the task to in_progress and redirects 303 (see_other)" do
        project.tasks.create!(title: "Pre-existing Task 1", status: "in_progress")
        task = project.tasks.create!(title: "Pre-existing Task 2", status: "not_started")

        patch project_task_path(project, task),
              params: { task: { status: "in_progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(task.reload.status).to eq("in_progress")
      end
    end

    context "when in_progress has reached the WIP limit" do
      it "does NOT update and redirects 303 back to edit with an alert" do
        project.tasks.create!(title: "Pre-existing Task A", status: "in_progress")
        project.tasks.create!(title: "Pre-existing Task B", status: "in_progress")
        task = project.tasks.create!(title: "Third Task", status: "not_started")

        patch project_task_path(project, task),
              params: { task: { status: "in_progress" } }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(edit_project_task_path(project, task))
        expect(flash[:alert]).to be_present
        expect(task.reload.status).to eq("not_started")
      end
    end
  end
end
