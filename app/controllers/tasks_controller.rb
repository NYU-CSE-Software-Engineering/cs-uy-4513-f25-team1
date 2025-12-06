class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [ :edit, :update ]

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to new_project_task_path(@project),
                  notice: "Task was successfully created.",
                  status: :see_other
    else
      flash.now[:alert] = "Task could not be created."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to edit_project_task_path(@project, @task),
                  notice: "Task updated.",
                  status: :see_other
    else
      flash.now[:alert] = "Task could not be updated."
      render :edit, status: :unprocessable_entity
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
    params.require(:task).permit(:title, :status)
  end
end
