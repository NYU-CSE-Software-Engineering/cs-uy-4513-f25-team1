import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "editor"]
  static values = { url: String }

  showEditor(event) {
    const field = event.currentTarget.dataset.field
    const fieldContainer = this.findFieldContainer(field)
    
    if (fieldContainer) {
      const display = fieldContainer.querySelector('[data-inline-edit-target="display"]')
      const editor = fieldContainer.querySelector('[data-inline-edit-target="editor"]')
      
      if (display && editor) {
        display.style.display = "none"
        editor.style.display = field === "assignee_id" ? "block" : "flex"
        
        const input = editor.querySelector("select, input")
        if (input) {
          input.focus()
        }
      }
    }
  }

  hideEditor(event) {
    const fieldContainer = event.currentTarget.closest('.inline-edit-field')
    
    if (fieldContainer) {
      const display = fieldContainer.querySelector('[data-inline-edit-target="display"]')
      const editor = fieldContainer.querySelector('[data-inline-edit-target="editor"]')
      const field = fieldContainer.dataset.field
      
      if (display && editor) {
        display.style.display = field === "assignee_id" ? "block" : "flex"
        editor.style.display = "none"
      }
    }
  }

  async save(event) {
    const input = event.currentTarget
    const field = input.dataset.field
    const value = input.value
    const fieldContainer = this.findFieldContainer(field)

    const formData = new FormData()
    formData.append(`task[${field}]`, value)
    formData.append("inline_edit", "1")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDisplay(field, data, fieldContainer)
        this.hideEditorForField(fieldContainer)
      } else {
        const errorData = await response.json()
        alert(errorData.error || "Failed to update")
        this.hideEditorForField(fieldContainer)
      }
    } catch (error) {
      console.error("Inline edit error:", error)
      alert("An error occurred while saving")
      this.hideEditorForField(fieldContainer)
    }
  }

  updateDisplay(field, data, fieldContainer) {
    const display = fieldContainer.querySelector('[data-inline-edit-target="display"]')
    if (!display) return

    switch (field) {
      case "priority":
        this.updatePriorityDisplay(display, data.priority)
        break
      case "type":
        this.updateTypeDisplay(display, data.type)
        break
      case "due_at":
        this.updateDueDateDisplay(display, data.due_at)
        break
      case "assignee_id":
        this.updateAssigneeDisplay(display, data.assignee)
        break
      case "description":
        this.updateDescriptionDisplay(display, data.description)
        break
      case "title":
        this.updateTitleDisplay(display, data.title)
        break
      case "branch_link":
        this.updateBranchLinkDisplay(display, data.branch_link)
        break
    }
  }

  async saveDescription(event) {
    const button = event.currentTarget
    const field = button.dataset.field
    const fieldContainer = this.findFieldContainer(field)
    const textarea = fieldContainer.querySelector('textarea')
    const value = textarea.value

    const formData = new FormData()
    formData.append(`task[${field}]`, value)
    formData.append("inline_edit", "1")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDisplay(field, data, fieldContainer)
        this.hideEditorForField(fieldContainer)
      } else {
        const errorData = await response.json()
        alert(errorData.error || "Failed to update")
      }
    } catch (error) {
      console.error("Inline edit error:", error)
      alert("An error occurred while saving")
    }
  }

  async saveTitle(event) {
    const button = event.currentTarget
    const field = button.dataset.field
    const fieldContainer = this.findFieldContainer(field)
    const input = fieldContainer.querySelector('input[data-field="title"]')
    const value = input.value.trim()

    if (!value) {
      alert("Title cannot be empty")
      return
    }

    const formData = new FormData()
    formData.append(`task[${field}]`, value)
    formData.append("inline_edit", "1")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDisplay(field, data, fieldContainer)
        this.hideEditorForField(fieldContainer)
      } else {
        const errorData = await response.json()
        alert(errorData.error || "Failed to update")
      }
    } catch (error) {
      console.error("Inline edit error:", error)
      alert("An error occurred while saving")
    }
  }

  async saveBranchLink(event) {
    const button = event.currentTarget
    const field = button.dataset.field
    const fieldContainer = this.findFieldContainer(field)
    const input = fieldContainer.querySelector('input[data-field="branch_link"]')
    const value = input.value.trim()

    const formData = new FormData()
    formData.append(`task[${field}]`, value)
    formData.append("inline_edit", "1")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        this.updateDisplay(field, data, fieldContainer)
        this.hideEditorForField(fieldContainer)
      } else {
        const errorData = await response.json()
        alert(errorData.error || "Failed to update")
      }
    } catch (error) {
      console.error("Inline edit error:", error)
      alert("An error occurred while saving")
    }
  }

  updateDescriptionDisplay(display, description) {
    const content = display.querySelector('.description-content')
    if (content) {
      if (description && description.trim()) {
        content.innerHTML = this.escapeHtml(description)
      } else {
        content.innerHTML = '<span class="text-placeholder">No description provided</span>'
      }
    }
  }

  updateTitleDisplay(display, title) {
    const titleElement = display.querySelector('.task-page-title')
    if (titleElement) {
      titleElement.textContent = title
    }
  }

  updateBranchLinkDisplay(display, branchLink) {
    if (branchLink && branchLink.trim()) {
      const githubIcon = `<svg class="github-icon" width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/></svg>`
      display.innerHTML = `
        <div class="github-link-pill">
          ${githubIcon}
          <a href="${this.escapeHtml(branchLink)}" target="_blank" rel="noopener noreferrer" class="branch-link-text">${this.escapeHtml(branchLink)}</a>
        </div>
      `
    } else {
      display.innerHTML = '<span class="text-placeholder">No branch link</span>'
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  updatePriorityDisplay(display, priority) {
    const badge = display.querySelector('.priority-badge')
    if (badge) {
      badge.className = `priority-badge priority-${priority || 'no-priority'}`
      badge.textContent = priority ? this.titleize(priority) : "No Priority"
    }
  }

  updateTypeDisplay(display, type) {
    let badge = display.querySelector('.task-type-badge')
    let placeholder = display.querySelector('.text-placeholder')
    
    if (type) {
      if (placeholder) {
        placeholder.remove()
      }
      if (!badge) {
        badge = document.createElement('span')
        badge.className = 'task-type-badge'
        const editTrigger = display.querySelector('.edit-trigger')
        if (editTrigger) {
          display.insertBefore(badge, editTrigger)
        } else {
          display.appendChild(badge)
        }
      }
      badge.setAttribute('data-type', type.toUpperCase())
      badge.textContent = type
    } else {
      if (badge) {
        badge.remove()
      }
      if (!placeholder) {
        placeholder = document.createElement('span')
        placeholder.className = 'text-placeholder'
        placeholder.textContent = 'Not specified'
        const editTrigger = display.querySelector('.edit-trigger')
        if (editTrigger) {
          display.insertBefore(placeholder, editTrigger)
        } else {
          display.appendChild(placeholder)
        }
      }
    }
  }

  updateDueDateDisplay(display, dueAt) {
    let dateValue = display.querySelector('.due-date-value')
    let placeholder = display.querySelector('.text-placeholder')
    
    if (dueAt) {
      if (placeholder) {
        placeholder.remove()
      }
      if (!dateValue) {
        dateValue = document.createElement('span')
        dateValue.className = 'due-date-value'
        const editTrigger = display.querySelector('.edit-trigger')
        if (editTrigger) {
          display.insertBefore(dateValue, editTrigger)
        } else {
          display.appendChild(dateValue)
        }
      }
      const date = new Date(dueAt)
      dateValue.textContent = date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      })
    } else {
      if (dateValue) {
        dateValue.remove()
      }
      if (!placeholder) {
        placeholder = document.createElement('span')
        placeholder.className = 'text-placeholder'
        placeholder.textContent = 'No due date'
        const editTrigger = display.querySelector('.edit-trigger')
        if (editTrigger) {
          display.insertBefore(placeholder, editTrigger)
        } else {
          display.appendChild(placeholder)
        }
      }
    }
  }

  updateAssigneeDisplay(display, assignee) {
    const projectId = window.location.pathname.match(/\/projects\/(\d+)/)?.[1]
    
    if (assignee && assignee.username) {
      const collaboratorUrl = `/projects/${projectId}/collaborators/${assignee.id}`
      const cardHTML = `
        <div class="assignee-card-wrapper">
          <a href="${collaboratorUrl}" class="assignee-card assignee-card-link" data-turbo-frame="_top">
            <div class="assignee-card-header">
              <div class="assignee-avatar-lg">${assignee.username[0].toUpperCase()}</div>
              <div class="assignee-info">
                <span class="assignee-username">${assignee.username}</span>
                <span class="assignee-role-badge role-${assignee.role}">${this.titleize(assignee.role)}</span>
              </div>
            </div>
            <div class="assignee-card-stats">
              <div class="assignee-stat">
                <span class="stat-value">${assignee.task_count}</span>
                <span class="stat-label">Tasks Assigned</span>
              </div>
              <div class="assignee-stat">
                <span class="stat-value">${assignee.completed_task_count}</span>
                <span class="stat-label">Completed</span>
              </div>
              <div class="assignee-stat">
                <span class="stat-value">${assignee.contribution_percentage}%</span>
                <span class="stat-label">Contribution</span>
              </div>
            </div>
          </a>
          <button type="button" class="edit-trigger assignee-edit-btn" data-action="click->inline-edit#showEditor" data-field="assignee_id">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          </button>
        </div>
      `
      display.innerHTML = cardHTML
    } else {
      const emptyCardHTML = `
        <div class="assignee-card assignee-card-empty">
          <div class="assignee-empty-content">
            <div class="assignee-avatar-lg empty-avatar">?</div>
            <div class="assignee-empty-text">
              <span class="empty-title">No Assignee</span>
              <span class="empty-subtitle">This task is unassigned</span>
            </div>
            <button type="button" class="btn btn-secondary assign-btn" data-action="click->inline-edit#showEditor" data-field="assignee_id">
              Assign Someone
            </button>
          </div>
        </div>
      `
      display.innerHTML = emptyCardHTML
    }
  }

  findFieldContainer(field) {
    return this.element.querySelector(`[data-field="${field}"]`)
  }

  hideEditorForField(fieldContainer) {
    const display = fieldContainer.querySelector('[data-inline-edit-target="display"]')
    const editor = fieldContainer.querySelector('[data-inline-edit-target="editor"]')
    const field = fieldContainer.dataset.field
    
    if (display && editor) {
      display.style.display = field === "assignee_id" ? "block" : "flex"
      editor.style.display = "none"
    }
  }

  getCSRFToken() {
    const metaTag = document.querySelector('meta[name="csrf-token"]')
    return metaTag ? metaTag.content : ""
  }

  titleize(str) {
    if (!str) return ""
    return str.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase())
  }
}
