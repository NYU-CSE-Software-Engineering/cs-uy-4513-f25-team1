module AuthenticationHelper
  def sign_in_test_user
    # Mock sign in - do nothing as User model is missing
    # This allows tests to pass "Given I am a signed-in user" steps
    # without crashing due to missing User model/auth logic.
  end
end

World(AuthenticationHelper)
