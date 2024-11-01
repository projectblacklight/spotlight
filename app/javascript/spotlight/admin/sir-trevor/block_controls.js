import Core from 'spotlight/core'

(function() {
  var BLOCK_REPLACER_CONTROL_TEMPLATE = function(block) {
    var el = document.createElement('button');
    el.className = "st-block-controls__button";
    el.setAttribute('data-type', block.type);
    el.type = "button";

    var img = document.createElement('svg');
    img.className = "st-icon";
    img.setAttribute('role', 'img');

    var use = document.createElement('use');
    use.setAttributeNS('https://www.w3.org/1999/xlink', 'href', SirTrevor.config.defaults.iconUrl + "#" + block.icon_name);
    img.appendChild(use);
    el.appendChild(img);
    el.appendChild(document.createTextNode(block.title()));

    return el.outerHTML;
  };

  function generateBlocksHTML(Blocks, availableTypes) {
    var groups = {};
    for(var i in availableTypes) {
      var type = availableTypes[i];
      if (Blocks.hasOwnProperty(type) && Blocks[type].prototype.toolbarEnabled) {
        var blockGroup;

        if ($.isFunction(Blocks[type].prototype.blockGroup)) {
          blockGroup = Blocks[type].prototype.blockGroup();
        } else {
          blockGroup = Blocks[type].prototype.blockGroup;
        }

        if (blockGroup == 'undefined' || blockGroup === undefined) {
          blockGroup = i18n.t("blocks:group:undefined");
        }

        groups[blockGroup] = groups[blockGroup] || [];
        groups[blockGroup].push(BLOCK_REPLACER_CONTROL_TEMPLATE(Blocks[type].prototype));
      }
    }

    function generateBlock(groups, key) {
      var group   = groups[key];
      var groupEl = $("<div class='st-controls-group'><div class='st-group-col-form-label'>" + key + "</div></div>");
      var buttons = group.reduce(function(memo, btn) {
        return memo += btn;
      }, "");
      groupEl.append(buttons);
      return groupEl[0].outerHTML;
    }

    var standardWidgets = generateBlock(groups, i18n.t("blocks:group:undefined"));

    var exhibitWidgets = Object.keys(groups).map(function(key) {
      if (key !== i18n.t("blocks:group:undefined")) {
        return generateBlock(groups, key);
      }
    }).filter(function (element) {
      return element != null;
    });

    var blocks = [standardWidgets].concat(exhibitWidgets).join("<hr />");
    return blocks;
  }

  function render(Blocks, availableTypes) {
    var el = document.createElement('div');
    el.className = "st-block-controls__buttons";
    el.innerHTML = generateBlocksHTML.apply(null, arguments);

    var elButtons = document.createElement('div');
    elButtons.className = "spotlight-block-controls";
    elButtons.appendChild(el);
    return elButtons;
  }

  Core.BlockControls = function() { };
  Core.BlockControls.create = function(editor) {
    // REFACTOR - should probably not know about blockManager
    var el = render(SirTrevor.Blocks, editor.blockManager.blockTypes);

    function hide() {
      var parent = el.parentNode;
      if (!parent) { return; }
      parent.removeChild(el);
      parent.classList.remove("st-block--controls-active");
      return parent;
    }

    function destroy() {
      SirTrevor = null;
      el = null;
    }

    function insert(e) {
      e.stopPropagation();

      var parent = this.parentNode;
      if (!parent || hide() === parent) { return; }
      $('.st-block__inner', parent).after(el);
      parent.classList.add("st-block--controls-active");
    }

    function replaceBlock() {
      SirTrevor.mediator.trigger(
        "block:replace", el.parentNode, this.getAttribute('data-type')
      );
    }

    $(editor.wrapper).delegate(".st-block-replacer", "click", insert);
    $(editor.wrapper).delegate(".st-block-controls__button", "click", insert);

    return {
      el: el,
      hide: hide,
      destroy: destroy
    };
  };
})();
