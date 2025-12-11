import { Controller } from "@hotwired/stimulus"

const MAX_FILE_SIZE_MB = 10
const MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024
const MAX_FILES = 10
const ALLOWED_CONTENT_TYPES = [
  "image/jpeg", "image/png", "image/gif", "image/svg+xml", "image/webp",
  "application/pdf",
  "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
]
const ALLOWED_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp", ".pdf", ".doc", ".docx", ".xls", ".xlsx"]

export default class extends Controller {
  static targets = ["input", "dropZone", "fileList", "fileListItems", "submitBtn", "form"]

  connect() {
    this.selectedFiles = new DataTransfer()
  }

  openFilePicker(event) {
    if (event.target === this.inputTarget) return
    this.inputTarget.click()
  }

  handleFileSelect(event) {
    const newFiles = Array.from(event.target.files)
    const rejectedFiles = []
    const currentFileCount = this.selectedFiles.files.length
    
    newFiles.forEach(file => {
      if (!this.isAllowedFileType(file)) {
        const ext = this.getFileExtension(file.name)
        rejectedFiles.push(`${file.name} (unsupported file type "${ext || file.type}")`)
      } else if (file.size > MAX_FILE_SIZE_BYTES) {
        rejectedFiles.push(`${file.name} (${this.formatFileSize(file.size)} exceeds ${MAX_FILE_SIZE_MB}MB limit)`)
      } else if (currentFileCount + this.selectedFiles.files.length >= MAX_FILES) {
        rejectedFiles.push(`${file.name} (maximum ${MAX_FILES} files allowed)`)
      } else {
        this.selectedFiles.items.add(file)
      }
    })

    if (rejectedFiles.length > 0) {
      alert(`The following files could not be added:\n\n${rejectedFiles.join('\n')}\n\nAllowed types: images, PDFs, Word, and Excel files.`)
    }

    this.inputTarget.files = this.selectedFiles.files
    this.updateFileList()
  }

  isAllowedFileType(file) {
    if (ALLOWED_CONTENT_TYPES.includes(file.type)) {
      return true
    }
    const ext = this.getFileExtension(file.name).toLowerCase()
    return ALLOWED_EXTENSIONS.includes(ext)
  }

  getFileExtension(filename) {
    const lastDot = filename.lastIndexOf('.')
    return lastDot !== -1 ? filename.slice(lastDot) : ''
  }

  updateFileList() {
    const files = Array.from(this.selectedFiles.files)
    
    if (files.length === 0) {
      this.fileListTarget.style.display = "none"
      this.submitBtnTarget.style.display = "none"
      return
    }

    this.fileListTarget.style.display = "block"
    this.submitBtnTarget.style.display = "block"

    this.fileListItemsTarget.innerHTML = files.map((file, index) => `
      <li class="selected-file-item">
        <span class="file-item-icon">${this.getFileIcon(file)}</span>
        <span class="file-item-name">${file.name}</span>
        <span class="file-item-size">${this.formatFileSize(file.size)}</span>
        <button type="button" class="file-item-remove" data-action="click->file-upload#removeFile" data-index="${index}">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
      </li>
    `).join("")
  }

  removeFile(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    const newDataTransfer = new DataTransfer()
    
    Array.from(this.selectedFiles.files).forEach((file, i) => {
      if (i !== index) {
        newDataTransfer.items.add(file)
      }
    })

    this.selectedFiles = newDataTransfer
    this.inputTarget.files = this.selectedFiles.files
    this.updateFileList()
  }

  clearFiles() {
    this.selectedFiles = new DataTransfer()
    this.inputTarget.files = this.selectedFiles.files
    this.updateFileList()
  }

  getFileIcon(file) {
    if (file.type.startsWith("image/")) {
      return `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>`
    } else if (file.type === "application/pdf") {
      return `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc3545" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>`
    } else {
      return `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>`
    }
  }

  formatFileSize(bytes) {
    if (bytes === 0) return "0 Bytes"
    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i]
  }
}
