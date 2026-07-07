import serializeJSON from "spotlight/admin/serialize_json"

function setElementValue(el, values) {
  var type = el.type || "";
  if (type === "checkbox" || type === "radio") {
    el.checked = values.indexOf(el.value) !== -1;
  } else if (el.nodeName.toLowerCase() === "select") {
    Array.prototype.forEach.call(el.options, function (opt) {
      opt.selected = values.indexOf(opt.value) !== -1;
    });
  } else {
    el.value = values[0] != null ? values[0] : "";
  }
}

SirTrevor.BlockMixins.Formable = {
  mixinName: "Formable",
  preload: true,

  initializeFormable: function() {

    if (this['afterLoadData'] === undefined) {
      this['afterLoadData'] = function(data) { };
    }
  },

  formId: function(id) {
    return this.blockID + "_" + id;
  },

  _serializeData: function() {
    var inputs = this.inner.querySelectorAll("input, select, textarea");
    var nonRadioInputs = Array.prototype.filter.call(inputs, function(el) {
      return el.type !== "radio";
    });
    var data = serializeJSON(nonRadioInputs);

    this.inner.querySelectorAll("input[type='radio']:checked").forEach(function(input) {
      var key = input.getAttribute('data-key') || input.getAttribute('name');

      if (key && !/\[/.test(key)) {
        data[key] = input.value;
      }
    });

    /* Simple to start. Add conditions later */
    if (this.hasTextBlock()) {
      data.text = this.getTextBlockHTML();
      data.format = 'html';
      if (data.text && data.text.length > 0 && this.options.convertToMarkdown) {
        data.text = stToMarkdown(data.text, this.type);
        data.format = 'markdown';
      }
    }

    return data;
  },

  loadData: function(data){
    if (this.hasTextBlock()) {
      if (data.text && data.text.length > 0 && this.options.convertFromMarkdown && data.format !== "html") {
        this.setTextBlockHTML(SirTrevor.toHTML(data.text, this.type));
      } else {
        this.setTextBlockHTML(data.text);
      }
    }
    this.loadFormDataByKey(data);
    this.afterLoadData(data);
  },

  loadFormDataByKey: function(data) {
    var elements = this.inner.querySelectorAll("input, select, textarea");
    Array.prototype.forEach.call(elements, function(input) {
      var type = input.type || "";
      if (type === "button" || type === "submit" || type === "hidden") return;

      var key = input.getAttribute('data-key') || input.getAttribute('name');

      if (key) {

        if (/\[\]$/.test(key)) {
          key = key.replace("[]", "");
        }

        // by wrapping it in an array, this'll "just work" for radio and checkbox fields too
        var input_data = data[key];

        if (!(input_data instanceof Array)) {
          input_data = [input_data];
        }
        setElementValue(input, input_data);
      }
    });
  },
};


SirTrevor.Block.prototype.availableMixins.push("formable");
