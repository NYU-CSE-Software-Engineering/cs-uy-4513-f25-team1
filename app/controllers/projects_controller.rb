class ProjectsController < ApplicationController
  def index
    @manager_projects = Current.user.manager_projects
    @developer_projects = Current.user.developer_projects
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      Collaborator.create!(project: @project, user: Current.user, role: "manager")
      redirect_to @project, notice: "Project created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join_page
  end

  def join
    project = Project.find_by(key: params[:key])

    if project
      if project.users.include?(Current.user)
        redirect_to project, alert: "You are already a member of this project."
      else
        Collaborator.create!(project: project, user: Current.user, role: "developer")
        redirect_to project, notice: "Successfully joined #{project.name}!"
      end
    else
      flash.now[:alert] = "Invalid project key."
      render :join_page, status: :unprocessable_entity
    end
  end
  before_action :set_project, only: :show

  def show
    @collaborators = @project.collaborators.includes(:user)
    @tasks = @project.tasks.includes(:user).ordered

    if params[:sort] == "due_date"
      @tasks = @tasks.reorder(due_date: :asc)
    elsif params[:sort] == "urgency"
      @tasks = @tasks.reorder(priority: :desc)
    end
  end

  private


  def set_project
    @project = Project.find(params[:id]) # ← 用 :id，不是 :project_id
  end

  def project_params
    params.require(:project).permit(:name, :key, :description)
  end
end
