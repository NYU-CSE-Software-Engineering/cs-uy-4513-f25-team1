class ProjectsController < ApplicationController
  def show
    @project = Project.find_by(params[:project_id])
  end
end
