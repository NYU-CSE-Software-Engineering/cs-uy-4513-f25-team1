// Task table filtering functionality using event delegation

// Store filter values
const filterValues = {
  name: '',
  type: '',
  priority: '',
  assignee: '',
  status: '',
  'due-date': ''
};

// Close all dropdowns
function closeAllDropdowns() {
  document.querySelectorAll('.custom-dropdown.open').forEach(dropdown => {
    dropdown.classList.remove('open');
  });
}

// Get filter value
function getFilterValue(filterName) {
  return filterValues[filterName] || '';
}

// Fuzzy match for search
function fuzzyMatch(text, query) {
  if (!query) return true;
  return text.toLowerCase().includes(query.toLowerCase());
}

// Apply all filters to the table
function applyFilters() {
  const table = document.getElementById('tasks-table');
  if (!table) return;

  const rows = table.querySelectorAll('tbody tr.task-row');
  const nameFilter = document.getElementById('filter-name');
  
  const nameValue = nameFilter ? nameFilter.value.trim() : '';
  const statusValue = getFilterValue('status');
  const assigneeValue = getFilterValue('assignee');
  const priorityValue = getFilterValue('priority');
  const typeValue = getFilterValue('type');
  const dueDateValue = getFilterValue('due-date');

  rows.forEach(row => {
    let show = true;

    // Name filter
    if (nameValue) {
      const taskTitle = row.querySelector('.task-title');
      const titleText = taskTitle ? taskTitle.textContent : '';
      if (!fuzzyMatch(titleText, nameValue)) {
        show = false;
      }
    }

    // Status filter
    if (statusValue && show) {
      if (row.dataset.status !== statusValue) {
        show = false;
      }
    }

    // Assignee filter
    if (assigneeValue && show) {
      if ((row.dataset.assignee || '') !== assigneeValue) {
        show = false;
      }
    }

    // Priority filter
    if (priorityValue && show) {
      if ((row.dataset.priority || 'no_priority') !== priorityValue) {
        show = false;
      }
    }

    // Type filter
    if (typeValue && show) {
      if ((row.dataset.type || '') !== typeValue) {
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
  const visibleRows = Array.from(rows).filter(r => r.style.display !== 'none');
  const emptyRow = table.querySelector('tbody tr:not(.task-row)');
  if (emptyRow) {
    emptyRow.style.display = visibleRows.length === 0 ? '' : 'none';
  }
}

// Handle dropdown trigger clicks using event delegation
document.addEventListener('click', function(e) {
  const trigger = e.target.closest('.dropdown-trigger');
  
  if (trigger) {
    e.preventDefault();
    e.stopPropagation();
    
    const dropdown = trigger.closest('.custom-dropdown');
    if (!dropdown) return;
    
    const isOpen = dropdown.classList.contains('open');
    closeAllDropdowns();
    
    if (!isOpen) {
      dropdown.classList.add('open');
    }
    return;
  }
  
  // Handle option clicks
  const option = e.target.closest('.dropdown-option');
  if (option) {
    e.preventDefault();
    e.stopPropagation();
    
    const dropdown = option.closest('.custom-dropdown');
    if (!dropdown) return;
    
    const value = option.dataset.value;
    const filterName = dropdown.dataset.filter;
    const valueDisplay = dropdown.querySelector('.dropdown-value');
    const options = dropdown.querySelectorAll('.dropdown-option');
    
    // Update selected state
    options.forEach(opt => opt.classList.remove('selected'));
    option.classList.add('selected');
    
    // Update display value
    if (value === '') {
      const optionText = option.querySelector('.option-text');
      const placeholderText = optionText ? optionText.textContent : 'All';
      valueDisplay.innerHTML = '<span class="text-placeholder">' + placeholderText + '</span>';
    } else {
      const badge = option.querySelector('.task-type-badge, .priority-badge, .status-badge, .due-date-badge, .assignee-pill');
      if (badge) {
        valueDisplay.innerHTML = badge.outerHTML;
      } else {
        valueDisplay.textContent = option.textContent.trim();
      }
    }
    
    // Store filter value and apply
    filterValues[filterName] = value;
    dropdown.classList.remove('open');
    applyFilters();
    return;
  }
  
  // Handle row clicks for navigation
  const row = e.target.closest('.task-row');
  if (row && !e.target.closest('.custom-dropdown') && !e.target.closest('a.task-row-link')) {
    window.location.href = row.dataset.taskUrl;
    return;
  }
  
  // Close dropdowns when clicking outside
  if (!e.target.closest('.custom-dropdown')) {
    closeAllDropdowns();
  }
});

// Handle name filter input
document.addEventListener('input', function(e) {
  if (e.target.id === 'filter-name') {
    applyFilters();
  }
});

// Handle escape key to close dropdowns
document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape') {
    closeAllDropdowns();
  }
});

// Log to confirm script loaded
console.log('Task table filters loaded');
