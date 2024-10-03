import SirTrevor from 'sir-trevor'

(function ($){
  SirTrevor.BlockMixins.Plustextable = {
    mixinName: "Textable",
    preload: true,

    initializeTextable: function() {
      if (this['formId'] === undefined) {
        this.withMixin(SirTrevor.BlockMixins.Formable);
      }
      
      if (this['show_heading'] === undefined) {
        this.show_heading = true;
      }
    },
    
    align_key:"text-align",
    text_key:"item-text",
    heading_key: "title",
    
    text_area: function() { 
      return `
      <div class="row">
        <div class="col-md-8">
          <div class="form-group mb-3">
            ${this.heading()}
            <div class="field">
              <label for="${this.formId(this.text_key)}" class="col-form-label">${i18n.t("blocks:textable:text")}</label>
              <div id="${this.formId(this.text_key)}" class="st-text-block form-control" contenteditable="true"></div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="text-align">
            <p>${i18n.t("blocks:textable:align:title")}</p>
            <input data-key="${this.align_key}" type="radio" name="${this.formId(this.align_key)}" id="${this.formId(this.align_key + "-left")}" value="left" checked="true">
            <label for="${this.formId(this.align_key + "-left")}">${i18n.t("blocks:textable:align:left")}</label>
            <input data-key="${this.align_key}" type="radio" name="${this.formId(this.align_key)}" id="${this.formId(this.align_key + "-right")}" value="right">
            <label for="${this.formId(this.align_key + "-right")}">${i18n.t("blocks:textable:align:right")}</label>
          </div>
        </div>
      </div>`
    },
    
    heading: function() {
      if(this.show_heading) {
        return `<div class="field">
          <label for="${this.formId(this.heading_key)}" class="col-form-label">${i18n.t("blocks:textable:heading")}</label>
          <input type="text" class="form-control" id="${this.formId(this.heading_key)}" name="${this.heading_key}" />
        </div>`
      } else {
        return "";
      }
    },
  };
  

  SirTrevor.Block.prototype.availableMixins.push("plustextable");
})(jQuery);
