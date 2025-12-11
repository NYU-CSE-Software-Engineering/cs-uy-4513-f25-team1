// Invite Collaborator Modal functionality using event delegation for Turbo compatibility

function getInviteModalElements() {
  const modal = document.getElementById("invite-modal");
  if (!modal) return null;
  
  return {
    modal,
    form: document.getElementById("invite-form"),
    emailInput: document.getElementById("invite-email"),
    feedback: document.getElementById("invite-feedback"),
    submitBtn: document.getElementById("invite-submit-btn"),
    projectId: modal.dataset.projectId
  };
}

function openInviteModal() {
  const elements = getInviteModalElements();
  if (!elements) return;
  
  elements.modal.classList.add("is-open");
  document.body.style.overflow = "hidden";
  setTimeout(() => elements.emailInput?.focus(), 100);
}

function closeInviteModal() {
  const elements = getInviteModalElements();
  if (!elements) return;
  
  elements.modal.classList.remove("is-open");
  document.body.style.overflow = "";
  resetInviteForm();
}

function resetInviteForm() {
  const elements = getInviteModalElements();
  if (!elements) return;
  
  elements.form?.reset();
  clearInviteFeedback();
  setInviteLoading(false);
}

function clearInviteFeedback() {
  const feedback = document.getElementById("invite-feedback");
  if (feedback) {
    feedback.textContent = "";
    feedback.className = "invite-feedback";
  }
}

function showInviteError(message) {
  const feedback = document.getElementById("invite-feedback");
  if (feedback) {
    feedback.textContent = message;
    feedback.className = "invite-feedback error";
  }
}

function showInviteSuccess(message) {
  const feedback = document.getElementById("invite-feedback");
  if (feedback) {
    feedback.textContent = message;
    feedback.className = "invite-feedback success";
  }
}

function setInviteLoading(loading) {
  const submitBtn = document.getElementById("invite-submit-btn");
  if (!submitBtn) return;
  
  const btnText = submitBtn.querySelector(".btn-text");
  const btnLoading = submitBtn.querySelector(".btn-loading");
  
  if (loading) {
    submitBtn.disabled = true;
    if (btnText) btnText.style.display = "none";
    if (btnLoading) btnLoading.style.display = "inline-flex";
  } else {
    submitBtn.disabled = false;
    if (btnText) btnText.style.display = "inline";
    if (btnLoading) btnLoading.style.display = "none";
  }
}

// Handle clicks using event delegation
document.addEventListener("click", function(e) {
  // Open modal
  if (e.target.closest('[data-action="open-invite-modal"]')) {
    e.preventDefault();
    openInviteModal();
    return;
  }
  
  // Close modal
  if (e.target.closest('[data-action="close-invite-modal"]')) {
    e.preventDefault();
    closeInviteModal();
    return;
  }
});

// Handle Escape key to close modal
document.addEventListener("keydown", function(e) {
  if (e.key === "Escape") {
    const modal = document.getElementById("invite-modal");
    if (modal && modal.classList.contains("is-open")) {
      closeInviteModal();
    }
  }
});

// Handle form submission using event delegation
document.addEventListener("submit", async function(e) {
  if (e.target.id !== "invite-form") return;
  
  e.preventDefault();
  
  const elements = getInviteModalElements();
  if (!elements) return;
  
  const identifier = elements.emailInput?.value?.trim();
  if (!identifier) {
    showInviteError("Please enter an email address or username.");
    return;
  }

  clearInviteFeedback();
  setInviteLoading(true);

  try {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    const response = await fetch(`/projects/${elements.projectId}/collaborators`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ identifier: identifier })
    });

    const data = await response.json();

    if (data.success) {
      showInviteSuccess(data.message);
      elements.emailInput.value = "";
      
      // Reload the page after a short delay to show the new collaborator
      setTimeout(() => {
        window.location.reload();
      }, 1500);
    } else {
      showInviteError(data.error || "An error occurred. Please try again.");
      setInviteLoading(false);
    }
  } catch (error) {
    console.error("Invite error:", error);
    showInviteError("An error occurred. Please try again.");
    setInviteLoading(false);
  }
});
