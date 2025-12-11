require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users/new (registration page)" do
    it "renders the registration page" do
      get new_user_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users (registration)" do
    context "with valid attributes" do
      it "creates a new user" do
        expect {
          post users_path, params: {
            user: {
              email_address: "newuser@example.com",
              username: "newuser",
              password: "SecurePassword123",
              password_confirmation: "SecurePassword123"
            }
          }
        }.to change(User, :count).by(1)
      end

      it "redirects to projects after successful registration" do
        post users_path, params: {
          user: {
            email_address: "newuser@example.com",
            username: "newuser",
            password: "SecurePassword123",
            password_confirmation: "SecurePassword123"
          }
        }

        expect(response).to redirect_to(projects_path)
      end

      it "logs in the user after registration" do
        post users_path, params: {
          user: {
            email_address: "newuser@example.com",
            username: "newuser",
            password: "SecurePassword123",
            password_confirmation: "SecurePassword123"
          }
        }

        expect(Session.count).to eq(1)
      end
    end

    context "with invalid email format" do
      it "does not create a user" do
        expect {
          post users_path, params: {
            user: {
              email_address: "not-an-email",
              username: "newuser",
              password: "SecurePassword123",
              password_confirmation: "SecurePassword123"
            }
          }
        }.not_to change(User, :count)
      end

      it "re-renders the registration form" do
        post users_path, params: {
          user: {
            email_address: "not-an-email",
            username: "newuser",
            password: "SecurePassword123",
            password_confirmation: "SecurePassword123"
          }
        }

        expect(response).to have_http_status(:ok)
      end
    end

    context "with duplicate email" do
      before do
        User.create!(email_address: "existing@example.com", username: "existing", password: "SecurePassword123")
      end

      it "does not create a user with duplicate email" do
        expect {
          post users_path, params: {
            user: {
              email_address: "existing@example.com",
              username: "newuser",
              password: "SecurePassword123",
              password_confirmation: "SecurePassword123"
            }
          }
        }.not_to change(User, :count)
      end
    end

    context "with password too short" do
      it "does not create a user" do
        expect {
          post users_path, params: {
            user: {
              email_address: "newuser@example.com",
              username: "newuser",
              password: "short",
              password_confirmation: "short"
            }
          }
        }.not_to change(User, :count)
      end
    end

    context "with mismatched password confirmation" do
      it "does not create a user" do
        expect {
          post users_path, params: {
            user: {
              email_address: "newuser@example.com",
              username: "newuser",
              password: "SecurePassword123",
              password_confirmation: "DifferentPassword123"
            }
          }
        }.not_to change(User, :count)
      end
    end

    context "without password" do
      it "does not create a user" do
        expect {
          post users_path, params: {
            user: {
              email_address: "newuser@example.com",
              username: "newuser",
              password: "",
              password_confirmation: ""
            }
          }
        }.not_to change(User, :count)
      end
    end
  end

  describe "GET /users/:id/edit" do
    let(:user) do
      user = User.create!(email_address: "edit@test.com", username: "edit", password: "password123")
      post "/session", params: { email_address: user.email_address, password: "password123" }
      user
    end

    it "renders the edit page" do
      @user = user

      get edit_user_path(@user)

      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /users/:id" do
    let(:user) do
      user = User.create!(email_address: "edit@test.com", username: "edit", password: "password123")
      post "/session", params: { email_address: user.email_address, password: "password123" }
      user
    end

    it "redirects to projects upon successful edit" do
      @user = user

      patch user_path(@user), params: {
        user: {
          email_address: "other@other.com",
          username: "other",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to have_http_status(:see_other)
    end

    it "updates the user's email" do
      @user = user

      patch user_path(@user), params: {
        user: {
          email_address: "updated@example.com",
          username: @user.username,
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(@user.reload.email_address).to eq("updated@example.com")
    end

    it "returns bad request for invalid email" do
      @user = user

      patch user_path(@user), params: {
        user: {
          email_address: "notanemail",
          username: "other",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns bad request for password too short" do
      @user = user

      patch user_path(@user), params: {
        user: {
          email_address: @user.email_address,
          username: @user.username,
          password: "short",
          password_confirmation: "short"
        }
      }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
