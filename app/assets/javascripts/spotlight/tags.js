Spotlight.onLoad(function(){
  var tagsControls = $('.assign-tags');

  tagsControls.multiselect();

  $('.destroy-row').on('change', function() {
    var checked = $(this).filter(':checked');

    if(checked.length > 0) {
      var row = checked.closest('tr');
      var id = row.data('original-name');

      row.hide();
      tagsControls.find('option[value="' + id + '"]').remove();
      tagsControls.multiselect('rebuild');
    }
  });

  function attachTagListener(el) {
    var id = $(el).closest('tr').data('original-name');
    var val = $(el).val();

    if (tagsControls.find('option[value="' + id + '"]').length > 0) {
      tagsControls.find('option[value="' + id + '"]').text(val).attr('value', val);
    } else {
      var opt = $('<option>').text(val).attr('value', val);
      tagsControls.append(opt);
    }

    tagsControls.multiselect('rebuild');

    $(el).closest('tr').data('original-name', val);
  }

  $('.tag_name').on('change', function() {
    attachTagListener(this);
  });

  $('#add-new-tag').on('click', function(event) {
    event.stopPropagation();

    $('#no-tags-warning').hide();

    var container = $($(this).data('target'));
    var template = $($(this).data('template-target')).find('tr');
    var tags = container.find('tr');
    var row = template.clone();

    row.show();

    row.data('original-name', '');
    row.removeAttr('data-original-name');

    // wipe out any values from the inputs
    row.find('input').each(function() {
      $(this).filter(':hidden').val('');
      $(this).filter(':checkbox').prop('checked', false);
      $(this).attr('id', $(this).attr('id').replace('0', tags.length));
      $(this).attr('name', $(this).attr('name').replace('0', tags.length));
    });

    row.find('.tag_name').on('change', function() {
      attachTagListener(this);
    });

    row.find('.field-label').html('New Tag');

    row.find('[data-in-place-edit-target]').spotlightEditInPlace();

    container.append(row);
    row.find('.field-label').click();
  });

});