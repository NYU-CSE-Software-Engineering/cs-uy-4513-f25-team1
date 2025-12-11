// Invite Collaborator Modal functionality
document.addEventListener("DOMContentLoaded", function() {
  const modal = document.getElementById("invite-modal");
  if (!modal) return;

  const openButtons = document.querySelectorAll('[data-action="open-invite-modal"]');
  const closeButtons = document.querySelectorAll('[data-action="close-invite-modal"]');
  const form = document.getElementById("invite-form");
  const emailInput = document.getElementById("invite-email");
  const feedback = document.getElementById("invite-feedback");
  const submitBtn = document.getElementById("invite-submit-btn");
  const projectId = modal.dataset.projectId;

  function openModal() {
    modal.classList.add("is-open");
    document.body.style.overflow = "hidden";
    setTimeout(() => emailInput?.focus(), 100);
  }

  function closeModal() {
    modal.classList.remove("is-open");
    document.body.style.overflow = "";
    resetForm();
  }

  function resetForm() {
    form?.reset();
    clearFeedback();
    setLoading(false);
  }

  function clearFeedback() {
    if (feedback) {
      feedback.textContent = "";
      feedback.className = "invite-feedback";
    }
  }

  function showError(message) {
    if (feedback) {
      feedback.textContent = message;
      feedback.className = "invite-feedback error";
    }
  }

  function showSuccess(message) {
    if (feedback) {
      feedback.textContent = message;
      feedback.className = "invite-feedback success";
    }
  }

  function setLoading(loading) {
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

  openButtons.forEach(btn => {
    btn.addEventListener("click", openModal);
  });

  closeButtons.forEach(btn => {
    btn.addEventListener("click", closeModal);
  });

  // Close on Escape key
  document.addEventListener("keydown", function(e) {
    if (e.key === "Escape" && modal.classList.contains("is-open")) {
      closeModal();
    }
  });

  // Form submission
  form?.addEventListener("submit", async function(e) {
    e.preventDefault();
    
    const identifier = emailInput?.value?.trim();
    if (!identifier) {
      showError("Please enter an email address or username.");
      return;
    }

    clearFeedback();
    setLoading(true);

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      
      const response = await fetch(`/projects/${projectId}/collaborators`, {
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
        showSuccess(data.message);
        emailInput.value = "";
        
        // Reload the page after a short delay to show the new collaborator
        setTimeout(() => {
          window.location.reload();
        }, 1500);
      } else {
        showError(data.error || "An error occurred. Please try again.");
        setLoading(false);
      }
    } catch (error) {
      console.error("Invite error:", error);
      showError("An error occurred. Please try again.");
      setLoading(false);
    }
  });
});
