/*
  Sir Trevor Records Block.
  This block takes an array of record IDs,
  fetches them from solr, and displays them.
*/

SirTrevor.Blocks.RecordThumbnail =  (function(){

  var id_key = "record-thumbnail-id";
  var title_key = "show-title";

  var type = "record-thumbnail";

  var template = _.template([
    '<div class="form-inline">',
      '<label for="' + id_key + '">Record ID:</label>',
      '<input name="' + id_key + '"',
      ' class="st-input-string form-control st-required ' + type + '" type="text" id="' + id_key + '" />',
      '<label for"' + title_key + '">',
        '<input name="' + title_key + '" type="hidden" value="false" />',
        '<input name="' + title_key + '" id="' + title_key + '" type="checkbox" value="true" />',
        'Show title?',
      '</label>',
      '<span class="help-block">The record ID of a document in this collection.',
      'If you choose to show the title it will be displayed as a caption beneath the image.</span>',
    '</div>'
  ].join("\n"));

  return SirTrevor.Block.extend({

    type: type,

    title: function() { return "Record Thumbnail"; },

    editorHTML: function() {
      return template(this);
    },

    icon_name: type,

    toData: function() {
      var data = {};
      data[id_key] = this.$('#' + id_key).val();
      data[title_key] = this.$('#' + title_key).is(':checked');
      this.setData(data);
    },

    loadData: function(data){
      this.$('#' + id_key).val(data[id_key]);
      this.$('#' + title_key).prop('checked', data[title_key]);
    }
  });
})();