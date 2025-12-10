require 'rails_helper'

RSpec.describe "Edit user", type: :request do
  let (:user) do
    user = User.create(email_address: "edit@test.com", username: "edit", password: "test")
    post "/session", params: { email_address: user.email_address, password: user.password }
    user
  end

  it "renders the edit page" do
    @user = user

    get edit_user_path(@user)

    expect(response).to have_http_status(:success)
  end

  it "redirects me to projects upon successful edit" do
    @user = user

    patch user_path(@user), params: { user: { email_address: "other@other.com", username: "other", password: "other", password_confirmation: "other" } }

    expect(response).to have_http_status(:see_other)
  end

  it "redirects me to the edit page upon unsuccessful edit" do
    @user = user

    patch user_path(@user), params: { user: { email_address: "notanemail", username: "other", password: "other", password_confirmation: "other" } }

    expect(response).to have_http_status(:bad_request)
  end
end
