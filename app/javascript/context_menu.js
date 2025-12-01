document.addEventListener('turbo:load', () => {
    const contextMenu = document.getElementById('context-menu');
    const taskRows = document.querySelectorAll('.task-row');

    if (!contextMenu) return;

    // Hide context menu on click elsewhere
    document.addEventListener('click', () => {
        contextMenu.classList.remove('visible');
    });

    taskRows.forEach(row => {
        row.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            const taskId = row.dataset.taskId;
            console.log('Right clicked task:', taskId);

            // Position menu
            contextMenu.style.top = `${e.pageY}px`;
            contextMenu.style.left = `${e.pageX}px`;
            contextMenu.classList.add('visible');
        });
    });
});
