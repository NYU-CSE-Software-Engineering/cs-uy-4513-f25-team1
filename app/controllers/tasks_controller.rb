class TasksController < ApplicationController
  class TaskNotFoundError < StandardError; end

  before_action :set_project
  before_action :set_task, only: [ :show, :update ]
  before_action :authorize_manager, only: [ :new, :create ]
  before_action :authorize_project_edit, only: [ :show, :update ]
  before_action :set_assignable_collaborators, only: [ :show, :new, :create, :update ]

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)
    set_status_based_on_assignee

    if @task.save
      redirect_to project_task_path(@project, @task),
                  notice: "Task was successfully created.",
                  status: :see_other
    else
      flash.now[:alert] = "Task could not be created."
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  def update
    if params[:inline_edit] == "1"
      handle_inline_edit
    else
      handle_standard_update
    end
  end

  private

  def handle_inline_edit
    unless current_user_is_manager?
      render json: { error: "Only managers can edit tasks" }, status: :forbidden
      return
    end

    update_params = inline_edit_params
    handle_assignee_status_change(update_params)

    if @task.update(update_params)
      render json: task_json_response
    else
      render json: { error: @task.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def handle_standard_update
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

    update_params = task_params.except(:remove_media_file_ids, :media_files)
    new_media_files = params[:task][:media_files]&.reject(&:blank?)

    update_successful = @task.update(update_params)

    if update_successful && new_media_files.present?
      @task.media_files.attach(new_media_files)
      @task.validate
      unless @task.errors.empty?
        update_successful = false
      end
    end

    if update_successful
      notice_message = if remove_media_file_ids.any?
        "Media file removed."
      elsif new_media_files.present?
        "Media files uploaded."
      else
        "Task updated."
      end
      redirect_to project_task_path(@project, @task),
                  notice: notice_message,
                  status: :see_other
    else
      error_message = @task.errors.full_messages.join(", ").presence || "Task could not be updated."
      redirect_to project_task_path(@project, @task),
                  alert: error_message,
                  status: :see_other
    end
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = Task.find(params[:id])
    raise TaskNotFoundError unless @task.project_id == @project.id
  end

  def set_assignable_collaborators
    @collaborators = @project.collaborators.where.not(role: :manager).includes(:user)
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :status,
      :type,
      :branch_link,
      :assignee_id,
      :priority,
      :due_at,
      media_files: [],
      remove_media_file_ids: []
    )
  end

  def set_status_based_on_assignee
    @task.status = @task.assignee_id.present? ? :in_progress : :todo
  end

  def authorize_manager
    collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
    unless collaborator&.manager?
      flash[:alert] = "Only managers can create tasks."
      redirect_to project_path(@project)
    end
  end

  def authorize_project_edit
    collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
    unless collaborator && collaborator.role != "invited"
      flash[:alert] = "You do not have permission to edit this project."
      redirect_to project_path(@project)
    end
  end

  def current_user_is_manager?
    collaborator = Collaborator.find_by(user_id: Current.session&.user_id, project_id: @project.id)
    collaborator&.manager?
  end

  def inline_edit_params
    params.require(:task).permit(:priority, :type, :due_at, :assignee_id, :description, :title, :branch_link)
  end

  def handle_assignee_status_change(update_params)
    return unless update_params.key?(:assignee_id)

    if update_params[:assignee_id].blank?
      @task.status = :todo
    elsif @task.assignee_id.blank? && update_params[:assignee_id].present?
      @task.status = :in_progress
    end
  end

  def task_json_response
    {
      id: @task.id,
      title: @task.title,
      priority: @task.priority,
      type: @task.type,
      status: @task.status,
      description: @task.description,
      branch_link: @task.branch_link,
      due_at: @task.due_at&.iso8601,
      assignee: @task.assignee ? {
        id: @task.assignee.id,
        username: @task.assignee.user.username,
        role: @task.assignee.role,
        task_count: @task.assignee.task_count,
        completed_task_count: @task.assignee.completed_task_count,
        contribution_percentage: @task.assignee.contribution_percentage
      } : nil
    }
  end
end
