require 'rails_helper'

RSpec.describe "Task Media", type: :request do
  let!(:user) { create(:user) }
  let!(:project) { create(:project) }
  let!(:task) { create(:task, project: project, user: user) }

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: "password" }
  end

  def create_test_image
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.png'), 'image/png')
  end

  def create_test_pdf
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_document.pdf'), 'application/pdf')
  end

  before do
    Collaborator.create!(user: user, project: project, role: :manager)
    sign_in(user)
  end

  describe "GET /projects/:project_id/tasks/:id" do
    it "displays the task show page with media section" do
      get project_task_path(project, task)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(task.title)
      expect(response.body).to include("Media Files")
    end

    it "displays attached media files" do
      task.media_files.attach(create_test_image)

      get project_task_path(project, task)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("test_image.png")
    end

    it "shows message when no media files are attached" do
      get project_task_path(project, task)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No media files attached")
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id (media upload)" do
    context "with valid media files" do
      it "attaches media files to the task" do
        expect {
          patch project_task_path(project, task), params: {
            task: {
              media_files: [ create_test_image ]
            },
            redirect_to_show: "1"
          }
        }.to change { task.media_files.count }.by(1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_task_path(project, task))
      end

      it "attaches multiple media files" do
        expect {
          patch project_task_path(project, task), params: {
            task: {
              media_files: [ create_test_image, create_test_pdf ]
            },
            redirect_to_show: "1"
          }
        }.to change { task.reload.media_files.count }.by(2)
      end

      it "redirects to show page when uploading from show page" do
        patch project_task_path(project, task), params: {
          task: {
            media_files: [ create_test_image ]
          },
          redirect_to_show: "1"
        }

        expect(response).to redirect_to(project_task_path(project, task))
        expect(flash[:notice]).to include("Media files uploaded")
      end
    end

    context "with invalid media files" do
      it "rejects files exceeding the count limit" do
        # Attach 10 files first
        10.times do
          task.media_files.attach(create_test_image)
        end
        task.save!
        initial_count = task.media_files.count

        # Try to attach an 11th file by appending (not replacing)
        new_file = create_test_image
        task.media_files.attach(new_file)

        # Validation should prevent saving
        expect(task.save).to be false
        expect(task.errors[:media_files]).to be_present

        # Reload to ensure nothing was persisted
        task.reload
        expect(task.media_files.count).to eq(initial_count)
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id (remove media)" do
    let!(:attachment) do
      task.media_files.attach(create_test_image)
      task.save!
      task.media_files.first
    end

    it "removes a media file from the task" do
      expect {
        patch project_task_path(project, task), params: {
          task: {
            remove_media_file_ids: [ attachment.id ]
          },
          redirect_to_show: "1"
        }
      }.to change { task.reload.media_files.count }.by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(project_task_path(project, task))
      expect(flash[:notice]).to include("Media file removed")
    end

    it "prevents removing media from a different task" do
      other_task = create(:task, project: project, user: user)
      other_attachment = other_task.media_files.attach(create_test_image)
      other_task.save!

      expect {
        patch project_task_path(project, task), params: {
          task: {
            remove_media_file_ids: [ other_task.media_files.first.id ]
          },
          redirect_to_show: "1"
        }
      }.not_to change { task.reload.media_files.count }

      expect(response).to have_http_status(:see_other)
      expect(task.reload.media_files.count).to eq(1)
    end

    it "handles non-existent attachment ID gracefully" do
      patch project_task_path(project, task), params: {
        task: {
          remove_media_file_ids: [ 99999 ]
        },
        redirect_to_show: "1"
      }

      expect(response).to have_http_status(:see_other)
      expect(task.reload.media_files.count).to eq(1)
    end
  end

  describe "POST /projects/:project_id/tasks (create with media)" do
    it "creates a task with media files attached" do
      expect {
        post project_tasks_path(project), params: {
          task: {
            title: "New Task with Media",
            status: "To Do",
            type: "Feature",
            media_files: [ create_test_image ]
          }
        }
      }.to change(Task, :count).by(1)

      new_task = Task.last
      expect(new_task.media_files.count).to eq(1)
    end
  end

  describe "PATCH /projects/:project_id/tasks/:id (update with media)" do
    it "updates task and attaches media files" do
      patch project_task_path(project, task), params: {
        task: {
          title: "Updated Title",
          status: task.status,
          type: task.type,
          media_files: [ create_test_image ]
        }
      }

      task.reload
      expect(task.title).to eq("Updated Title")
      expect(task.media_files.count).to eq(1)
    end
  end

  describe "security: media scoping" do
    let!(:other_project) { create(:project) }
    let!(:other_task) { create(:task, project: other_project, user: user) }

    it "prevents accessing media from a task in a different project" do
      other_task.media_files.attach(create_test_image)
      other_task.save!

      # Try to access the other task's media via wrong project
      # This should fail because other_task belongs to other_project, not project
      # The set_task before_action should raise RecordNotFound
      expect {
        get project_task_path(project, other_task)
      }.to raise_error(TasksController::TaskNotFoundError)
    end

    it "prevents deleting media from a task in a different project" do
      other_task.media_files.attach(create_test_image)
      other_task.save!
      attachment = other_task.media_files.first

      # Try to delete via wrong project context
      # This should fail because other_task belongs to other_project, not project
      # The set_task before_action should raise TaskNotFoundError
      expect {
        patch project_task_path(project, other_task), params: {
          task: {
            remove_media_file_ids: [ attachment.id ]
          },
          redirect_to_show: "1"
        }
      }.to raise_error(TasksController::TaskNotFoundError)
    end
  end
end
