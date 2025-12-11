class Collaborator < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :comments, dependent: :destroy

  enum :role, { manager: 0, developer: 1, invited: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id, message: "is already a collaborator on this project" }

  STALE_THRESHOLD_DAYS = 7

  # Calculate contribution percentage (completed tasks / total tasks in project)
  def contribution_percentage
    total_tasks = project.tasks.count
    return 0 if total_tasks.zero?

    completed_tasks = project.tasks.where(assignee_id: id, status: :completed).count
    ((completed_tasks.to_f / total_tasks) * 100).round(1)
  end

  # Count tasks assigned to this collaborator in this project
  def task_count
    project.tasks.where(assignee_id: id).count
  end

  # Count completed tasks by this collaborator in this project
  def completed_task_count
    project.tasks.where(assignee_id: id, status: :completed).count
  end

  # Time & Performance Metrics

  def avg_completion_time_days
    completed_tasks = assigned_tasks.where.not(completed_at: nil)
    return nil if completed_tasks.empty?

    total_seconds = completed_tasks.sum { |task| task.completed_at - task.created_at }
    avg_seconds = total_seconds / completed_tasks.count
    (avg_seconds / 1.day).round(1)
  end

  def on_time_completion_rate
    tasks_with_due_date = assigned_tasks.completed.where.not(due_at: nil)
    return nil if tasks_with_due_date.empty?

    on_time_count = tasks_with_due_date.count { |task| task.completed_at <= task.due_at }
    ((on_time_count.to_f / tasks_with_due_date.count) * 100).round(1)
  end

  def overdue_tasks
    assigned_tasks.where.not(status: :completed)
                  .where.not(due_at: nil)
                  .where("due_at < ?", Time.current)
  end

  def overdue_task_count
    overdue_tasks.count
  end

  def avg_days_overdue
    overdue = overdue_tasks
    return nil if overdue.empty?

    total_days = overdue.sum { |task| (Time.current - task.due_at) / 1.day }
    (total_days / overdue.count).round(1)
  end

  # Velocity & Productivity Metrics

  def weekly_velocity
    assigned_tasks.completed.where("completed_at >= ?", 7.days.ago).count
  end

  def monthly_velocity
    assigned_tasks.completed.where("completed_at >= ?", 30.days.ago).count
  end

  def completion_rate
    total = task_count
    return 0 if total.zero?

    ((completed_task_count.to_f / total) * 100).round(1)
  end

  def days_on_project
    (Date.current - created_at.to_date).to_i
  end

  def tasks_per_day
    days = days_on_project
    return 0 if days.zero?

    (completed_task_count.to_f / days).round(2)
  end

  def days_since_last_completion
    last_completed = assigned_tasks.completed.maximum(:completed_at)
    return nil if last_completed.nil?

    ((Time.current - last_completed) / 1.day).round(0)
  end

  def weekly_velocity_trend
    (0..3).map do |weeks_ago|
      start_date = (weeks_ago + 1).weeks.ago
      end_date = weeks_ago.weeks.ago
      {
        week: start_date.strftime("%b %d"),
        count: assigned_tasks.completed.where(completed_at: start_date..end_date).count
      }
    end.reverse
  end

  # Priority Distribution Metrics

  def priority_breakdown
    Task.priorities.keys.index_with do |priority|
      assigned_tasks.where(priority: priority).count
    end
  end

  def high_priority_completion_rate
    high_priority_tasks = assigned_tasks.where(priority: [ :high, :urgent ])
    return nil if high_priority_tasks.empty?

    completed_high = high_priority_tasks.completed.count
    ((completed_high.to_f / high_priority_tasks.count) * 100).round(1)
  end

  def open_urgent_task_count
    assigned_tasks.where(priority: :urgent).where.not(status: :completed).count
  end

  # Task Type Analysis Metrics

  def type_breakdown
    assigned_tasks.group(:type).count.transform_keys { |k| k.presence || "Untyped" }
  end

  def avg_completion_time_by_type
    completed = assigned_tasks.completed.where.not(completed_at: nil)
    return {} if completed.empty?

    completed.group_by(&:type).transform_values do |tasks|
      avg_seconds = tasks.sum { |t| t.completed_at - t.created_at } / tasks.count
      (avg_seconds / 1.day).round(1)
    end.transform_keys { |k| k.presence || "Untyped" }
  end

  # Work-in-Progress Metrics

  def current_wip_count
    assigned_tasks.where(status: [ :in_progress, :in_review ]).count
  end

  def current_wip_tasks
    assigned_tasks.where(status: [ :in_progress, :in_review ])
  end

  def stale_task_count
    assigned_tasks.where(status: :in_progress)
                  .where("updated_at < ?", STALE_THRESHOLD_DAYS.days.ago)
                  .count
  end

  def stale_tasks
    assigned_tasks.where(status: :in_progress)
                  .where("updated_at < ?", STALE_THRESHOLD_DAYS.days.ago)
  end

  # Collaboration & Engagement Metrics

  def total_comments_count
    comments.count
  end

  def avg_comments_per_task
    total = task_count
    return 0 if total.zero?

    (total_comments_count.to_f / total).round(1)
  end

  private

  def assigned_tasks
    project.tasks.where(assignee_id: id)
  end
end
