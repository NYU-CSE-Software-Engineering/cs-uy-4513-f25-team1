import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["item"]
    static values = {
        role: String,
        requestReviewUrl: String,
        markCompleteUrl: String
    }

    check(event) {
        // Submit the form to save the state
        event.target.form.requestSubmit()

        // Check if all items are checked
        const allChecked = this.itemTargets.every(target => target.checked)

        if (allChecked) {
            if (this.roleValue === "developer") {
                if (confirm("You have completed all items. Do you want to request a review?")) {
                    this.triggerAction(this.requestReviewUrlValue)
                }
            } else if (this.roleValue === "manager") {
                if (confirm("All items completed. Do you want to mark the task as complete?")) {
                    this.triggerAction(this.markCompleteUrlValue)
                }
            }
        }
    }

    triggerAction(url) {
        // Create a temporary form to submit the PATCH request
        const form = document.createElement('form')
        form.method = 'POST'
        form.action = url

        const methodInput = document.createElement('input')
        methodInput.type = 'hidden'
        methodInput.name = '_method'
        methodInput.value = 'PATCH'
        form.appendChild(methodInput)

        // Add CSRF token
        const token = document.querySelector('meta[name="csrf-token"]').content
        const tokenInput = document.createElement('input')
        tokenInput.type = 'hidden'
        tokenInput.name = 'authenticity_token'
        tokenInput.value = token
        form.appendChild(tokenInput)

        document.body.appendChild(form)
        form.submit()
    }
}
