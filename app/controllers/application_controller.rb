class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :load_sidebar_data

  private

  def load_sidebar_data
    resume_session
    if Current.user
      @sidebar_manager_projects = Current.user.manager_projects
      @sidebar_developer_projects = Current.user.developer_projects
    end
  end
end
