class ProjectsController < ApplicationController
  before_action :set_project, only: :show

  def show
  end

  private

  def set_project
    @project = Project.find(params[:id]) # ← 用 :id，不是 :project_id
  end
end
