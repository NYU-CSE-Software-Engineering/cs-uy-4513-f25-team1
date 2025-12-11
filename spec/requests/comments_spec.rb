require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:project) { create(:project) }
  let!(:task) { create(:task, project: project) }

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: "password" }
  end

  describe "POST /projects/:project_id/tasks/:task_id/comments" do
    context "when user is a manager" do
      before do
        Collaborator.create!(user: user, project: project, role: :manager)
        sign_in(user)
      end

      it "creates a comment on the task" do
        expect {
          post project_task_comments_path(project, task), params: {
            comment: { content: "This is a test comment" }
          }
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:notice]).to eq("Comment added.")
      end

      it "creates a comment with markdown content" do
        post project_task_comments_path(project, task), params: {
          comment: { content: "**Bold** and *italic* text" }
        }

        comment = Comment.last
        expect(comment.content).to eq("**Bold** and *italic* text")
      end

      it "fails to create comment with blank content" do
        expect {
          post project_task_comments_path(project, task), params: {
            comment: { content: "" }
          }
        }.not_to change(Comment, :count)

        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to include("Content can't be blank")
      end
    end

    context "when user is a developer" do
      before do
        Collaborator.create!(user: user, project: project, role: :developer)
        sign_in(user)
      end

      it "creates a comment on the task" do
        expect {
          post project_task_comments_path(project, task), params: {
            comment: { content: "Developer comment" }
          }
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:see_other)
      end
    end

    context "when user is invited (not manager or developer)" do
      before do
        Collaborator.create!(user: user, project: project, role: :invited)
        sign_in(user)
      end

      it "does not allow creating comments" do
        expect {
          post project_task_comments_path(project, task), params: {
            comment: { content: "Should not be allowed" }
          }
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("Only managers and developers can comment on tasks.")
      end
    end

    context "when task is completed" do
      let!(:completed_task) { create(:task, project: project, status: :completed, completed_at: Time.current) }

      before do
        Collaborator.create!(user: user, project: project, role: :manager)
        sign_in(user)
      end

      it "does not allow creating comments on completed tasks" do
        expect {
          post project_task_comments_path(project, completed_task), params: {
            comment: { content: "Should not be allowed" }
          }
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(project_task_path(project, completed_task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("Cannot add comments to completed tasks.")
      end
    end
  end

  describe "PATCH /projects/:project_id/tasks/:task_id/comments/:id" do
    let!(:collaborator) { Collaborator.create!(user: user, project: project, role: :manager) }
    let!(:comment) { Comment.create!(task: task, collaborator: collaborator, content: "Original content") }

    before { sign_in(user) }

    it "updates the comment" do
      patch project_task_comment_path(project, task, comment), params: {
        comment: { content: "Updated content" }
      }

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(project_task_path(project, task, anchor: "comment-#{comment.id}"))
      expect(comment.reload.content).to eq("Updated content")
      expect(flash[:notice]).to eq("Comment updated.")
    end

    it "fails to update with blank content" do
      patch project_task_comment_path(project, task, comment), params: {
        comment: { content: "" }
      }

      expect(response).to have_http_status(:see_other)
      expect(flash[:alert]).to include("Content can't be blank")
      expect(comment.reload.content).to eq("Original content")
    end

    context "when another user tries to edit the comment" do
      let!(:other_collaborator) { Collaborator.create!(user: other_user, project: project, role: :developer) }

      before do
        sign_in(other_user)
      end

      it "does not allow editing another user's comment" do
        patch project_task_comment_path(project, task, comment), params: {
          comment: { content: "Hacked content" }
        }

        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("You can only edit or delete your own comments.")
        expect(comment.reload.content).to eq("Original content")
      end
    end

    context "when task is completed" do
      before do
        task.update!(status: :completed, completed_at: Time.current)
      end

      it "does not allow editing comments on completed tasks" do
        patch project_task_comment_path(project, task, comment), params: {
          comment: { content: "Should not update" }
        }

        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("Cannot add comments to completed tasks.")
        expect(comment.reload.content).to eq("Original content")
      end
    end
  end

  describe "DELETE /projects/:project_id/tasks/:task_id/comments/:id" do
    let!(:collaborator) { Collaborator.create!(user: user, project: project, role: :manager) }
    let!(:comment) { Comment.create!(task: task, collaborator: collaborator, content: "To be deleted") }

    before { sign_in(user) }

    it "deletes the comment" do
      expect {
        delete project_task_comment_path(project, task, comment)
      }.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
      expect(flash[:notice]).to eq("Comment deleted.")
    end

    context "when another user tries to delete the comment" do
      let!(:other_collaborator) { Collaborator.create!(user: other_user, project: project, role: :developer) }

      before do
        sign_in(other_user)
      end

      it "does not allow deleting another user's comment" do
        expect {
          delete project_task_comment_path(project, task, comment)
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("You can only edit or delete your own comments.")
      end
    end

    context "when task is completed" do
      before do
        task.update!(status: :completed, completed_at: Time.current)
      end

      it "does not allow deleting comments on completed tasks" do
        expect {
          delete project_task_comment_path(project, task, comment)
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(project_task_path(project, task, anchor: "comments-section"))
        expect(flash[:alert]).to eq("Cannot add comments to completed tasks.")
      end
    end
  end

  describe "GET /projects/:project_id/tasks/:id (viewing comments)" do
    let!(:collaborator) { Collaborator.create!(user: user, project: project, role: :manager) }
    let!(:comment) { Comment.create!(task: task, collaborator: collaborator, content: "Test comment content") }

    before { sign_in(user) }

    it "displays comments on the task show page" do
      get project_task_path(project, task)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Comments")
      expect(response.body).to include("Test comment content")
      expect(response.body).to include(user.username)
    end

    it "shows comment count" do
      get project_task_path(project, task)

      expect(response.body).to include("1")
    end

    it "shows edit and delete buttons for comment author" do
      get project_task_path(project, task)

      expect(response.body).to include("edit-comment-btn")
      expect(response.body).to include("delete-comment-btn")
    end

    context "when viewing as a different user" do
      let!(:other_collaborator) { Collaborator.create!(user: other_user, project: project, role: :developer) }

      before { sign_in(other_user) }

      it "does not show edit and delete buttons for other user's comments" do
        get project_task_path(project, task)

        expect(response.body).to include("Test comment content")
        expect(response.body).not_to include("edit-comment-btn")
        expect(response.body).not_to include("delete-comment-btn")
      end
    end
  end
end
