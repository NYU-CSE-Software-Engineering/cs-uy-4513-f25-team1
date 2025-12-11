require 'rails_helper'

RSpec.describe "Edit user", type: :request do
  let (:user) do
    user = User.create!(email_address: "edit@test.com", username: "edit", password: "password123")
    post "/session", params: { email_address: user.email_address, password: "password123" }
    user
  end

  it "renders the edit page" do
    @user = user

    get edit_user_path(@user)

    expect(response).to have_http_status(:success)
  end

  it "redirects me to projects upon successful edit" do
    @user = user

    patch user_path(@user), params: { user: { email_address: "other@other.com", username: "other", password: "newpassword123", password_confirmation: "newpassword123" } }

    expect(response).to have_http_status(:see_other)
  end

  it "redirects me to the edit page upon unsuccessful edit" do
    @user = user

    patch user_path(@user), params: { user: { email_address: "notanemail", username: "other", password: "newpassword123", password_confirmation: "newpassword123" } }

    expect(response).to have_http_status(:bad_request)
  end
end
