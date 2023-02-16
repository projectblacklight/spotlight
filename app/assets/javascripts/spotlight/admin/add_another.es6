export default class {
  connect() {
    $("[data-action='add-another']").on("click", function(event) {
      event.preventDefault();

      var templateId = $(this).data('template-id');

      var template = document.querySelector('#' + templateId);
      var clone = document.importNode(template.content, true);

      var count = $(this).closest('.form-group').find('[name="' + $(clone).find('[name]').attr('name') + '"]').length + 1;
      $(clone).find('[id]').each(function(index, el) {
        $(el).attr('id', $(el).attr('id') + '_' + String(count));
      });

      $(clone).find('[for]').each(function(index, el) {
        $(el).attr('for', $(el).attr('for') + '_' + String(count));
      });


      $(clone).insertBefore(this);
    });
  }
}
