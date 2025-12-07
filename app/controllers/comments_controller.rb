class CommentsController < ApplicationController
  before_action :set_project_and_task

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = Current.user
    if @comment.save
      redirect_to project_task_path(@project, @task), notice: "Comment added."
    else
      redirect_to project_task_path(@project, @task), alert: "Failed to add comment."
    end
  end

  def destroy
    @comment = @task.comments.find(params[:id])
    if @comment.user == Current.user || @project.collaborators.find_by(user: Current.user)&.role == "manager"
       @comment.destroy
       redirect_to project_task_path(@project, @task), notice: "Comment deleted."
    else
       redirect_to project_task_path(@project, @task), alert: "Not authorized."
    end
  end

  private

  def set_project_and_task
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
