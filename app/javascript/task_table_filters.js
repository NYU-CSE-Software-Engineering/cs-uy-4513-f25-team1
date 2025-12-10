// Task table filtering functionality
(function() {
  function initializeTaskFilters() {
    const table = document.getElementById('tasks-table');
    if (!table) return;
    
    const rows = table.querySelectorAll('tbody tr.task-row');
    const statusFilter = document.getElementById('filter-status');
    const assigneeFilter = document.getElementById('filter-assignee');
    const priorityFilter = document.getElementById('filter-priority');
    const dueDateFilter = document.getElementById('filter-due-date');

    if (!statusFilter || !assigneeFilter || !priorityFilter || !dueDateFilter) {
      return;
    }

    function applyFilters() {
      const statusValue = statusFilter.value;
      const assigneeValue = assigneeFilter.value;
      const priorityValue = priorityFilter.value;
      const dueDateValue = dueDateFilter.value;

      rows.forEach(row => {
        let show = true;

        // Status filter
        if (statusValue) {
          const rowStatus = row.dataset.status;
          if (rowStatus !== statusValue) {
            show = false;
          }
        }

        // Assignee filter
        if (assigneeValue) {
          const rowAssignee = row.dataset.assignee || '';
          if (rowAssignee !== assigneeValue) {
            show = false;
          }
        }

        // Priority filter
        if (priorityValue) {
          const rowPriority = row.dataset.priority || 'no_priority';
          if (rowPriority !== priorityValue) {
            show = false;
          }
        }

        // Due date filter
        if (dueDateValue && show) {
          const dueDateStr = row.dataset.dueDate;
          if (!dueDateStr) {
            if (dueDateValue !== 'no_due_date') {
              show = false;
            }
          } else {
            const dueDate = new Date(dueDateStr);
            const now = new Date();
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            const dueDateOnly = new Date(dueDate.getFullYear(), dueDate.getMonth(), dueDate.getDate());

            switch (dueDateValue) {
              case 'overdue':
                if (dueDateOnly >= today) show = false;
                break;
              case 'due_today':
                if (dueDateOnly.getTime() !== today.getTime()) show = false;
                break;
              case 'due_this_week':
                const weekEnd = new Date(today);
                weekEnd.setDate(weekEnd.getDate() + 7);
                if (dueDateOnly < today || dueDateOnly >= weekEnd) show = false;
                break;
              case 'due_this_month':
                const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                if (dueDateOnly < today || dueDateOnly > monthEnd) show = false;
                break;
              case 'no_due_date':
                show = false;
                break;
            }
          }
        }

        row.style.display = show ? '' : 'none';
      });

      // Show/hide empty state
      const visibleRows = Array.from(rows).filter(row => {
        const display = window.getComputedStyle(row).display;
        return display !== 'none';
      });
      const emptyRow = table.querySelector('tbody tr:not(.task-row)');
      if (emptyRow) {
        emptyRow.style.display = visibleRows.length === 0 ? '' : 'none';
      }
    }

    // Add event listeners directly to each filter
    statusFilter.addEventListener('change', applyFilters);
    assigneeFilter.addEventListener('change', applyFilters);
    priorityFilter.addEventListener('change', applyFilters);
    dueDateFilter.addEventListener('change', applyFilters);
    
    // Also use event delegation as backup
    table.addEventListener('change', function(e) {
      if (e.target.matches('#filter-status, #filter-assignee, #filter-priority, #filter-due-date')) {
        applyFilters();
      }
    });

    // Make rows clickable - rows are already clickable via links, but add fallback
    rows.forEach(row => {
      row.style.cursor = 'pointer';
      row.addEventListener('click', function(e) {
        // Don't navigate if clicking on a filter dropdown
        if (e.target.closest('select')) {
          return;
        }
        // If clicking on a link, let it handle navigation
        const link = e.target.closest('a.task-row-link');
        if (link) {
          return; // Let the link handle it
        }
        // Otherwise, navigate to the task URL
        window.location.href = row.dataset.taskUrl;
      });
    });
  }

  // Initialize on page load
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeTaskFilters);
  } else {
    initializeTaskFilters();
  }

  // Re-initialize on Turbo navigation (if using Turbo)
  if (typeof Turbo !== 'undefined') {
    document.addEventListener('turbo:load', initializeTaskFilters);
    document.addEventListener('turbo:frame-load', initializeTaskFilters);
  }
})();
