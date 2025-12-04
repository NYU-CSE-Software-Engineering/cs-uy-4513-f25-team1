class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update ]

  def index
    @tasks = @project.tasks.order(status: :asc, priority: :desc)
  end

  def show
    @comments = @task.comments.includes(:user).order(created_at: :asc)
    @comment = Comment.new
  end

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.user = current_user # Ensure user is assigned

    if @task.save
      redirect_to project_task_path(@project, @task),
                  notice: "Task was successfully created."
    else
      flash.now[:alert] = "Task could not be created."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    target_status = task_params[:status]

    if moving_to_in_progress?(target_status) && wip_reached?
      redirect_to edit_project_task_path(@project, @task),
                  alert: "WIP limit has been reached for this project.",
                  status: :see_other
    else
      if @task.update(task_params)
        redirect_to project_task_path(@project, @task),
                    notice: "Task updated.",
                    status: :see_other
      else
        flash.now[:alert] = "Task could not be updated."
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @task.destroy
    redirect_to project_tasks_path(@project), notice: "Task was successfully destroyed."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :status, :description, :github_branch, :priority, attachments: [])
  end

  def project_wip_limit
    @project.get_task_limit
  end

  def moving_to_in_progress?(target_status)
    target_status == "in_progress"
  end

  def wip_reached?
    limit = project_wip_limit.to_i
    return false if limit <= 0
    current_in_progress = @project.tasks
                                  .where(status: "in_progress")
                                  .where.not(id: @task.id)
                                  .count
    current_in_progress >= limit
  end
end
