export default class {
  delete_lock(el) {
    $.ajax({ url: $(el).data('lock'), type: 'POST', data: { _method: "delete" }, async: false});
    $(el).removeAttr('data-lock');
  }

  connect() {
    $('[data-lock]').on('click', (e) => {
      this.delete_lock(e.target);
    })
  }
}