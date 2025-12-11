class CommentsController < ApplicationController
  before_action :set_project
  before_action :set_task
  before_action :set_collaborator
  before_action :authorize_commenter
  before_action :set_comment, only: [ :update, :destroy ]
  before_action :authorize_comment_author, only: [ :update, :destroy ]
  before_action :verify_task_not_completed

  def create
    @comment = @task.comments.build(comment_params)
    @comment.collaborator = @collaborator

    if @comment.save
      return_task_to_in_progress_if_manager_review_comment
      redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                  notice: "Comment added.",
                  status: :see_other
    else
      redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                  alert: @comment.errors.full_messages.join(", "),
                  status: :see_other
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to project_task_path(@project, @task, anchor: "comment-#{@comment.id}"),
                  notice: "Comment updated.",
                  status: :see_other
    else
      redirect_to project_task_path(@project, @task, anchor: "comment-#{@comment.id}"),
                  alert: @comment.errors.full_messages.join(", "),
                  status: :see_other
    end
  end

  def destroy
    @comment.destroy
    redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                notice: "Comment deleted.",
                status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def set_collaborator
    @collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def authorize_commenter
    unless @collaborator && %w[manager developer].include?(@collaborator.role)
      redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                  alert: "Only managers and developers can comment on tasks."
    end
  end

  def authorize_comment_author
    unless @comment.authored_by?(@collaborator)
      redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                  alert: "You can only edit or delete your own comments."
    end
  end

  def verify_task_not_completed
    if @task.completed_at.present?
      redirect_to project_task_path(@project, @task, anchor: "comments-section"),
                  alert: "Cannot add comments to completed tasks."
    end
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def return_task_to_in_progress_if_manager_review_comment
    return unless @collaborator.manager? && @task.in_review?

    @task.update!(status: :in_progress)
  end
end
