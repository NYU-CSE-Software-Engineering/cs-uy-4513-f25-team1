import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "quadratic_sidebar_width"
const MIN_WIDTH = 200
const MAX_WIDTH = 400
const DEFAULT_WIDTH = 280

export default class extends Controller {
  static targets = ["handle"]

  connect() {
    this.restoreWidth()
    this.boundOnMouseMove = this.onMouseMove.bind(this)
    this.boundOnMouseUp = this.onMouseUp.bind(this)
  }

  disconnect() {
    this.removeGlobalListeners()
  }

  restoreWidth() {
    const savedWidth = localStorage.getItem(STORAGE_KEY)
    if (savedWidth) {
      const width = parseInt(savedWidth, 10)
      if (width >= MIN_WIDTH && width <= MAX_WIDTH) {
        this.setWidth(width)
      }
    }
  }

  startResize(event) {
    event.preventDefault()
    
    this.isResizing = true
    this.startX = event.clientX
    this.startWidth = this.element.offsetWidth
    
    this.dashboardLayout.classList.add("resizing")
    this.handleTarget.classList.add("dragging")
    
    document.addEventListener("mousemove", this.boundOnMouseMove)
    document.addEventListener("mouseup", this.boundOnMouseUp)
  }

  onMouseMove(event) {
    if (!this.isResizing) return
    
    const deltaX = event.clientX - this.startX
    const newWidth = Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, this.startWidth + deltaX))
    
    this.setWidth(newWidth)
  }

  onMouseUp() {
    if (!this.isResizing) return
    
    this.isResizing = false
    this.dashboardLayout.classList.remove("resizing")
    this.handleTarget.classList.remove("dragging")
    
    this.removeGlobalListeners()
    this.saveWidth()
  }

  setWidth(width) {
    this.dashboardLayout.style.setProperty("--sidebar-width", `${width}px`)
  }

  saveWidth() {
    const currentWidth = this.element.offsetWidth
    localStorage.setItem(STORAGE_KEY, currentWidth.toString())
  }

  removeGlobalListeners() {
    document.removeEventListener("mousemove", this.boundOnMouseMove)
    document.removeEventListener("mouseup", this.boundOnMouseUp)
  }

  get dashboardLayout() {
    return this.element.closest(".dashboard-layout") || document.body
  }
}
