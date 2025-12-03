class CommentsController < ApplicationController
  before_action :set_project
  before_action :set_task

  def create
    @comment = @task.comments.build(comment_params)

    if @comment.save
      redirect_to project_task_path(@project, @task), notice: "Comment added."
    else
      redirect_to project_task_path(@project, @task), alert: "Failed to add comment."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
