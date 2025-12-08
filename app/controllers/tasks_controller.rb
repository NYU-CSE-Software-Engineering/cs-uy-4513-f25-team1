class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [ :edit, :update ]
  before_action :require_manager_role, only: [ :new, :create ]

  def index
    @tasks = @project.tasks
    @is_manager = manager_for_project?
  end

  helper_method :manager_for_project?

  def new
    @task = @project.tasks.build
    @collaborators = @project.collaborators
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to project_tasks_path(@project),
                  notice: "Task was successfully created.",
                  status: :see_other
    else
      @collaborators = @project.collaborators
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
        redirect_to edit_project_task_path(@project, @task),
                    notice: "Task updated.",
                    status: :see_other
      else
        flash.now[:alert] = "Task could not be updated."
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_at, :priority, :assignee, :branch_link)
  end

  def require_manager_role
    unless manager_for_project?
      redirect_to project_tasks_path(@project),
                  alert: "Only managers can create tasks.",
                  status: :see_other
    end
  end

  def manager_for_project?
    user_id = session[:user_id]
    user_id && Collaborator.exists?(user_id: user_id, project_id: @project.id, role: "manager")
  end

  def project_wip_limit
    @project.get_task_limit
  end

  def moving_to_in_progress?(target_status)
    target_status == "In Progress"
  end

  def wip_reached?
    limit = project_wip_limit.to_i
    return false if limit <= 0
    current_in_progress = @project.tasks
                                  .where(status: "In Progress")
                                  .where.not(id: @task.id)
                                  .count
    current_in_progress >= limit
  end
end
