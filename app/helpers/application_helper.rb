module ApplicationHelper
  SAFE_URL_PROTOCOLS = %w[http https].freeze

  def safe_url(url)
    return nil if url.blank?

    uri = URI.parse(url)
    return url if uri.scheme.present? && SAFE_URL_PROTOCOLS.include?(uri.scheme.downcase)

    nil
  rescue URI::InvalidURIError
    nil
  end

  def manager_usernames_for(project)
    Collaborator.joins(:user).where(project_id: project.id, role: :manager).pluck("users.username").join(",")
  end

  def assignee_color(username)
    return "hsl(0, 0%, 60%)" if username.blank?

    hue = username.hash.abs % 360
    "hsl(#{hue}, 55%, 45%)"
  end

  def due_date_category(date)
    return "due-none" if date.blank?

    today = Date.current
    due_date = date.to_date

    if due_date < today
      "due-overdue"
    elsif due_date == today
      "due-today"
    elsif due_date <= today + 7.days
      "due-this-week"
    elsif due_date <= today.end_of_month
      "due-this-month"
    else
      "due-future"
    end
  end
end
