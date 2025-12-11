import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "project", "section", "emptyState"]

  connect() {
    this.filterProjects()
  }

  filter() {
    this.filterProjects()
  }

  filterProjects() {
    const query = this.inputTarget.value.toLowerCase().trim()
    
    if (!query) {
      this.showAllProjects()
      return
    }

    this.projectTargets.forEach(project => {
      const projectName = (project.dataset.projectName || "").toLowerCase()
      const managers = (project.dataset.managers || "").toLowerCase()
      
      const matchesName = this.fuzzyMatch(projectName, query)
      const matchesManager = this.fuzzyMatch(managers, query)
      
      if (matchesName || matchesManager) {
        project.classList.remove("sidebar-search-hidden")
      } else {
        project.classList.add("sidebar-search-hidden")
      }
    })

    this.updateSectionVisibility()
  }

  fuzzyMatch(text, query) {
    if (!query) return true
    return text.includes(query)
  }

  showAllProjects() {
    this.projectTargets.forEach(project => {
      project.classList.remove("sidebar-search-hidden")
    })
    this.updateSectionVisibility()
  }

  updateSectionVisibility() {
    this.sectionTargets.forEach(section => {
      const projects = section.querySelectorAll("[data-sidebar-search-target='project']")
      const visibleProjects = Array.from(projects).filter(p => !p.classList.contains("sidebar-search-hidden"))
      const emptyState = section.querySelector("[data-sidebar-search-target='emptyState']")
      
      if (emptyState) {
        if (visibleProjects.length === 0 && projects.length > 0) {
          emptyState.classList.remove("sidebar-search-hidden")
        } else {
          emptyState.classList.add("sidebar-search-hidden")
        }
      }
    })
  }

  clear() {
    this.inputTarget.value = ""
    this.filterProjects()
  }
}
