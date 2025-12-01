module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^the home\s?page$/
      '/'
    when /^the projects page$/
      projects_path
    when /^the new project page$/
      new_project_path
    when /^the project page$/
      project_path(@project)
    when /^the project settings page$/
      edit_project_path(@project)
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
