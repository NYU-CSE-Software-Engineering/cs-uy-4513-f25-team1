class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [ :edit, :update ]

  def new
    @task = @project.tasks.build
  end

  def show
    @checklist_item = ChecklistItem.new
    @comment = Comment.new
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.status = @task.user.present? ? :in_progress : :todo

    if @task.save
      redirect_to project_path(@project), notice: "Task created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to project_task_path(@project, @task), notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def request_review
    @task.review!
    redirect_to project_task_path(@project, @task), notice: "Review requested."
  end

  def mark_complete
    @task.done!
    redirect_to project_task_path(@project, @task), notice: "Task marked as complete."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :github_branch, :user_id, files: [])
  end
end
