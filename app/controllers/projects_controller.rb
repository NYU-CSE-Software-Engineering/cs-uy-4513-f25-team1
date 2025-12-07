class ProjectsController < ApplicationController
  before_action :set_project, only: :show

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(name: params[:project][:name], wip_limit: params[:project][:wip_limit])
    valid = @project.save
    if !valid then
      flash[:error] = "some error happened"
    end
    redirect_to new_project_path
  end

  def show
  end

  private

  def set_project
    @project = Project.find(params[:id]) # use :id not :project_id
  end
end
