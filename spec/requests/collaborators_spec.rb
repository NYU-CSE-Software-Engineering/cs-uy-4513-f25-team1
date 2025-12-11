require 'rails_helper'

RSpec.describe "Collaborators", type: :request do
  let(:manager) { User.create!(email_address: 'manager@example.com', username: 'manager', password: 'SecurePassword123') }
  let(:invited_user) { User.create!(email_address: 'invited@example.com', username: 'invited', password: 'SecurePassword123') }
  let(:other_user) { User.create!(email_address: 'other@example.com', username: 'other', password: 'SecurePassword123') }
  let(:project) { Project.create!(name: 'Test Project', description: 'Test description') }

  before do
    Collaborator.create!(user: manager, project: project, role: :manager)
  end

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  describe "PATCH /projects/:project_id/collaborators/:id" do
    context "when user is the invited collaborator" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(invited_user) }

      it "changes role from invited to developer" do
        expect {
          patch project_collaborator_path(project, invite)
        }.to change { invite.reload.role }.from("invited").to("developer")
      end

      it "redirects with success notice" do
        patch project_collaborator_path(project, invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq("You have joined #{project.name} as a developer.")
      end

      it "does not destroy the collaborator record" do
        expect {
          patch project_collaborator_path(project, invite)
        }.not_to change(Collaborator, :count)
      end
    end

    context "when collaborator is not in invited status" do
      let!(:developer_collab) { Collaborator.create!(user: invited_user, project: project, role: :developer) }

      before { sign_in(invited_user) }

      it "does not change the role" do
        expect {
          patch project_collaborator_path(project, developer_collab)
        }.not_to change { developer_collab.reload.role }
      end

      it "redirects to project page without changing anything" do
        patch project_collaborator_path(project, developer_collab)
        expect(response).to redirect_to(project_path(project))
        expect(developer_collab.reload.role).to eq('developer')
      end
    end

    context "when user tries to accept another user's invite" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(other_user) }

      it "redirects with authorization error" do
        patch project_collaborator_path(project, invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not change the invite status" do
        expect {
          patch project_collaborator_path(project, invite)
        }.not_to change { invite.reload.role }
      end
    end
  end

  describe "DELETE /projects/:project_id/collaborators/:id" do
    context "when user is the invited collaborator" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(invited_user) }

      it "destroys the collaborator record" do
        expect {
          delete project_collaborator_path(project, invite)
        }.to change(Collaborator, :count).by(-1)
      end

      it "redirects with success notice" do
        delete project_collaborator_path(project, invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq("You have declined the invitation to #{project.name}.")
      end

      it "removes the user from the project collaborators" do
        delete project_collaborator_path(project, invite)
        expect(Collaborator.find_by(user: invited_user, project: project)).to be_nil
      end
    end

    context "when user tries to reject another user's invite" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(other_user) }

      it "redirects with authorization error" do
        delete project_collaborator_path(project, invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not destroy the collaborator record" do
        expect {
          delete project_collaborator_path(project, invite)
        }.not_to change(Collaborator, :count)
      end
    end
  end

  describe "GET /projects/:project_id/collaborators/:id" do
    let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before do
      sign_in(manager)
      # Create some tasks for stats
      Task.create!(title: 'Task 1', description: 'Description', status: :completed, project: project, assignee: developer)
      Task.create!(title: 'Task 2', description: 'Description', status: :in_progress, project: project, assignee: developer)
    end

    it "displays individual collaborator details" do
      get project_collaborator_path(project, developer)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('other')
      expect(response.body).to include('Performance Metrics')
    end

    it "displays task statistics" do
      get project_collaborator_path(project, developer)

      expect(response.body).to include('Total Assigned')
      expect(response.body).to include('Total Completed')
    end
  end

  describe "GET /projects/:project_id/collaborators/:id/edit" do
    let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before { sign_in(manager) }

    it "displays edit form for a collaborator" do
      get edit_project_collaborator_path(project, developer)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Edit other')
    end

    context "when manager edits a collaborator" do
      it "shows role change form" do
        get edit_project_collaborator_path(project, developer)

        expect(response.body).to include('Change Role')
        expect(response.body).to include('Remove Collaborator')
      end
    end
  end

  describe "PATCH /projects/:project_id/collaborators/:id - role change" do
    let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before { sign_in(manager) }

    context "when manager changes a developer to manager" do
      it "updates the collaborator's role" do
        patch project_collaborator_path(project, developer), params: {
          collaborator: { role: 'manager' }
        }

        expect(response).to redirect_to(project_path(project))
        expect(developer.reload.role).to eq('manager')
      end

      it "displays success message" do
        patch project_collaborator_path(project, developer), params: {
          collaborator: { role: 'manager' }
        }

        follow_redirect!
        expect(response.body).to include('Collaborator role updated successfully')
      end
    end

    context "when trying to set invalid role" do
      it "does not update the role" do
        patch project_collaborator_path(project, developer), params: {
          collaborator: { role: 'invalid_role' }
        }

        expect(developer.reload.role).to eq('developer')
      end
    end
  end

  describe "DELETE /projects/:project_id/collaborators/:id - manager removal" do
    let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before { sign_in(manager) }

    context "when manager removes a collaborator" do
      it "destroys the collaborator record" do
        expect {
          delete project_collaborator_path(project, developer)
        }.to change(Collaborator, :count).by(-1)
      end

      it "redirects to project page" do
        delete project_collaborator_path(project, developer)

        expect(response).to redirect_to(project_path(project))
      end

      it "displays success message" do
        delete project_collaborator_path(project, developer)

        follow_redirect!
        expect(response.body).to include('has been removed from')
      end
    end
  end

  describe "authorization" do
    let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

    context "when not signed in" do
      it "redirects to login for show" do
        get project_collaborator_path(project, invite)
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login for edit" do
        get edit_project_collaborator_path(project, invite)
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login for update" do
        patch project_collaborator_path(project, invite)
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login for destroy" do
        delete project_collaborator_path(project, invite)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /projects/:project_id/collaborators (JSON API invite)" do
    let!(:user_to_invite) { User.create!(email_address: 'newinvite@example.com', username: 'newinvite', password: 'SecurePassword123') }

    context "when user is a manager" do
      before { sign_in(manager) }

      it "creates invitation with valid email and returns JSON success" do
        expect {
          post project_collaborators_path(project), params: { identifier: user_to_invite.email_address }
        }.to change(Collaborator, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['message']).to include(user_to_invite.username)
      end

      it "creates invitation with valid username and returns JSON success" do
        expect {
          post project_collaborators_path(project), params: { identifier: user_to_invite.username }
        }.to change(Collaborator, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['collaborator']['username']).to eq(user_to_invite.username)
        expect(json_response['collaborator']['role']).to eq('invited')
      end

      it "returns JSON error for non-existent user" do
        expect {
          post project_collaborators_path(project), params: { identifier: 'nonexistent@example.com' }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('No user found')
      end

      it "returns JSON error when inviting self" do
        expect {
          post project_collaborators_path(project), params: { identifier: manager.email_address }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('cannot invite yourself')
      end

      it "returns JSON error for already-invited user" do
        Collaborator.create!(user: user_to_invite, project: project, role: :invited)

        expect {
          post project_collaborators_path(project), params: { identifier: user_to_invite.email_address }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('already a collaborator')
      end

      it "returns JSON error for blank identifier" do
        expect {
          post project_collaborators_path(project), params: { identifier: '' }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('enter an email')
      end

      it "returns JSON error when identifier is nil" do
        expect {
          post project_collaborators_path(project), params: { identifier: nil }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when user is a developer" do
      let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

      before { sign_in(other_user) }

      it "returns JSON forbidden error" do
        expect {
          post project_collaborators_path(project), params: { identifier: user_to_invite.email_address }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('managers')
      end
    end

    context "when user is invited (view-only)" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(invited_user) }

      it "returns JSON forbidden error" do
        expect {
          post project_collaborators_path(project), params: { identifier: user_to_invite.email_address }
        }.not_to change(Collaborator, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "developer leaving project" do
    let!(:developer) { Collaborator.create!(user: other_user, project: project, role: :developer) }

    before { sign_in(other_user) }

    it "allows developer to remove themselves from project" do
      expect {
        delete project_collaborator_path(project, developer)
      }.to change(Collaborator, :count).by(-1)
    end

    it "unassigns tasks when developer leaves" do
      task = Task.create!(
        title: 'Assigned Task',
        description: 'Description',
        status: :in_progress,
        project: project,
        assignee: developer
      )

      delete project_collaborator_path(project, developer)

      expect(task.reload.assignee_id).to be_nil
    end
  end
end
