class ChecklistItemsController < ApplicationController
  before_action :set_project_and_task

  def create
    @checklist_item = @task.checklist_items.build(checklist_item_params)
    if @checklist_item.save
      redirect_to project_task_path(@project, @task), notice: "Item added."
    else
      redirect_to project_task_path(@project, @task), alert: "Failed to add item."
    end
  end

  def update
    @checklist_item = @task.checklist_items.find(params[:id])
    @checklist_item.update(checklist_item_params)
    # Respond to turbo stream or html
    redirect_to project_task_path(@project, @task)
  end

  def destroy
    @checklist_item = @task.checklist_items.find(params[:id])
    @checklist_item.destroy
    redirect_to project_task_path(@project, @task), notice: "Item removed."
  end

  private

  def set_project_and_task
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find(params[:task_id])
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:content, :completed)
  end
end
