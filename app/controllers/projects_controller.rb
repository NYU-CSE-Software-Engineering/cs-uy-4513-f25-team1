class ProjectsController < ApplicationController
  def show
    @project = Project.find_by(params[:id])
  end
end
