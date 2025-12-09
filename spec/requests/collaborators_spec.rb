require 'rails_helper'

RSpec.describe "Collaborators", type: :request do
  let(:manager) { User.create!(email_address: 'manager@example.com', username: 'manager', password: 'SecurePassword123') }
  let(:invited_user) { User.create!(email_address: 'invited@example.com', username: 'invited', password: 'SecurePassword123') }
  let(:other_user) { User.create!(email_address: 'other@example.com', username: 'other', password: 'SecurePassword123') }
  let(:project) { Project.create!(name: 'Test Project', wip_limit: 3) }

  before do
    Collaborator.create!(user: manager, project: project, role: :manager)
  end

  def sign_in(user)
    post "/session", params: { email_address: user.email_address, password: 'SecurePassword123' }
  end

  describe "PATCH /collaborators/:id" do
    context "when user is the invited collaborator" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(invited_user) }

      it "changes role from invited to developer" do
        expect {
          patch collaborator_path(invite)
        }.to change { invite.reload.role }.from("invited").to("developer")
      end

      it "redirects with success notice" do
        patch collaborator_path(invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq("You have joined #{project.name} as a developer.")
      end

      it "does not destroy the collaborator record" do
        expect {
          patch collaborator_path(invite)
        }.not_to change(Collaborator, :count)
      end
    end

    context "when collaborator is not in invited status" do
      let!(:developer_collab) { Collaborator.create!(user: invited_user, project: project, role: :developer) }

      before { sign_in(invited_user) }

      it "does not change the role" do
        expect {
          patch collaborator_path(developer_collab)
        }.not_to change { developer_collab.reload.role }
      end

      it "sets an alert flash message" do
        patch collaborator_path(developer_collab)
        expect(flash[:alert]).to eq("This invitation is no longer valid.")
      end
    end

    context "when user tries to accept another user's invite" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(other_user) }

      it "redirects with authorization error" do
        patch collaborator_path(invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not change the invite status" do
        expect {
          patch collaborator_path(invite)
        }.not_to change { invite.reload.role }
      end
    end
  end

  describe "DELETE /collaborators/:id" do
    context "when user is the invited collaborator" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(invited_user) }

      it "destroys the collaborator record" do
        expect {
          delete collaborator_path(invite)
        }.to change(Collaborator, :count).by(-1)
      end

      it "redirects with success notice" do
        delete collaborator_path(invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:notice]).to eq("You have declined the invitation to #{project.name}.")
      end

      it "removes the user from the project collaborators" do
        delete collaborator_path(invite)
        expect(Collaborator.find_by(user: invited_user, project: project)).to be_nil
      end
    end

    context "when user tries to reject another user's invite" do
      let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

      before { sign_in(other_user) }

      it "redirects with authorization error" do
        delete collaborator_path(invite)
        expect(response).to redirect_to(projects_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end

      it "does not destroy the collaborator record" do
        expect {
          delete collaborator_path(invite)
        }.not_to change(Collaborator, :count)
      end
    end
  end

  describe "authorization" do
    let!(:invite) { Collaborator.create!(user: invited_user, project: project, role: :invited) }

    context "when not signed in" do
      it "redirects to login for update" do
        patch collaborator_path(invite)
        expect(response).to redirect_to(new_session_path)
      end

      it "redirects to login for destroy" do
        delete collaborator_path(invite)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
