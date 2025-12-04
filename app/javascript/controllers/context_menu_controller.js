import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        this.close = this.close.bind(this)
        document.addEventListener("click", this.close)
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape") this.close()
        })
    }

    disconnect() {
        document.removeEventListener("click", this.close)
    }

    open(event) {
        event.preventDefault()

        // Store the current task URLs
        this.currentEditUrl = event.currentTarget.dataset.editUrl
        this.currentDeleteUrl = event.currentTarget.dataset.deleteUrl

        // Position the menu
        const menu = this.menuTarget
        menu.style.display = "block"

        // Calculate position to keep within viewport
        let x = event.clientX
        let y = event.clientY

        const menuRect = menu.getBoundingClientRect()
        const windowWidth = window.innerWidth
        const windowHeight = window.innerHeight

        if (x + menuRect.width > windowWidth) {
            x -= menuRect.width
        }

        if (y + menuRect.height > windowHeight) {
            y -= menuRect.height
        }

        menu.style.left = `${x}px`
        menu.style.top = `${y}px`
    }

    close() {
        this.menuTarget.style.display = "none"
    }

    navigate(event) {
        // Allow default behavior if clicking a link or button inside the row
        if (event.target.closest('a') || event.target.closest('button')) {
            return
        }

        const url = event.currentTarget.dataset.url
        if (url) {
            window.location.href = url
        }
    }

    edit(event) {
        event.preventDefault()
        if (this.currentEditUrl) {
            window.location.href = this.currentEditUrl
        }
        this.close()
    }

    updateStatus(event) {
        event.preventDefault()
        const newStatus = event.currentTarget.dataset.status

        if (this.currentDeleteUrl && newStatus) { // Using deleteUrl as base for update since it's the resource URL
            const form = document.createElement('form')
            form.method = 'post'
            form.action = this.currentDeleteUrl

            const methodInput = document.createElement('input')
            methodInput.type = 'hidden'
            methodInput.name = '_method'
            methodInput.value = 'patch'

            const tokenInput = document.createElement('input')
            tokenInput.type = 'hidden'
            tokenInput.name = 'authenticity_token'
            tokenInput.value = document.querySelector('meta[name="csrf-token"]').content

            const statusInput = document.createElement('input')
            statusInput.type = 'hidden'
            statusInput.name = 'task[status]'
            statusInput.value = newStatus

            form.appendChild(methodInput)
            form.appendChild(tokenInput)
            form.appendChild(statusInput)
            document.body.appendChild(form)
            form.submit()
        }
        this.close()
    }

    delete(event) {
        event.preventDefault()
        if (this.currentDeleteUrl) {
            if (confirm("Are you sure you want to delete this task?")) {
                // Create a form to submit the delete request via Turbo
                const form = document.createElement('form')
                form.method = 'post'
                form.action = this.currentDeleteUrl

                const methodInput = document.createElement('input')
                methodInput.type = 'hidden'
                methodInput.name = '_method'
                methodInput.value = 'delete'

                const tokenInput = document.createElement('input')
                tokenInput.type = 'hidden'
                tokenInput.name = 'authenticity_token'
                tokenInput.value = document.querySelector('meta[name="csrf-token"]').content

                form.appendChild(methodInput)
                form.appendChild(tokenInput)
                document.body.appendChild(form)
                form.submit()
            }
        }
        this.close()
    }
}
