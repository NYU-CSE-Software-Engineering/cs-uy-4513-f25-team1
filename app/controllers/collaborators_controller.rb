class CollaboratorsController < ApplicationController
  before_action :set_collaborator

  def update
    if @collaborator.invited?
      @collaborator.developer!
      flash[:notice] = "You have joined #{@collaborator.project.name} as a developer."
    else
      flash[:alert] = "This invitation is no longer valid."
    end
    redirect_back fallback_location: projects_path
  end

  def destroy
    project_name = @collaborator.project.name
    @collaborator.destroy
    flash[:notice] = "You have declined the invitation to #{project_name}."
    redirect_back fallback_location: projects_path
  end

  private

  def set_collaborator
    @collaborator = Collaborator.find(params[:id])
    unless @collaborator.user_id == Current.session.user_id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to projects_path
    end
  end
end
