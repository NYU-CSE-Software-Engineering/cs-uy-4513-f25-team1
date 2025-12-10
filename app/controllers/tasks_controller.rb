class TasksController < ApplicationController
  class TaskNotFoundError < StandardError; end

  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update ]
  before_action :authorize_project_edit

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.user = Current.user

    if @task.save
      redirect_to new_project_task_path(@project),
                  notice: "Task was successfully created.",
                  status: :see_other
    else
      flash.now[:alert] = "Task could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def edit
  end

  def update
    params_hash = params[:task] || {}
    remove_media_file_ids = Array(params_hash[:remove_media_file_ids]).reject(&:blank?)

    if remove_media_file_ids.any?
      remove_media_file_ids.each do |attachment_id|
        attachment = ActiveStorage::Attachment.find_by(id: attachment_id)
        if attachment && attachment.record == @task
          attachment.purge
        end
      end
    end

    redirect_to_show = params[:redirect_to_show] == "1"
    update_params = task_params.except(:remove_media_file_ids)
    update_successful = @task.update(update_params)

    if update_successful
      redirect_path = redirect_to_show ? project_task_path(@project, @task) : edit_project_task_path(@project, @task)
      notice_message = if remove_media_file_ids.any?
        "Media file removed."
      elsif redirect_to_show
        "Media files uploaded."
      else
        "Task updated."
      end
      redirect_to redirect_path,
                  notice: notice_message,
                  status: :see_other
    else
      if redirect_to_show
        error_message = @task.errors.full_messages.join(", ").presence || "Media files could not be uploaded."
        redirect_to project_task_path(@project, @task),
                    alert: error_message,
                    status: :see_other
      else
        flash.now[:alert] = "Task could not be updated."
        render :edit, status: :unprocessable_content
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = Task.find(params[:id])
    raise TaskNotFoundError unless @task.project_id == @project.id
  end

  def task_params
    params.require(:task).permit(:title, :status, :type, media_files: [], remove_media_file_ids: [])
  end

  def authorize_project_edit
    collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
    unless collaborator && collaborator.role != "invited"
      flash[:alert] = "You do not have permission to edit this project."
      redirect_to project_path(@project)
    end
  end
end
