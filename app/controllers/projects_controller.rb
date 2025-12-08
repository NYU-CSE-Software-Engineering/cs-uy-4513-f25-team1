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
    # if name is duplicate of another project owned by the user then valid is false as well
    duplicate_project = Collaborator.where(user_id: @user, role: "manager").joins(:project).where(projects: { name: @project.name }).exists?
    if !valid or duplicate_project then
      if @project.errors[:name] then
        flash[:name_error] = "Name can't be blank"
      end
      if duplicate_project then
        flash[:name_duplicate_error] = "Name has already been taken"
      end
      if @project.errors[:wip_limit] then
        flash[:wip_limit_error] = "WIP limit must be 0 or greater"
      end
      redirect_to new_project_path
      return
    else
      collaborator = Collaborator.new(user_id: session[:user_id], project_id: @project.id, role: "owner")
      collaborator.save!
      flash[:created] = "Project was successfully created."
    end
    redirect_to project_path(@project.id)
  end

  def show
    @tasks = @project.tasks

    # Filter by type if specified
    if params[:type].present? && %w[Feature Bug Backlog].include?(params[:type])
      @tasks = @tasks.where(type: params[:type])
    end

    # Filter by status if specified
    valid_statuses = [ "To Do", "In Progress", "In Review", "Completed" ]
    if params[:status].present? && valid_statuses.include?(params[:status])
      @tasks = @tasks.where(status: params[:status])
    end

    # Determine sort direction (default: asc = early to late)
    sort_direction = params[:direction] == "desc" ? :desc : :asc

    # Sort tasks based on filter parameter
    case params[:filter]
    when "date_modified"
      @tasks = @tasks.order(updated_at: sort_direction)
    else
      # Default: sort by date created
      @tasks = @tasks.order(created_at: sort_direction)
    end

    @current_filter = params[:filter] || "date_created"
    @current_direction = params[:direction] || "asc"
    @current_type = params[:type]
    @current_status = params[:status]
  end

  private

  def set_project
    @project = Project.find(params[:id]) # use :id not :project_id
  end

  def set_user
    @user = session[:user_id]
  end
end
