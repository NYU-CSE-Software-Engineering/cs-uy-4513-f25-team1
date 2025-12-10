class CollaboratorsController < ApplicationController
  before_action :set_project
  before_action :set_collaborator, only: [ :show, :edit, :update, :destroy ]
  before_action :set_current_user_role, only: [ :index, :show, :edit, :update, :destroy ]
  before_action :authorize_edit, only: [ :edit ]
  before_action :authorize_update_or_destroy, only: [ :update, :destroy ]

  def index
    @collaborators = @project.collaborators.includes(:user)
  end

  def show
    @collaborator_tasks = @project.tasks.where(user_id: @collaborator.user_id)
    @tasks_by_status = {
      "In Progress" => @collaborator_tasks.where(status: "In Progress"),
      "In Review" => @collaborator_tasks.where(status: "In Review"),
      "Completed" => @collaborator_tasks.where(status: "Completed")
    }
  end

  def edit
    # Just renders the edit form
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

    redirect_to project_collaborators_path(@project)
  end

  def destroy
    # Handle invitation decline (existing functionality)
    if @collaborator.invited? && @collaborator.user_id == Current.session.user_id
      @collaborator.destroy
      flash[:notice] = "You have declined the invitation to #{@project.name}."
      redirect_back fallback_location: projects_path
      return
    end

    # Handle collaborator removal (manager only)
    user_to_remove = @collaborator.user
    @collaborator.destroy
    flash[:notice] = "#{user_to_remove.username} has been removed from #{@project.name}."
    redirect_to project_collaborators_path(@project)
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
      redirect_to project_collaborators_path(@project)
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
end
