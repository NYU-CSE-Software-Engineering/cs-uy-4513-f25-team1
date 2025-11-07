class TasksController < ApplicationController
  before_action :set_project, if: -> { params[:project_id].present? }

  def index
    if @project
      @tasks = @project.tasks
    else
      @tasks = Task.all
    end
  end

  def new
    if @project
      @task = @project.tasks.build
    else
      @task = Task.new
    end
  end

  def create
    if @project
      @task = @project.tasks.build(task_params)
    else
      @task = Task.new(task_params)
    end
  
    if @task.save
      if @project
        redirect_to project_tasks_path(@project),
                    notice: "Task was successfully created.",
                    status: :see_other
      else
        redirect_to tasks_path,
                    notice: "Task was successfully created.",
                    status: :see_other 
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :status)
  end
end
