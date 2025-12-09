class CollaboratorsController < ApplicationController
  before_action :set_project
  before_action :set_collaborator

  def update
    if @collaborator.invited?
      @collaborator.developer!
      flash[:notice] = "You have joined #{@project.name} as a developer."
    else
      flash[:alert] = "This invitation is no longer valid."
    end
    redirect_back fallback_location: projects_path
  end

  def destroy
    @collaborator.destroy
    flash[:notice] = "You have declined the invitation to #{@project.name}."
    redirect_back fallback_location: projects_path
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_collaborator
    @collaborator = @project.collaborators.find(params[:id])
    unless @collaborator.user_id == Current.session.user_id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to projects_path
    end
  end
end
