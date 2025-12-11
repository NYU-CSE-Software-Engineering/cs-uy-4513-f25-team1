class CollaboratorsController < ApplicationController
  before_action :set_project
  before_action :set_collaborator, only: [ :show, :edit, :update, :destroy ]
  before_action :set_current_user_role, only: [ :show, :edit, :update, :destroy, :create ]
  before_action :authorize_edit, only: [ :edit ]
  before_action :authorize_update_or_destroy, only: [ :update, :destroy ]
  before_action :authorize_manager, only: [ :create ]

  def show
    @collaborator_tasks = @project.tasks.where(assignee_id: @collaborator.id)
    @tasks_by_status = {
      "In Progress" => @collaborator_tasks.where(status: :in_progress),
      "In Review" => @collaborator_tasks.where(status: :in_review),
      "Completed" => @collaborator_tasks.where(status: :completed)
    }

    load_metrics_data unless @collaborator.invited?
  end

  def edit
    # Just renders the edit form
  end

  def create
    identifier = params[:identifier]&.strip

    if identifier.blank?
      render json: { success: false, error: "Please enter an email address or username." }, status: :unprocessable_entity
      return
    end

    user = User.find_by(email_address: identifier) || User.find_by(username: identifier)

    if user.nil?
      render json: { success: false, error: "No user found with that email or username." }, status: :not_found
      return
    end

    if user.id == Current.session&.user_id
      render json: { success: false, error: "You cannot invite yourself." }, status: :unprocessable_entity
      return
    end

    existing = @project.collaborators.find_by(user_id: user.id)
    if existing
      render json: { success: false, error: "#{user.username} is already a collaborator on this project." }, status: :unprocessable_entity
      return
    end

    collaborator = @project.collaborators.create(user: user, role: :invited)

    if collaborator.persisted?
      render json: {
        success: true,
        message: "Invitation sent to #{user.username}.",
        collaborator: {
          id: collaborator.id,
          username: user.username,
          role: collaborator.role
        }
      }, status: :created
    else
      render json: { success: false, error: collaborator.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def update
    # Handle invitation acceptance (existing functionality)
    if @collaborator.invited? && @collaborator.user_id == Current.session.user_id
      @collaborator.developer!
      flash[:notice] = "You have joined #{@project.name} as a developer."
      redirect_back fallback_location: projects_path
      return
    end

    # If not accepting invitation but still invited status
    if @collaborator.invited?
      flash[:alert] = "This invitation is no longer valid."
      redirect_back fallback_location: projects_path
      return
    end

    # Handle role change (manager only)
    if params[:collaborator] && params[:collaborator][:role]
      new_role = params[:collaborator][:role]
      if [ "manager", "developer" ].include?(new_role)
        @collaborator.update(role: new_role)
        flash[:notice] = "Collaborator role updated successfully."
      else
        flash[:alert] = "Invalid role."
      end
    end

    redirect_to project_path(@project)
  end

  def destroy
    # Handle invitation decline (existing functionality)
    if @collaborator.invited? && @collaborator.user_id == Current.session.user_id
      @collaborator.destroy
      flash[:notice] = "You have declined the invitation to #{@project.name}."
      redirect_back fallback_location: projects_path
      return
    end

    # Unassign all tasks from this collaborator before removal
    @project.tasks.where(assignee_id: @collaborator.id).update_all(assignee_id: nil)

    # Handle collaborator removal (manager only)
    user_to_remove = @collaborator.user
    @collaborator.destroy
    flash[:notice] = "#{user_to_remove.username} has been removed from #{@project.name}."
    redirect_to project_path(@project)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_collaborator
    @collaborator = @project.collaborators.find(params[:id])
  end

  def set_current_user_role
    @current_collaborator = @project.collaborators.find_by(user_id: Current.session&.user_id)
    @current_user_role = @current_collaborator&.role
  end

  def authorize_edit
    # Managers can edit anyone, developers can only edit themselves
    is_manager = @current_user_role == "manager"
    is_self = @collaborator.user_id == Current.session&.user_id

    unless is_manager || is_self
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to project_path(@project)
    end
  end

  def authorize_update_or_destroy
    # Allow invitation acceptance/decline (user acting on their own invitation)
    if @collaborator.user_id == Current.session&.user_id
      return
    end

    # Otherwise, only managers can update/destroy other collaborators
    unless @current_user_role == "manager"
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to projects_path
    end
  end

  def authorize_manager
    unless @current_user_role == "manager"
      render json: { success: false, error: "Only managers can invite collaborators." }, status: :forbidden
    end
  end

  def load_metrics_data
    @metrics = {
      avg_completion_time: @collaborator.avg_completion_time_days,
      on_time_rate: @collaborator.on_time_completion_rate,
      overdue_count: @collaborator.overdue_task_count,
      avg_days_overdue: @collaborator.avg_days_overdue,
      weekly_velocity: @collaborator.weekly_velocity,
      monthly_velocity: @collaborator.monthly_velocity,
      completion_rate: @collaborator.completion_rate,
      days_on_project: @collaborator.days_on_project,
      tasks_per_day: @collaborator.tasks_per_day,
      days_since_completion: @collaborator.days_since_last_completion,
      current_wip: @collaborator.current_wip_count,
      stale_tasks: @collaborator.stale_task_count,
      total_comments: @collaborator.total_comments_count,
      avg_comments_per_task: @collaborator.avg_comments_per_task,
      high_priority_rate: @collaborator.high_priority_completion_rate,
      open_urgent: @collaborator.open_urgent_task_count
    }

    @priority_breakdown = @collaborator.priority_breakdown
    @type_breakdown = @collaborator.type_breakdown
    @velocity_trend = @collaborator.weekly_velocity_trend
    @completion_time_by_type = @collaborator.avg_completion_time_by_type
  end
end
