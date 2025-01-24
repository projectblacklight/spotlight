export default class {
  delete_lock(el) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    fetch(el.dataset.lock, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken
      }
    });
    
    el.removeAttribute('data-lock');
  }

  connect() {
    document.querySelectorAll('[data-lock]').forEach(element => {
      element.addEventListener('click', (e) => {
        this.delete_lock(e.target);
      });
    });
  }
}