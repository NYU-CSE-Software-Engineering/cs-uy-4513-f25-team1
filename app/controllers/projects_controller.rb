class ProjectsController < ApplicationController
  before_action :set_project, only: :show
  before_action :set_user

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(name: params[:project][:name], wip_limit: params[:project][:wip_limit], description: params[:project][:description])
    valid = @project.save
    if !valid then
      if @project.errors[:name] then
        flash[:name_error] = "Name can't be blank"
      end
      if @project.errors[:wip_limit] then
        flash[:wip_limit_error] = "WIP limit must be 0 or greater"
      end
      redirect_to new_project_path
    else
      collaborator = Collaborator.new(user_id: session[:user_id], project_id: @project.id, role: "owner")
      collaborator.save!
      flash[:created] = "Project was successfully created."
    end
    redirect_to project_path(@project.id)
  end

  def show
  end

  private

  def set_project
    @project = Project.find(params[:id]) # use :id not :project_id
  end

  def set_user
    @user = session[:user_id]
  end
end
