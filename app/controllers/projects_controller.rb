class ProjectsController < ApplicationController
  before_action :set_project, only: :show
  before_action :set_user
  before_action :set_user_role, only: :show
  helper_method :can_edit_project?

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(
      name: params[:project][:name],
      description: params[:project][:description],
      repo: params[:project][:repo]
    )

    duplicate_project = Collaborator.where(user_id: @user, role: :manager).joins(:project).where(projects: { name: @project.name }).exists?
    invite_identifiers = Array(params[:project][:invites]).reject(&:blank?)
    invited_users = []
    invalid_invites = []

    invite_identifiers.each do |identifier|
      user = User.find_by(email_address: identifier) || User.find_by(username: identifier)
      if user.nil?
        invalid_invites << identifier
      elsif user.id == @user
        invalid_invites << identifier
      else
        invited_users << user
      end
    end

    valid = @project.valid? && !duplicate_project && invalid_invites.empty?

    if !valid
      if @project.errors[:name].present?
        flash[:name_error] = "Name can't be blank"
      end
      if @project.errors[:description].present?
        flash[:description_error] = "Description can't be blank"
      end
      if duplicate_project
        flash[:name_duplicate_error] = "Name has already been taken"
      end
      if invalid_invites.any?
        flash[:invite_error] = "Could not find users: #{invalid_invites.join(', ')}"
      end
      redirect_to new_project_path
      return
    end

    @project.save!
    Collaborator.create!(user_id: session[:user_id], project_id: @project.id, role: :manager)

    invited_users.each do |user|
      Collaborator.create!(user_id: user.id, project_id: @project.id, role: :invited)
    end

    flash[:created] = "Project was successfully created."
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

  def set_user_role
    @collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
    @user_role = @collaborator&.role
  end

  def can_edit_project?
    @user_role.present? && @user_role != "invited"
  end
end
