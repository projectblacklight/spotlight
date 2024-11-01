export default class {
  delete_lock(el) {
    $.ajax({ url: $(el).data('lock'), type: 'POST', data: { _method: "delete" }, headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }, async: false});
    $(el).removeAttr('data-lock');
  }

  connect() {
    $('[data-lock]').on('click', (e) => {
      this.delete_lock(e.target);
    })
  }
}