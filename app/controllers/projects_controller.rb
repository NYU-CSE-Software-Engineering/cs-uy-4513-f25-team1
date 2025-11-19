class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: :show

  def index
    @projects = current_user.projects
  end

  def show
  end

  private

  def set_project
    @project = Project.find(params[:id]) # ← 用 :id，不是 :project_id
  end
end
