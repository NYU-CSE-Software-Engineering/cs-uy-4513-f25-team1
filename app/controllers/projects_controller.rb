class ProjectsController < ApplicationController
  before_action :set_project, only: :show

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(name: params[:name], wip_limit: params[:wip_limit])
    @project.save!
  end

  def show
  end

  private

  def set_project
    @project = Project.find(params[:id]) # use :id not :project_id
  end
end
