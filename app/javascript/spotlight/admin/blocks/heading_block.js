SirTrevor.Blocks.Heading = (function () {
  return SirTrevor.Blocks.Heading.extend({
    editorHTML: function() {
      return `<p>${i18n.t("blocks:heading:description")}</p><hr><h2 class="st-required st-text-block st-text-block--heading" contenteditable="true"></h2>`;
    }
  });
})();