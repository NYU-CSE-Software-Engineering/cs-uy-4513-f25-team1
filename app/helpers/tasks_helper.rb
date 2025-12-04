module TasksHelper
  def priority_badge_class(priority)
    case priority
    when "urgent"
      "bg-red-100 text-red-800 px-2 py-1 rounded-full text-xs font-medium"
    when "high"
      "bg-orange-100 text-orange-800 px-2 py-1 rounded-full text-xs font-medium"
    when "medium"
      "bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs font-medium"
    when "low"
      "bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium"
    when "no_priority"
      "bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-medium"
    else
      "bg-gray-100 text-gray-800 px-2 py-1 rounded-full text-xs font-medium"
    end
  end
end
