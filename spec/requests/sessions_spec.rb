require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:user) { User.create!(email_address: 'test@example.com', username: 'testuser', password: 'SecurePassword123') }

  describe "GET /session/new" do
    it "renders the login page" do
      get new_session_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Sign in")
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "logs in and redirects to projects" do
        post session_path, params: { email_address: user.email_address, password: 'SecurePassword123' }

        expect(response).to redirect_to(projects_path)
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "creates a session" do
        expect {
          post session_path, params: { email_address: user.email_address, password: 'SecurePassword123' }
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid password" do
      it "does not log in and shows error" do
        post session_path, params: { email_address: user.email_address, password: 'wrongpassword' }

        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(response.body).to include("Try another email address or password")
      end

      it "does not create a session" do
        expect {
          post session_path, params: { email_address: user.email_address, password: 'wrongpassword' }
        }.not_to change(Session, :count)
      end
    end

    context "with non-existent email" do
      it "does not log in and shows error" do
        post session_path, params: { email_address: 'nonexistent@example.com', password: 'SecurePassword123' }

        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(response.body).to include("Try another email address or password")
      end
    end
  end

  describe "DELETE /session" do
    before do
      post session_path, params: { email_address: user.email_address, password: 'SecurePassword123' }
    end

    it "logs out and redirects to root" do
      delete session_path

      expect(response).to redirect_to(root_path)
    end

    it "destroys the session" do
      expect {
        delete session_path
      }.to change(Session, :count).by(-1)
    end
  end

  describe "authentication requirement" do
    it "redirects to login when accessing protected routes without authentication" do
      get projects_path

      expect(response).to redirect_to(new_session_path)
    end

    it "allows access to protected routes when authenticated" do
      post session_path, params: { email_address: user.email_address, password: 'SecurePassword123' }

      get projects_path

      expect(response).to have_http_status(:success)
    end
  end
end
