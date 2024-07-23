(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.Spotlight = factory());
})(this, (function () { 'use strict';

  class BrowseGroupCateogries {
    connect() {
      var $container, slider;

      function init() {
        var data = $container.data();
        var sidebar = $container.data().sidebar;
        var items = data.browseGroupCategoriesCount;
        var dir = $('html').attr('dir');
        var controls = $container.parent().find('.browse-group-categories-controls')[0];

        slider = tns({
          container: $container[0],
          controlsContainer: controls,
          loop: false,
          nav: false,
          items: 1,
          slideBy: 'page',
          textDirection: dir,
          responsive: {
            576: {
              items: itemCount(items, sidebar)
            }
          }
        });
      }

      // Destroy the slider instance, as tns will change the dom elements, causing some issues with turbolinks
      function setupDestroy() {
        document.addEventListener('turbolinks:before-cache', function() {
          if (slider && slider.destroy) {
            slider.destroy();
          }
        });
      }

      function itemCount(items, sidebar) {
        if (items < 3) {
          return items;
        }
        return sidebar ? 3 : 4;
      }

      return $('[data-browse-group-categories-carousel]').each(function() {
        $container = $(this);
        init();
        setupDestroy();
      });
    }
  }

  class Carousel {
    connect() {
      $('.carousel').carousel();
    }
  }

  class ClearFormButton {
    connect() {
      var $clearBtn = $('.btn-reset');
      var $input = $clearBtn.parent().prev('input');
      var btnCheck = function(){
        if ($input.val() !== '') {
          $clearBtn.css('display', 'inline-block');
        } else {
          $clearBtn.css('display', 'none');
        }
      };

      btnCheck();
      $input.on('keyup', function() {
        btnCheck();
      });

      $clearBtn.on('click', function(event) {
        event.preventDefault();
        $input.val('');
      });
    }
  }

  class ReportProblem {
    connect(){
      var container, target;

      function init() {
        const target_val = container.attr('data-target');
        if (!target_val) 
          return

        target = $("#" + target_val); 
        container.on('click', open);
        target.find('[data-behavior="cancel-link"]').on('click', close);
      }

      function open(event) {
        event.preventDefault();
        target.slideToggle('slow');
      }

      function close(event) {
        event.preventDefault();
        target.slideUp('fast');
      }

      return $('[data-behavior="contact-link"]').each(function() {        
        container = $(this);
        init();
      });
    }
  }

  class ZprLinks {
    connect() {
      $('.zpr-link').on('click', function() {
        var modalDialog = $('#blacklight-modal .modal-dialog');
        var modalContent = modalDialog.find('.modal-content');
        modalDialog.removeClass('modal-lg');
        modalDialog.addClass('modal-xl');
        modalContent.html('<div id="osd-modal-container"></div>');
        var controls = `<div class="controls d-flex justify-content-center justify-content-md-end">
          <div class="custom-close-controls pr-3 pt-3">
            <button type="button" class="btn btn-dark" data-dismiss="modal" aria-hidden="true">${Spotlight.ZprLinks.close}</button>
          </div>
          <div class="zoom-controls mb-3 mr-md-3">
            <button id="osd-zoom-in" type="button" class="btn btn-dark">${Spotlight.ZprLinks.zoomIn}</button>
            <button id="osd-zoom-out" type="button" class="btn btn-dark">${Spotlight.ZprLinks.zoomOut}</button>
          </div>
          <div id="empty-div-required-by-osd"></div>
        </div>`;

        $('#osd-modal-container').append('<div id="osd-div"></div>');
        $('#osd-modal-container').append(controls);

        $('#blacklight-modal').modal('show');
        
        $('#blacklight-modal').one('hidden.bs.modal', function (event) {
          modalDialog.removeClass('modal-xl');
          modalDialog.addClass('modal-lg');
        });

        OpenSeadragon({
          id: 'osd-div',
          zoomInButton: "osd-zoom-in",
          zoomOutButton: "osd-zoom-out",
          // This is a hack where OpenSeadragon (if using mapped buttons) requires you
          // to map all of the buttons.
          homeButton: "empty-div-required-by-osd",
          fullPageButton: "empty-div-required-by-osd",
          nextButton: "empty-div-required-by-osd",
          previousButton: "empty-div-required-by-osd",
          tileSources: [$(this).data('iiif-tilesource')]
        });
      });
    }
  }

  class UserIndex {
    connect() {
      new BrowseGroupCateogries().connect();
      new Carousel().connect();
      new ClearFormButton().connect();
      new ReportProblem().connect();
      new ZprLinks().connect();
    }
  }

  /*!
   * Nestable jQuery Plugin - Copyright (c) 2012 David Bushell - http://dbushell.com/
   * Dual-licensed under the BSD or MIT licenses
   */
  (function($, window, document, undefined$1)
  {
      var hasTouch = 'ontouchstart' in window;

      /**
       * Detect CSS pointer-events property
       * events are normally disabled on the dragging element to avoid conflicts
       * https://github.com/ausi/Feature-detection-technique-for-pointer-events/blob/master/modernizr-pointerevents.js
       */
      var hasPointerEvents = (function()
      {
          var el    = document.createElement('div'),
              docEl = document.documentElement;
          if (!('pointerEvents' in el.style)) {
              return false;
          }
          el.style.pointerEvents = 'auto';
          el.style.pointerEvents = 'x';
          docEl.appendChild(el);
          var supports = window.getComputedStyle && window.getComputedStyle(el, '').pointerEvents === 'auto';
          docEl.removeChild(el);
          return !!supports;
      })();

      var eStart  = hasTouch ? 'touchstart'  : 'mousedown',
           eMove   = hasTouch ? 'touchmove'   : 'mousemove',
           eEnd    = hasTouch ? 'touchend'    : 'mouseup',
           eCancel = hasTouch ? 'touchcancel' : 'mouseup';
            
      var defaults = {
          listNodeName    : 'ol',
          itemNodeName    : 'li',
          rootClass       : 'dd',
          listClass       : 'dd-list',
          itemClass       : 'dd-item',
          dragClass       : 'dd-dragel',
          handleClass     : 'dd-handle',
          collapsedClass  : 'dd-collapsed',
          placeClass      : 'dd-placeholder',
          noDragClass     : 'dd-nodrag',
          noChildrenClass : 'dd-nochildren',
          emptyClass      : 'dd-empty',
          expandBtnHTML   : '<button data-action="expand" type="button">Expand</button>',
          collapseBtnHTML : '<button data-action="collapse" type="button">Collapse</button>',
          group           : 0,
          maxDepth        : 5,
          threshold       : 20,
          reject          : [],
          //method for call when an item has been successfully dropped
          //method has 1 argument in which sends an object containing all
          //necessary details
          dropCallback    : null,
        // When a node is dragged it is moved to its new location.
        // You can set the next option to true to create a copy of the node  that is dragged.
        cloneNodeOnDrag   : false,
        // When the node is dragged and released outside its list delete it.
        dragOutsideToDelete : false
      };

      function Plugin(element, options)
      {
          this.w = $(document);
          this.el = $(element);
          this.options = $.extend({}, defaults, options);
          this.init();
      }

      Plugin.prototype = {

          init: function()
          {
              var list = this;

              list.reset();

              list.el.data('nestable-group', this.options.group);

              list.placeEl = $('<div class="' + list.options.placeClass + '"/>');

              $.each(this.el.find(list.options.itemNodeName), function(k, el) {
                  list.setParent($(el));
              });

              list.el.on('click', 'button', function(e)
              {
                  if (list.dragEl || (!hasTouch && e.button !== 0)) {
                      return;
                  }
                  var target = $(e.currentTarget),
                      action = target.data('action'),
                      item   = target.parent(list.options.itemNodeName);
                  if (action === 'collapse') {
                      list.collapseItem(item);
                  }
                  if (action === 'expand') {
                      list.expandItem(item);
                  }
              });

              var onStartEvent = function(e)
              {
                  var handle = $(e.target);

                  list.nestableCopy = handle.closest('.'+list.options.rootClass).clone(true);

                  if (!handle.hasClass(list.options.handleClass)) {
                      if (handle.closest('.' + list.options.noDragClass).length) {
                          return;
                      }
                      handle = handle.closest('.' + list.options.handleClass);
                  }
                  if (!handle.length || list.dragEl || (!hasTouch && e.which !== 1) || (hasTouch && e.touches.length !== 1)) {
                      return;
                  }
                  e.preventDefault();
                  list.dragStart(hasTouch ? e.touches[0] : e);
              };

              var onMoveEvent = function(e)
              {
                  if (list.dragEl) {
                      e.preventDefault();
                      list.dragMove(hasTouch ? e.touches[0] : e);
                  }
              };

              var onEndEvent = function(e)
              {
                  if (list.dragEl) {
                      e.preventDefault();
                      list.dragStop(hasTouch ? e.touches[0] : e);
                  }
              };

              if (hasTouch) {
                  list.el[0].addEventListener(eStart, onStartEvent, false);
                  window.addEventListener(eMove, onMoveEvent, false);
                  window.addEventListener(eEnd, onEndEvent, false);
                  window.addEventListener(eCancel, onEndEvent, false);
              } else {
                  list.el.on(eStart, onStartEvent);
                  list.w.on(eMove, onMoveEvent);
                  list.w.on(eEnd, onEndEvent);
              }

              var destroyNestable = function()
              {
                  if (hasTouch) {
                      list.el[0].removeEventListener(eStart, onStartEvent, false);
                      window.removeEventListener(eMove, onMoveEvent, false);
                      window.removeEventListener(eEnd, onEndEvent, false);
                      window.removeEventListener(eCancel, onEndEvent, false);
                  } else {
                      list.el.off(eStart, onStartEvent);
                      list.w.off(eMove, onMoveEvent);
                      list.w.off(eEnd, onEndEvent);
                  }

                  list.el.off('click');
                  list.el.unbind('destroy-nestable');

                  list.el.data("nestable", null);

                  var buttons = list.el[0].getElementsByTagName('button');

                  $(buttons).remove();
              };

              list.el.bind('destroy-nestable', destroyNestable);
          },

          destroy: function ()
          {
              this.expandAll();
              this.el.trigger('destroy-nestable');
          },

          serialize: function()
          {
              var data,
                  list  = this;
              const step  = function(level, depth)
                  {
                      var array = [ ],
                          items = level.children(list.options.itemNodeName);
                      items.each(function()
                      {
                          var li   = $(this),
                              item = $.extend({}, li.data()),
                              sub  = li.children(list.options.listNodeName);
                          if (sub.length) {
                              item.children = step(sub);
                          }
                          array.push(item);
                      });
                      return array;
                  };
              var el;

              if (list.el.is(list.options.listNodeName)) {
                  el = list.el;
              } else {
                  el = list.el.find(list.options.listNodeName).first();
              }
              data = step(el);
              return data;
          },

          reset: function()
          {
              this.mouse = {
                  offsetX   : 0,
                  offsetY   : 0,
                  startX    : 0,
                  startY    : 0,
                  lastX     : 0,
                  lastY     : 0,
                  nowX      : 0,
                  nowY      : 0,
                  distX     : 0,
                  distY     : 0,
                  dirAx     : 0,
                  dirX      : 0,
                  dirY      : 0,
                  lastDirX  : 0,
                  lastDirY  : 0,
                  distAxX   : 0,
                  distAxY   : 0
              };
              this.moving     = false;
              this.dragEl     = null;
              this.dragRootEl = null;
              this.dragDepth  = 0;
              this.dragItem   = null;
              this.hasNewRoot = false;
              this.pointEl    = null;
              this.sourceRoot = null;
              this.isOutsideRoot = false;
          },

          expandItem: function(li)
          {
              li.removeClass(this.options.collapsedClass);
              li.children('[data-action="expand"]').hide();
              li.children('[data-action="collapse"]').show();
              li.children(this.options.listNodeName).show();
              this.el.trigger('expand', [li]);
              li.trigger('expand');
          },

          collapseItem: function(li)
          {
              var lists = li.children(this.options.listNodeName);
              if (lists.length) {
                  li.addClass(this.options.collapsedClass);
                  li.children('[data-action="collapse"]').hide();
                  li.children('[data-action="expand"]').show();
                  li.children(this.options.listNodeName).hide();
              }
              this.el.trigger('collapse', [li]);
              li.trigger('collapse');
          },

          expandAll: function()
          {
              var list = this;
              list.el.find(list.options.itemNodeName).each(function() {
                  list.expandItem($(this));
              });
          },

          collapseAll: function()
          {
              var list = this;
              list.el.find(list.options.itemNodeName).each(function() {
                  list.collapseItem($(this));
              });
          },

          setParent: function(li)
          {
              if (li.children(this.options.listNodeName).length) {
                  li.prepend($(this.options.expandBtnHTML));
                  li.prepend($(this.options.collapseBtnHTML));
              }
              if( (' ' + li[0].className + ' ').indexOf(' ' + defaults.collapsedClass + ' ') > -1 )
              {
                  li.children('[data-action="collapse"]').hide();
              } else {
                  li.children('[data-action="expand"]').hide();
              }
          },

          unsetParent: function(li)
          {
              li.removeClass(this.options.collapsedClass);
              li.children('[data-action]').remove();
              li.children(this.options.listNodeName).remove();
          },

          dragStart: function(e)
          {
              var mouse    = this.mouse,
                  target   = $(e.target),
                  dragItem = target.closest('.' + this.options.handleClass).closest(this.options.itemNodeName);

              this.sourceRoot = target.closest('.' + this.options.rootClass);

              this.dragItem = dragItem;

              this.placeEl.css('height', dragItem.height());

              mouse.offsetX = e.offsetX !== undefined$1 ? e.offsetX : e.pageX - target.offset().left;
              mouse.offsetY = e.offsetY !== undefined$1 ? e.offsetY : e.pageY - target.offset().top;
              mouse.startX = mouse.lastX = e.pageX;
              mouse.startY = mouse.lastY = e.pageY;

              this.dragRootEl = this.el;

              this.dragEl = $(document.createElement(this.options.listNodeName)).addClass(this.options.listClass + ' ' + this.options.dragClass);
              this.dragEl.css('width', dragItem.width());

              // fix for zepto.js
              //dragItem.after(this.placeEl).detach().appendTo(this.dragEl);
              if(this.options.cloneNodeOnDrag) {
                  dragItem.after(dragItem.clone());
              } else {
                  dragItem.after(this.placeEl);
              }
              dragItem[0].parentNode.removeChild(dragItem[0]);
              dragItem.appendTo(this.dragEl);

              $(document.body).append(this.dragEl);
              this.dragEl.css({
                  'left' : e.pageX - mouse.offsetX,
                  'top'  : e.pageY - mouse.offsetY
              });
              // total depth of dragging item
              var i, depth,
                  items = this.dragEl.find(this.options.itemNodeName);
              for (i = 0; i < items.length; i++) {
                  depth = $(items[i]).parents(this.options.listNodeName).length;
                  if (depth > this.dragDepth) {
                      this.dragDepth = depth;
                  }
              }
          },

          dragStop: function(e)
          {
              // fix for zepto.js
              //this.placeEl.replaceWith(this.dragEl.children(this.options.itemNodeName + ':first').detach());
              var el = this.dragEl.children(this.options.itemNodeName).first();
              el[0].parentNode.removeChild(el[0]);

              if(this.isOutsideRoot && this.options.dragOutsideToDelete)
                  {
                  var parent = this.placeEl.parent();
                  this.placeEl.remove();
                  if (!parent.children().length) {
                      this.unsetParent(parent.parent());
                  }
                  // If all nodes where deleted, create a placeholder element.
                  if (!this.dragRootEl.find(this.options.itemNodeName).length)
                       {
                      this.dragRootEl.append('<div class="' + this.options.emptyClass + '"/>');
                  }
              } 
                  else 
                  {
                  this.placeEl.replaceWith(el);
              }

              if (!this.moving)
              {
                  $(this.dragItem).trigger('click');
              }

              var i;
              var isRejected = false;
              for (i = 0; i < this.options.reject.length; i++)
              {
                  var reject = this.options.reject[i];
                  if (reject.rule.apply(this.dragRootEl))
                  {
                      var nestableDragEl = el.clone(true);
                      this.dragRootEl.html(this.nestableCopy.children().clone(true));
                      if (reject.action) {
                          reject.action.apply(this.dragRootEl, [nestableDragEl]);
                      }

                      isRejected = true;
                      break;
                  }
              }

              if (!isRejected)
              {
                  this.dragEl.remove();
                  this.el.trigger('change');

                  //Let's find out new parent id
                  var parentItem = el.parent().parent();
                  var parentId = null;
                  if(parentItem !== null && !parentItem.is('.' + this.options.rootClass))
                      parentId = parentItem.data('id');

                  if($.isFunction(this.options.dropCallback))
                  {
                      var details = {
                          sourceId   : el.data('id'),
                          destId     : parentId,
                          sourceEl   : el,
                          destParent : parentItem,
                          destRoot   : el.closest('.' + this.options.rootClass),
                          sourceRoot : this.sourceRoot
                    };
                    this.options.dropCallback.call(this, details);
                  }

                  if (this.hasNewRoot) {
                      this.dragRootEl.trigger('change');
                  }

                  this.reset();
              }
          },

          dragMove: function(e)
          {
              var list, parent, prev, next, depth,
                  opt   = this.options,
                  mouse = this.mouse;

              this.dragEl.css({
                  'left' : e.pageX - mouse.offsetX,
                  'top'  : e.pageY - mouse.offsetY
              });

              // mouse position last events
              mouse.lastX = mouse.nowX;
              mouse.lastY = mouse.nowY;
              // mouse position this events
              mouse.nowX  = e.pageX;
              mouse.nowY  = e.pageY;
              // distance mouse moved between events
              mouse.distX = mouse.nowX - mouse.lastX;
              mouse.distY = mouse.nowY - mouse.lastY;
              // direction mouse was moving
              mouse.lastDirX = mouse.dirX;
              mouse.lastDirY = mouse.dirY;
              // direction mouse is now moving (on both axis)
              mouse.dirX = mouse.distX === 0 ? 0 : mouse.distX > 0 ? 1 : -1;
              mouse.dirY = mouse.distY === 0 ? 0 : mouse.distY > 0 ? 1 : -1;
              // axis mouse is now moving on
              var newAx   = Math.abs(mouse.distX) > Math.abs(mouse.distY) ? 1 : 0;

              // do nothing on first move
              if (!this.moving) {
                  mouse.dirAx  = newAx;
                  this.moving = true;
                  return;
              }

              // calc distance moved on this axis (and direction)
              if (mouse.dirAx !== newAx) {
                  mouse.distAxX = 0;
                  mouse.distAxY = 0;
              } else {
                  mouse.distAxX += Math.abs(mouse.distX);
                  if (mouse.dirX !== 0 && mouse.dirX !== mouse.lastDirX) {
                      mouse.distAxX = 0;
                  }
                  mouse.distAxY += Math.abs(mouse.distY);
                  if (mouse.dirY !== 0 && mouse.dirY !== mouse.lastDirY) {
                      mouse.distAxY = 0;
                  }
              }
              mouse.dirAx = newAx;

              /**
               * move horizontal
               */
              if (mouse.dirAx && mouse.distAxX >= opt.threshold) {
                  // reset move distance on x-axis for new phase
                  mouse.distAxX = 0;
                  prev = this.placeEl.prev(opt.itemNodeName);
                  // increase horizontal level if previous sibling exists and is not collapsed
                  if (mouse.distX > 0 && prev.length && !prev.hasClass(opt.collapsedClass) && !prev.hasClass(opt.noChildrenClass)) {
                      // cannot increase level when item above is collapsed
                      list = prev.find(opt.listNodeName).last();
                      // check if depth limit has reached
                      depth = this.placeEl.parents(opt.listNodeName).length;
                      if (depth + this.dragDepth <= opt.maxDepth) {
                          // create new sub-level if one doesn't exist
                          if (!list.length) {
                              list = $('<' + opt.listNodeName + '/>').addClass(opt.listClass);
                              list.append(this.placeEl);
                              prev.append(list);
                              this.setParent(prev);
                          } else {
                              // else append to next level up
                              list = prev.children(opt.listNodeName).last();
                              list.append(this.placeEl);
                          }
                      }
                  }
                  // decrease horizontal level
                  if (mouse.distX < 0) {
                      // we can't decrease a level if an item preceeds the current one
                      next = this.placeEl.next(opt.itemNodeName);
                      if (!next.length) {
                          parent = this.placeEl.parent();
                          this.placeEl.closest(opt.itemNodeName).after(this.placeEl);
                          if (!parent.children().length) {
                              this.unsetParent(parent.parent());
                          }
                      }
                  }
              }

              var isEmpty = false;

              // find list item under cursor
              if (!hasPointerEvents) {
                  this.dragEl[0].style.visibility = 'hidden';
              }
                  
              this.pointEl = $(document.elementFromPoint(e.pageX - document.documentElement.scrollLeft, e.pageY - (window.pageYOffset || document.documentElement.scrollTop)));

              // Check if the node is dragged outside of its list.
              if(this.dragRootEl.has(this.pointEl).length) {
                  this.isOutsideRoot = false;
                  this.dragEl[0].style.opacity = 1;
              } else {
                  this.isOutsideRoot = true;
                  this.dragEl[0].style.opacity = 0.5;
              }

              // find parent list of item under cursor
              var pointElRoot = this.pointEl.closest('.' + opt.rootClass),
                  isNewRoot   = this.dragRootEl.data('nestable-id') !== pointElRoot.data('nestable-id');

              this.isOutsideRoot = !pointElRoot.length;

              if (!hasPointerEvents) {
                  this.dragEl[0].style.visibility = 'visible';
              }
              if (this.pointEl.hasClass(opt.handleClass)) {
                  this.pointEl = this.pointEl.closest( opt.itemNodeName );
              }

              if (opt.maxDepth == 1 && !this.pointEl.hasClass(opt.itemClass)) {
                  this.pointEl = this.pointEl.closest("." + opt.itemClass);
              }

              if (this.pointEl.hasClass(opt.emptyClass)) {
                  isEmpty = true;
              }
              else if (!this.pointEl.length || !this.pointEl.hasClass(opt.itemClass)) {
                  return;
              }

              /**
               * move vertical
               */
              if (!mouse.dirAx || isNewRoot || isEmpty) {
                  // check if groups match if dragging over new root
                  if (isNewRoot && opt.group !== pointElRoot.data('nestable-group')) {
                      return;
                  }
                  // check depth limit
                  depth = this.dragDepth - 1 + this.pointEl.parents(opt.listNodeName).length;
                  if (depth > opt.maxDepth) {
                      return;
                  }
                  var before = e.pageY < (this.pointEl.offset().top + this.pointEl.height() / 2);
                      parent = this.placeEl.parent();
                  // if empty create new list to replace empty placeholder
                  if (isEmpty) {
                      list = $(document.createElement(opt.listNodeName)).addClass(opt.listClass);
                      list.append(this.placeEl);
                      this.pointEl.replaceWith(list);
                  }
                  else if (before) {
                      this.pointEl.before(this.placeEl);
                  }
                  else {
                      this.pointEl.after(this.placeEl);
                  }
                  if (!parent.children().length) {
                      this.unsetParent(parent.parent());
                  }
                  if (!this.dragRootEl.find(opt.itemNodeName).length) {
                      this.dragRootEl.append('<div class="' + opt.emptyClass + '"/>');
                  }
                  // parent root list has changed
                  this.dragRootEl = pointElRoot;
                  if (isNewRoot) {
                      this.hasNewRoot = this.el[0] !== this.dragRootEl[0];
                  }
              }
          }

      };

      $.fn.nestable = function(params)
      {
          var lists  = this,
              retval = this;

          var generateUid = function (separator) {
              var delim = separator || "-";

              function S4() {
                  return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
              }

              return (S4() + S4() + delim + S4() + delim + S4() + delim + S4() + delim + S4() + S4() + S4());
          };

          lists.each(function()
          {
              var plugin = $(this).data("nestable");

              if (!plugin) {
                  $(this).data("nestable", new Plugin(this, params));
                  $(this).data("nestable-id", generateUid());
              } else {
                  if (typeof params === 'string' && typeof plugin[params] === 'function') {
                      retval = plugin[params]();
                  }
              }
          });

          return retval || lists;
      };

  })(window.jQuery || window.Zepto, window, document);

  /*
  https://gist.github.com/pjambet/3710461
  */
  var LATIN_MAP = {
    'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A', 'Æ': 'AE', 'Ç':
    'C', 'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', 'Ì': 'I', 'Í': 'I', 'Î': 'I',
    'Ï': 'I', 'Ð': 'D', 'Ñ': 'N', 'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö':
    'O', 'Ő': 'O', 'Ø': 'O', 'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U', 'Ű': 'U',
    'Ý': 'Y', 'Þ': 'TH', 'ß': 'ss', 'à':'a', 'á':'a', 'â': 'a', 'ã': 'a', 'ä':
    'a', 'å': 'a', 'æ': 'ae', 'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ð': 'd', 'ñ': 'n', 'ò': 'o', 'ó':
    'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ő': 'o', 'ø': 'o', 'ù': 'u', 'ú': 'u',
    'û': 'u', 'ü': 'u', 'ű': 'u', 'ý': 'y', 'þ': 'th', 'ÿ': 'y'
  };
  var LATIN_SYMBOLS_MAP = {
    '©':'(c)'
  };
  var GREEK_MAP = {
    'α':'a', 'β':'b', 'γ':'g', 'δ':'d', 'ε':'e', 'ζ':'z', 'η':'h', 'θ':'8',
    'ι':'i', 'κ':'k', 'λ':'l', 'μ':'m', 'ν':'n', 'ξ':'3', 'ο':'o', 'π':'p',
    'ρ':'r', 'σ':'s', 'τ':'t', 'υ':'y', 'φ':'f', 'χ':'x', 'ψ':'ps', 'ω':'w',
    'ά':'a', 'έ':'e', 'ί':'i', 'ό':'o', 'ύ':'y', 'ή':'h', 'ώ':'w', 'ς':'s',
    'ϊ':'i', 'ΰ':'y', 'ϋ':'y', 'ΐ':'i',
    'Α':'A', 'Β':'B', 'Γ':'G', 'Δ':'D', 'Ε':'E', 'Ζ':'Z', 'Η':'H', 'Θ':'8',
    'Ι':'I', 'Κ':'K', 'Λ':'L', 'Μ':'M', 'Ν':'N', 'Ξ':'3', 'Ο':'O', 'Π':'P',
    'Ρ':'R', 'Σ':'S', 'Τ':'T', 'Υ':'Y', 'Φ':'F', 'Χ':'X', 'Ψ':'PS', 'Ω':'W',
    'Ά':'A', 'Έ':'E', 'Ί':'I', 'Ό':'O', 'Ύ':'Y', 'Ή':'H', 'Ώ':'W', 'Ϊ':'I',
    'Ϋ':'Y'
  };
  var TURKISH_MAP = {
    'ş':'s', 'Ş':'S', 'ı':'i', 'İ':'I', 'ç':'c', 'Ç':'C', 'ü':'u', 'Ü':'U',
    'ö':'o', 'Ö':'O', 'ğ':'g', 'Ğ':'G'
  };
  var RUSSIAN_MAP = {
    'а':'a', 'б':'b', 'в':'v', 'г':'g', 'д':'d', 'е':'e', 'ё':'yo', 'ж':'zh',
    'з':'z', 'и':'i', 'й':'j', 'к':'k', 'л':'l', 'м':'m', 'н':'n', 'о':'o',
    'п':'p', 'р':'r', 'с':'s', 'т':'t', 'у':'u', 'ф':'f', 'х':'h', 'ц':'c',
    'ч':'ch', 'ш':'sh', 'щ':'sh', 'ъ':'', 'ы':'y', 'ь':'', 'э':'e', 'ю':'yu',
    'я':'ya',
    'А':'A', 'Б':'B', 'В':'V', 'Г':'G', 'Д':'D', 'Е':'E', 'Ё':'Yo', 'Ж':'Zh',
    'З':'Z', 'И':'I', 'Й':'J', 'К':'K', 'Л':'L', 'М':'M', 'Н':'N', 'О':'O',
    'П':'P', 'Р':'R', 'С':'S', 'Т':'T', 'У':'U', 'Ф':'F', 'Х':'H', 'Ц':'C',
    'Ч':'Ch', 'Ш':'Sh', 'Щ':'Sh', 'Ъ':'', 'Ы':'Y', 'Ь':'', 'Э':'E', 'Ю':'Yu',
    'Я':'Ya'
  };
  var UKRAINIAN_MAP = {
    'Є':'Ye', 'І':'I', 'Ї':'Yi', 'Ґ':'G', 'є':'ye', 'і':'i', 'ї':'yi', 'ґ':'g'
  };
  var CZECH_MAP = {
    'č':'c', 'ď':'d', 'ě':'e', 'ň': 'n', 'ř':'r', 'š':'s', 'ť':'t', 'ů':'u',
    'ž':'z', 'Č':'C', 'Ď':'D', 'Ě':'E', 'Ň': 'N', 'Ř':'R', 'Š':'S', 'Ť':'T',
    'Ů':'U', 'Ž':'Z'
  };

  var POLISH_MAP = {
    'ą':'a', 'ć':'c', 'ę':'e', 'ł':'l', 'ń':'n', 'ó':'o', 'ś':'s', 'ź':'z',
    'ż':'z', 'Ą':'A', 'Ć':'C', 'Ę':'e', 'Ł':'L', 'Ń':'N', 'Ó':'o', 'Ś':'S',
    'Ź':'Z', 'Ż':'Z'
  };

  var LATVIAN_MAP = {
    'ā':'a', 'č':'c', 'ē':'e', 'ģ':'g', 'ī':'i', 'ķ':'k', 'ļ':'l', 'ņ':'n',
    'š':'s', 'ū':'u', 'ž':'z', 'Ā':'A', 'Č':'C', 'Ē':'E', 'Ģ':'G', 'Ī':'i',
    'Ķ':'k', 'Ļ':'L', 'Ņ':'N', 'Š':'S', 'Ū':'u', 'Ž':'Z'
  };

  var ALL_DOWNCODE_MAPS=new Array();
  ALL_DOWNCODE_MAPS[0]=LATIN_MAP;
  ALL_DOWNCODE_MAPS[1]=LATIN_SYMBOLS_MAP;
  ALL_DOWNCODE_MAPS[2]=GREEK_MAP;
  ALL_DOWNCODE_MAPS[3]=TURKISH_MAP;
  ALL_DOWNCODE_MAPS[4]=RUSSIAN_MAP;
  ALL_DOWNCODE_MAPS[5]=UKRAINIAN_MAP;
  ALL_DOWNCODE_MAPS[6]=CZECH_MAP;
  ALL_DOWNCODE_MAPS[7]=POLISH_MAP;
  ALL_DOWNCODE_MAPS[8]=LATVIAN_MAP;

  var Downcoder = new Object();
  Downcoder.Initialize = function()
  {
    if (Downcoder.map) // already made
      return ;
      Downcoder.map ={};
      Downcoder.chars = '' ;
      for(var i in ALL_DOWNCODE_MAPS)
      {
        var lookup = ALL_DOWNCODE_MAPS[i];
        for (var c in lookup)
        {
          Downcoder.map[c] = lookup[c] ;
          Downcoder.chars += c ;
        }
      }
      Downcoder.regex = new RegExp('[' + Downcoder.chars + ']|[^' + Downcoder.chars + ']+','g') ;
    };

  /*!
    SerializeJSON jQuery plugin.
    https://github.com/marioizquierdo/jquery.serializeJSON
    version 2.4.2 (Oct, 2014)

    Copyright (c) 2014 Mario Izquierdo
    Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
    and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
  */
  (function ($) {

    // jQuery('form').serializeJSON()
    $.fn.serializeJSON = function (options) {
      var serializedObject, formAsArray, keys, type, value, f, opts;
      f = $.serializeJSON;
      opts = f.optsWithDefaults(options); // calculate values for options {parseNumbers, parseBoolens, parseNulls}
      f.validateOptions(opts);
      formAsArray = this.serializeArray(); // array of objects {name, value}
      f.readCheckboxUncheckedValues(formAsArray, this, opts); // add {name, value} of unchecked checkboxes if needed

      serializedObject = {};
      $.each(formAsArray, function (i, input) {
        keys = f.splitInputNameIntoKeysArray(input.name);
        type = keys.pop(); // the last element is always the type ("string" by default)
        if (type !== 'skip') { // easy way to skip a value
          value = f.parseValue(input.value, type, opts); // string, number, boolean or null
          if (opts.parseWithFunction && type === '_') value = opts.parseWithFunction(value, input.name); // allow for custom parsing
          f.deepSet(serializedObject, keys, value, opts);
        }
      });
      return serializedObject;
    };

    // Use $.serializeJSON as namespace for the auxiliar functions
    // and to define defaults
    $.serializeJSON = {

      defaultOptions: {
        parseNumbers: false, // convert values like "1", "-2.33" to 1, -2.33
        parseBooleans: false, // convert "true", "false" to true, false
        parseNulls: false, // convert "null" to null
        parseAll: false, // all of the above
        parseWithFunction: null, // to use custom parser, a function like: function(val){ return parsed_val; }
        checkboxUncheckedValue: undefined, // to include that value for unchecked checkboxes (instead of ignoring them)
        useIntKeysAsArrayIndex: false // name="foo[2]" value="v" => {foo: [null, null, "v"]}, instead of {foo: ["2": "v"]}
      },

      // Merge options with defaults to get {parseNumbers, parseBoolens, parseNulls, useIntKeysAsArrayIndex}
      optsWithDefaults: function(options) {
        var f, parseAll;
        if (options == null) options = {}; // arg default value = {}
        f = $.serializeJSON;
        parseAll = f.optWithDefaults('parseAll', options);
        return {
          parseNumbers:  parseAll || f.optWithDefaults('parseNumbers',  options),
          parseBooleans: parseAll || f.optWithDefaults('parseBooleans', options),
          parseNulls:    parseAll || f.optWithDefaults('parseNulls',    options),
          parseWithFunction:         f.optWithDefaults('parseWithFunction', options),
          checkboxUncheckedValue:    f.optWithDefaults('checkboxUncheckedValue', options),
          useIntKeysAsArrayIndex:    f.optWithDefaults('useIntKeysAsArrayIndex', options)
        }
      },

      optWithDefaults: function(key, options) {
        return (options[key] !== false) && (options[key] !== '') && (options[key] || $.serializeJSON.defaultOptions[key]);
      },

      validateOptions: function(opts) {
        var opt, validOpts;
        validOpts = ['parseNumbers', 'parseBooleans', 'parseNulls', 'parseAll', 'parseWithFunction', 'checkboxUncheckedValue', 'useIntKeysAsArrayIndex'];
        for (opt in opts) {
          if (validOpts.indexOf(opt) === -1) {
            throw new  Error("serializeJSON ERROR: invalid option '" + opt + "'. Please use one of " + validOpts.join(','));
          }
        }
      },

      // Convert the string to a number, boolean or null, depending on the enable option and the string format.
      parseValue: function(str, type, opts) {
        var f;
        f = $.serializeJSON;
        if (type == 'string') return str; // force string
        if (type == 'number'  || (opts.parseNumbers  && f.isNumeric(str))) return Number(str); // number
        if (type == 'boolean' || (opts.parseBooleans && (str === "true" || str === "false"))) return (["false", "null", "undefined", "", "0"].indexOf(str) === -1); // boolean
        if (type == 'null'    || (opts.parseNulls    && str == "null")) return ["false", "null", "undefined", "", "0"].indexOf(str) !== -1 ? null : str; // null
        if (type == 'array' || type == 'object') return JSON.parse(str); // array or objects require JSON
        if (type == 'auto') return f.parseValue(str, null, {parseNumbers: true, parseBooleans: true, parseNulls: true}); // try again with something like "parseAll"
        return str; // otherwise, keep same string
      },

      isObject:          function(obj) { return obj === Object(obj); }, // is this variable an object?
      isUndefined:       function(obj) { return obj === void 0; }, // safe check for undefined values
      isValidArrayIndex: function(val) { return /^[0-9]+$/.test(String(val)); }, // 1,2,3,4 ... are valid array indexes
      isNumeric:         function(obj) { return obj - parseFloat(obj) >= 0; }, // taken from jQuery.isNumeric implementation. Not using jQuery.isNumeric to support old jQuery and Zepto versions

      // Split the input name in programatically readable keys.
      // The last element is always the type (default "_").
      // Examples:
      // "foo"              => ['foo', '_']
      // "foo:string"       => ['foo', 'string']
      // "foo:boolean"      => ['foo', 'boolean']
      // "[foo]"            => ['foo', '_']
      // "foo[inn][bar]"    => ['foo', 'inn', 'bar', '_']
      // "foo[inn[bar]]"    => ['foo', 'inn', 'bar', '_']
      // "foo[inn][arr][0]" => ['foo', 'inn', 'arr', '0', '_']
      // "arr[][val]"       => ['arr', '', 'val', '_']
      // "arr[][val]:null"  => ['arr', '', 'val', 'null']
      splitInputNameIntoKeysArray: function (name) {
        var keys, nameWithoutType, type, _ref, f;
        f = $.serializeJSON;
        _ref = f.extractTypeFromInputName(name), nameWithoutType = _ref[0], type = _ref[1];
        keys = nameWithoutType.split('['); // split string into array
        keys = $.map(keys, function (key) { return key.replace(/]/g, ''); }); // remove closing brackets
        if (keys[0] === '') { keys.shift(); } // ensure no opening bracket ("[foo][inn]" should be same as "foo[inn]")
        keys.push(type); // add type at the end
        return keys;
      },

      // Returns [name-without-type, type] from name.
      // "foo"              =>  ["foo", "_"]
      // "foo:boolean"      =>  ["foo", "boolean"]
      // "foo[bar]:null"    =>  ["foo[bar]", "null"]
      extractTypeFromInputName: function(name) {
        var match;
        $.serializeJSON;
        if (match = name.match(/(.*):([^:]+)$/)){
          var validTypes = ['string', 'number', 'boolean', 'null', 'array', 'object', 'skip', 'auto']; // validate type
          if (validTypes.indexOf(match[2]) !== -1) {
            return [match[1], match[2]];
          } else {
            throw new Error("serializeJSON ERROR: Invalid type " + match[2] + " found in input name '" + name + "', please use one of " + validTypes.join(', '))
          }
        } else {
          return [name, '_']; // no defined type, then use parse options
        }
      },

      // Set a value in an object or array, using multiple keys to set in a nested object or array:
      //
      // deepSet(obj, ['foo'], v)               // obj['foo'] = v
      // deepSet(obj, ['foo', 'inn'], v)        // obj['foo']['inn'] = v // Create the inner obj['foo'] object, if needed
      // deepSet(obj, ['foo', 'inn', '123'], v) // obj['foo']['arr']['123'] = v //
      //
      // deepSet(obj, ['0'], v)                                   // obj['0'] = v
      // deepSet(arr, ['0'], v, {useIntKeysAsArrayIndex: true})   // arr[0] = v
      // deepSet(arr, [''], v)                                    // arr.push(v)
      // deepSet(obj, ['arr', ''], v)                             // obj['arr'].push(v)
      //
      // arr = [];
      // deepSet(arr, ['', v]          // arr => [v]
      // deepSet(arr, ['', 'foo'], v)  // arr => [v, {foo: v}]
      // deepSet(arr, ['', 'bar'], v)  // arr => [v, {foo: v, bar: v}]
      // deepSet(arr, ['', 'bar'], v)  // arr => [v, {foo: v, bar: v}, {bar: v}]
      //
      deepSet: function (o, keys, value, opts) {
        var key, nextKey, tail, lastIdx, lastVal, f;
        if (opts == null) opts = {};
        f = $.serializeJSON;
        if (f.isUndefined(o)) { throw new Error("ArgumentError: param 'o' expected to be an object or array, found undefined"); }
        if (!keys || keys.length === 0) { throw new Error("ArgumentError: param 'keys' expected to be an array with least one element"); }

        key = keys[0];

        // Only one key, then it's not a deepSet, just assign the value.
        if (keys.length === 1) {
          if (key === '') {
            o.push(value); // '' is used to push values into the array (assume o is an array)
          } else {
            o[key] = value; // other keys can be used as object keys or array indexes
          }

        // With more keys is a deepSet. Apply recursively.
        } else {

          nextKey = keys[1];

          // '' is used to push values into the array,
          // with nextKey, set the value into the same object, in object[nextKey].
          // Covers the case of ['', 'foo'] and ['', 'var'] to push the object {foo, var}, and the case of nested arrays.
          if (key === '') {
            lastIdx = o.length - 1; // asume o is array
            lastVal = o[lastIdx];
            if (f.isObject(lastVal) && (f.isUndefined(lastVal[nextKey]) || keys.length > 2)) { // if nextKey is not present in the last object element, or there are more keys to deep set
              key = lastIdx; // then set the new value in the same object element
            } else {
              key = lastIdx + 1; // otherwise, point to set the next index in the array
            }
          }

          // o[key] defaults to object or array, depending if nextKey is an array index (int or '') or an object key (string)
          if (f.isUndefined(o[key])) {
            if (nextKey === '') { // '' is used to push values into the array.
              o[key] = [];
            } else if (opts.useIntKeysAsArrayIndex && f.isValidArrayIndex(nextKey)) { // if 1, 2, 3 ... then use an array, where nextKey is the index
              o[key] = [];
            } else { // for anything else, use an object, where nextKey is going to be the attribute name
              o[key] = {};
            }
          }

          // Recursively set the inner object
          tail = keys.slice(1);
          f.deepSet(o[key], tail, value, opts);
        }
      },

      // Fill the formAsArray object with values for the unchecked checkbox inputs,
      // using the same format as the jquery.serializeArray function.
      // The value of the unchecked values is determined from the opts.checkboxUncheckedValue
      // and/or the data-unchecked-value attribute of the inputs.
      readCheckboxUncheckedValues: function (formAsArray, $form, opts) {
        var selector, $uncheckedCheckboxes, $el, dataUncheckedValue, f;
        if (opts == null) opts = {};
        f = $.serializeJSON;

        selector = 'input[type=checkbox][name]:not(:checked,[disabled])';
        $uncheckedCheckboxes = $form.find(selector).add($form.filter(selector));
        $uncheckedCheckboxes.each(function (i, el) {
          $el = $(el);
          dataUncheckedValue = $el.attr('data-unchecked-value');
          if(dataUncheckedValue) { // data-unchecked-value has precedence over option opts.checkboxUncheckedValue
            formAsArray.push({name: el.name, value: dataUncheckedValue});
          } else {
            if (!f.isUndefined(opts.checkboxUncheckedValue)) {
              formAsArray.push({name: el.name, value: opts.checkboxUncheckedValue});
            }
          }
        });
      }

    };

  }(window.jQuery || window.Zepto || window.$));

  /*
   * Leaflet-IIIF 3.0.0
   * IIIF Viewer for Leaflet
   * by Jack Reed, @mejackreed
   */

  L.TileLayer.Iiif = L.TileLayer.extend({
    options: {
      continuousWorld: true,
      tileSize: 256,
      updateWhenIdle: true,
      tileFormat: 'jpg',
      fitBounds: true,
      setMaxBounds: false
    },

    initialize: function(url, options) {
      options = typeof options !== 'undefined' ? options : {};

      if (options.maxZoom) {
        this._customMaxZoom = true;
      }

      // Check for explicit tileSize set
      if (options.tileSize) {
        this._explicitTileSize = true;
      }

      // Check for an explicit quality
      if (options.quality) {
        this._explicitQuality = true;
      }

      options = L.setOptions(this, options);
      this._infoPromise = null;
      this._infoUrl = url;
      this._baseUrl = this._templateUrl();
      this._getInfo();
    },
    getTileUrl: function(coords) {
      var _this = this,
        x = coords.x,
        y = (coords.y),
        zoom = _this._getZoomForUrl(),
        scale = Math.pow(2, _this.maxNativeZoom - zoom),
        tileBaseSize = _this.options.tileSize * scale,
        minx = (x * tileBaseSize),
        miny = (y * tileBaseSize),
        maxx = Math.min(minx + tileBaseSize, _this.x),
        maxy = Math.min(miny + tileBaseSize, _this.y);

      var xDiff = (maxx - minx);
      var yDiff = (maxy - miny);

      // Canonical URI Syntax for v2
      var size = Math.ceil(xDiff / scale) + ',';
      if (_this.type === 'ImageService3') {
        // Cannonical URI Syntax for v3
        size = size + Math.ceil(yDiff / scale);
      }

      return L.Util.template(this._baseUrl, L.extend({
        format: _this.options.tileFormat,
        quality: _this.quality,
        region: [minx, miny, xDiff, yDiff].join(','),
        rotation: 0,
        size: size
      }, this.options));
    },
    onAdd: function(map) {
      var _this = this;

      // Wait for info.json fetch and parse to complete
      Promise.all([_this._infoPromise]).then(function() {
        // Store unmutated imageSizes
        _this._imageSizesOriginal = _this._imageSizes.slice(0);

        // Set maxZoom for map
        map._layersMaxZoom = _this.maxZoom;

        // Call add TileLayer
        L.TileLayer.prototype.onAdd.call(_this, map);

        // Set minZoom and minNativeZoom based on how the imageSizes match up
        var smallestImage = _this._imageSizes[0];
        var mapSize = _this._map.getSize();
        var newMinZoom = 0;
        // Loop back through 5 times to see if a better fit can be found.
        for (var i = 1; i <= 5; i++) {
          if (smallestImage.x > mapSize.x || smallestImage.y > mapSize.y) {
            smallestImage = smallestImage.divideBy(2);
            _this._imageSizes.unshift(smallestImage);
            newMinZoom = -i;
          } else {
            break;
          }
        }
        _this.options.minZoom = newMinZoom;
        _this.options.minNativeZoom = newMinZoom;
        _this._prev_map_layersMinZoom = _this._map._layersMinZoom;
        _this._map._layersMinZoom = newMinZoom;

        if (_this.options.fitBounds) {
          _this._fitBounds();
        }

        if(_this.options.setMaxBounds) {
          _this._setMaxBounds();
        }

        // Reset tile sizes to handle non 256x256 IIIF tiles
        _this.on('tileload', function(tile, url) {

          var height = tile.tile.naturalHeight,
            width = tile.tile.naturalWidth;

          // No need to resize if tile is 256 x 256
          if (height === 256 && width === 256) return;

          tile.tile.style.width = width + 'px';
          tile.tile.style.height = height + 'px';

        });
      })
      .catch(function(err){
          console.error(err);
      });
    },
    onRemove: function(map) {
      var _this = this;

      map._layersMinZoom = _this._prev_map_layersMinZoom;
      _this._imageSizes = _this._imageSizesOriginal;

      // Remove maxBounds set for this image
      if(_this.options.setMaxBounds) {
        map.setMaxBounds(null);
      }

      // Call remove TileLayer
      L.TileLayer.prototype.onRemove.call(_this, map);

    },
    _fitBounds: function() {
      var _this = this;

      // Find best zoom level and center map
      var initialZoom = _this._getInitialZoom(_this._map.getSize());
      var offset = _this._imageSizes.length - 1 - _this.options.maxNativeZoom;
      var imageSize = _this._imageSizes[initialZoom + offset];
      var sw = _this._map.options.crs.pointToLatLng(L.point(0, imageSize.y), initialZoom);
      var ne = _this._map.options.crs.pointToLatLng(L.point(imageSize.x, 0), initialZoom);
      var bounds = L.latLngBounds(sw, ne);

      _this._map.fitBounds(bounds, true);
    },
    _setMaxBounds: function() {
      var _this = this;

      // Find best zoom level, center map, and constrain viewer
      var initialZoom = _this._getInitialZoom(_this._map.getSize());
      var imageSize = _this._imageSizes[initialZoom];
      var sw = _this._map.options.crs.pointToLatLng(L.point(0, imageSize.y), initialZoom);
      var ne = _this._map.options.crs.pointToLatLng(L.point(imageSize.x, 0), initialZoom);
      var bounds = L.latLngBounds(sw, ne);

      _this._map.setMaxBounds(bounds, true);
    },
    _getInfo: function() {
      var _this = this;

      _this._infoPromise = fetch(_this._infoUrl)
        .then(function(response) {
          return response.json();
        })
        .catch(function(err){
            console.error(err);
        })
        .then(function(data) {
          _this.y = data.height;
          _this.x = data.width;

          var tierSizes = [],
            imageSizes = [],
            scale,
            width_,
            height_,
            tilesX_,
            tilesY_;

          // Set quality based off of IIIF version
          if (data.profile instanceof Array) {
            _this.profile = data.profile[0];
          }else {
            _this.profile = data.profile;
          }
          _this.type = data.type;

          _this._setQuality();

          // Unless an explicit tileSize is set, use a preferred tileSize
          if (!_this._explicitTileSize) {
            // Set the default first
            _this.options.tileSize = 256;
            if (data.tiles) {
              // Image API 2.0 Case
              _this.options.tileSize = data.tiles[0].width;
            } else if (data.tile_width){
              // Image API 1.1 Case
              _this.options.tileSize = data.tile_width;
            }
          }

          function ceilLog2(x) {
            return Math.ceil(Math.log(x) / Math.LN2);
          }
          // Calculates maximum native zoom for the layer
          _this.maxNativeZoom = Math.max(
            ceilLog2(_this.x / _this.options.tileSize),
            ceilLog2(_this.y / _this.options.tileSize),
            0
          );
          _this.options.maxNativeZoom = _this.maxNativeZoom;

          // Enable zooming further than native if maxZoom option supplied
          if (_this._customMaxZoom && _this.options.maxZoom > _this.maxNativeZoom) {
            _this.maxZoom = _this.options.maxZoom;
          }
          else {
            _this.maxZoom = _this.maxNativeZoom;
          }

          for (var i = 0; i <= _this.maxZoom; i++) {
            scale = Math.pow(2, _this.maxNativeZoom - i);
            width_ = Math.ceil(_this.x / scale);
            height_ = Math.ceil(_this.y / scale);
            tilesX_ = Math.ceil(width_ / _this.options.tileSize);
            tilesY_ = Math.ceil(height_ / _this.options.tileSize);
            tierSizes.push([tilesX_, tilesY_]);
            imageSizes.push(L.point(width_,height_));
          }

          _this._tierSizes = tierSizes;
          _this._imageSizes = imageSizes;
        })
        .catch(function(err){
            console.error(err);
        });

    },

    _setQuality: function() {
      var _this = this;
      var profileToCheck = _this.profile;

      if (_this._explicitQuality) {
        return;
      }

      // If profile is an object
      if (typeof(profileToCheck) === 'object') {
        profileToCheck = profileToCheck['@id'];
      }

      // Set the quality based on the IIIF compliance level
      switch (true) {
        case /^http:\/\/library.stanford.edu\/iiif\/image-api\/1.1\/compliance.html.*$/.test(profileToCheck):
          _this.options.quality = 'native';
          break;
        // Assume later profiles and set to default
        default:
          _this.options.quality = 'default';
          break;
      }
    },

    _infoToBaseUrl: function() {
      return this._infoUrl.replace('info.json', '');
    },
    _templateUrl: function() {
      return this._infoToBaseUrl() + '{region}/{size}/{rotation}/{quality}.{format}';
    },
    _isValidTile: function(coords) {
      var _this = this;
      var zoom = _this._getZoomForUrl();
      var sizes = _this._tierSizes[zoom];
      var x = coords.x;
      var y = coords.y;
      if (zoom < 0 && x >= 0 && y >= 0) {
        return true;
      }

      if (!sizes) return false;
      if (x < 0 || sizes[0] <= x || y < 0 || sizes[1] <= y) {
        return false;
      }else {
        return true;
      }
    },
    _tileShouldBeLoaded: function(coords) {
      return this._isValidTile(coords);
    },
    _getInitialZoom: function (mapSize) {
      var _this = this;
      var tolerance = 0.8;
      var imageSize;
      // Calculate an offset between the zoom levels and the array accessors
      var offset = _this._imageSizes.length - 1 - _this.options.maxNativeZoom;
      for (var i = _this._imageSizes.length - 1; i >= 0; i--) {
        imageSize = _this._imageSizes[i];
        if (imageSize.x * tolerance < mapSize.x && imageSize.y * tolerance < mapSize.y) {
          return i - offset;
        }
      }
      // return a default zoom
      return 2;
    }
  });

  L.tileLayer.iiif = function(url, options) {
    return new L.TileLayer.Iiif(url, options);
  };

  (function (factory, window) {
      /*globals define, module, require*/

      // define an AMD module that relies on 'leaflet'
      if (typeof define === 'function' && define.amd) {
          define(['leaflet'], factory);


      // define a Common JS module that relies on 'leaflet'
      } else if (typeof exports === 'object') {
          module.exports = factory(require('leaflet'));
      }

      // attach your plugin to the global 'L' variable
      if(typeof window !== 'undefined' && window.L){
          factory(window.L);
      }

  }(function (L) {
      // 🍂miniclass CancelableEvent (Event objects)
      // 🍂method cancel()
      // Cancel any subsequent action.

      // 🍂miniclass VertexEvent (Event objects)
      // 🍂property vertex: VertexMarker
      // The vertex that fires the event.

      // 🍂miniclass ShapeEvent (Event objects)
      // 🍂property shape: Array
      // The shape (LatLngs array) subject of the action.

      // 🍂miniclass CancelableVertexEvent (Event objects)
      // 🍂inherits VertexEvent
      // 🍂inherits CancelableEvent

      // 🍂miniclass CancelableShapeEvent (Event objects)
      // 🍂inherits ShapeEvent
      // 🍂inherits CancelableEvent

      // 🍂miniclass LayerEvent (Event objects)
      // 🍂property layer: object
      // The Layer (Marker, Polyline…) subject of the action.

      // 🍂namespace Editable; 🍂class Editable; 🍂aka L.Editable
      // Main edition handler. By default, it is attached to the map
      // as `map.editTools` property.
      // Leaflet.Editable is made to be fully extendable. You have three ways to customize
      // the behaviour: using options, listening to events, or extending.
      L.Editable = L.Evented.extend({

          statics: {
              FORWARD: 1,
              BACKWARD: -1
          },

          options: {

              // You can pass them when creating a map using the `editOptions` key.
              // 🍂option zIndex: int = 1000
              // The default zIndex of the editing tools.
              zIndex: 1000,

              // 🍂option polygonClass: class = L.Polygon
              // Class to be used when creating a new Polygon.
              polygonClass: L.Polygon,

              // 🍂option polylineClass: class = L.Polyline
              // Class to be used when creating a new Polyline.
              polylineClass: L.Polyline,

              // 🍂option markerClass: class = L.Marker
              // Class to be used when creating a new Marker.
              markerClass: L.Marker,

              // 🍂option rectangleClass: class = L.Rectangle
              // Class to be used when creating a new Rectangle.
              rectangleClass: L.Rectangle,

              // 🍂option circleClass: class = L.Circle
              // Class to be used when creating a new Circle.
              circleClass: L.Circle,

              // 🍂option drawingCSSClass: string = 'leaflet-editable-drawing'
              // CSS class to be added to the map container while drawing.
              drawingCSSClass: 'leaflet-editable-drawing',

              // 🍂option drawingCursor: const = 'crosshair'
              // Cursor mode set to the map while drawing.
              drawingCursor: 'crosshair',

              // 🍂option editLayer: Layer = new L.LayerGroup()
              // Layer used to store edit tools (vertex, line guide…).
              editLayer: undefined,

              // 🍂option featuresLayer: Layer = new L.LayerGroup()
              // Default layer used to store drawn features (Marker, Polyline…).
              featuresLayer: undefined,

              // 🍂option polylineEditorClass: class = PolylineEditor
              // Class to be used as Polyline editor.
              polylineEditorClass: undefined,

              // 🍂option polygonEditorClass: class = PolygonEditor
              // Class to be used as Polygon editor.
              polygonEditorClass: undefined,

              // 🍂option markerEditorClass: class = MarkerEditor
              // Class to be used as Marker editor.
              markerEditorClass: undefined,

              // 🍂option rectangleEditorClass: class = RectangleEditor
              // Class to be used as Rectangle editor.
              rectangleEditorClass: undefined,

              // 🍂option circleEditorClass: class = CircleEditor
              // Class to be used as Circle editor.
              circleEditorClass: undefined,

              // 🍂option lineGuideOptions: hash = {}
              // Options to be passed to the line guides.
              lineGuideOptions: {},

              // 🍂option skipMiddleMarkers: boolean = false
              // Set this to true if you don't want middle markers.
              skipMiddleMarkers: false

          },

          initialize: function (map, options) {
              L.setOptions(this, options);
              this._lastZIndex = this.options.zIndex;
              this.map = map;
              this.editLayer = this.createEditLayer();
              this.featuresLayer = this.createFeaturesLayer();
              this.forwardLineGuide = this.createLineGuide();
              this.backwardLineGuide = this.createLineGuide();
          },

          fireAndForward: function (type, e) {
              e = e || {};
              e.editTools = this;
              this.fire(type, e);
              this.map.fire(type, e);
          },

          createLineGuide: function () {
              var options = L.extend({dashArray: '5,10', weight: 1, interactive: false}, this.options.lineGuideOptions);
              return L.polyline([], options);
          },

          createVertexIcon: function (options) {
              return L.Browser.touch ? new L.Editable.TouchVertexIcon(options) : new L.Editable.VertexIcon(options);
          },

          createEditLayer: function () {
              return this.options.editLayer || new L.LayerGroup().addTo(this.map);
          },

          createFeaturesLayer: function () {
              return this.options.featuresLayer || new L.LayerGroup().addTo(this.map);
          },

          moveForwardLineGuide: function (latlng) {
              if (this.forwardLineGuide._latlngs.length) {
                  this.forwardLineGuide._latlngs[1] = latlng;
                  this.forwardLineGuide._bounds.extend(latlng);
                  this.forwardLineGuide.redraw();
              }
          },

          moveBackwardLineGuide: function (latlng) {
              if (this.backwardLineGuide._latlngs.length) {
                  this.backwardLineGuide._latlngs[1] = latlng;
                  this.backwardLineGuide._bounds.extend(latlng);
                  this.backwardLineGuide.redraw();
              }
          },

          anchorForwardLineGuide: function (latlng) {
              this.forwardLineGuide._latlngs[0] = latlng;
              this.forwardLineGuide._bounds.extend(latlng);
              this.forwardLineGuide.redraw();
          },

          anchorBackwardLineGuide: function (latlng) {
              this.backwardLineGuide._latlngs[0] = latlng;
              this.backwardLineGuide._bounds.extend(latlng);
              this.backwardLineGuide.redraw();
          },

          attachForwardLineGuide: function () {
              this.editLayer.addLayer(this.forwardLineGuide);
          },

          attachBackwardLineGuide: function () {
              this.editLayer.addLayer(this.backwardLineGuide);
          },

          detachForwardLineGuide: function () {
              this.forwardLineGuide.setLatLngs([]);
              this.editLayer.removeLayer(this.forwardLineGuide);
          },

          detachBackwardLineGuide: function () {
              this.backwardLineGuide.setLatLngs([]);
              this.editLayer.removeLayer(this.backwardLineGuide);
          },

          blockEvents: function () {
              // Hack: force map not to listen to other layers events while drawing.
              if (!this._oldTargets) {
                  this._oldTargets = this.map._targets;
                  this.map._targets = {};
              }
          },

          unblockEvents: function () {
              if (this._oldTargets) {
                  // Reset, but keep targets created while drawing.
                  this.map._targets = L.extend(this.map._targets, this._oldTargets);
                  delete this._oldTargets;
              }
          },

          registerForDrawing: function (editor) {
              if (this._drawingEditor) this.unregisterForDrawing(this._drawingEditor);
              this.blockEvents();
              editor.reset();  // Make sure editor tools still receive events.
              this._drawingEditor = editor;
              this.map.on('mousemove touchmove', editor.onDrawingMouseMove, editor);
              this.map.on('mousedown', this.onMousedown, this);
              this.map.on('mouseup', this.onMouseup, this);
              L.DomUtil.addClass(this.map._container, this.options.drawingCSSClass);
              this.defaultMapCursor = this.map._container.style.cursor;
              this.map._container.style.cursor = this.options.drawingCursor;
          },

          unregisterForDrawing: function (editor) {
              this.unblockEvents();
              L.DomUtil.removeClass(this.map._container, this.options.drawingCSSClass);
              this.map._container.style.cursor = this.defaultMapCursor;
              editor = editor || this._drawingEditor;
              if (!editor) return;
              this.map.off('mousemove touchmove', editor.onDrawingMouseMove, editor);
              this.map.off('mousedown', this.onMousedown, this);
              this.map.off('mouseup', this.onMouseup, this);
              if (editor !== this._drawingEditor) return;
              delete this._drawingEditor;
              if (editor._drawing) editor.cancelDrawing();
          },

          onMousedown: function (e) {
              this._mouseDown = e;
              this._drawingEditor.onDrawingMouseDown(e);
          },

          onMouseup: function (e) {
              if (this._mouseDown) {
                  var editor = this._drawingEditor,
                      mouseDown = this._mouseDown;
                  this._mouseDown = null;
                  editor.onDrawingMouseUp(e);
                  if (this._drawingEditor !== editor) return;  // onDrawingMouseUp may call unregisterFromDrawing.
                  var origin = L.point(mouseDown.originalEvent.clientX, mouseDown.originalEvent.clientY);
                  var distance = L.point(e.originalEvent.clientX, e.originalEvent.clientY).distanceTo(origin);
                  if (Math.abs(distance) < 9 * (window.devicePixelRatio || 1)) this._drawingEditor.onDrawingClick(e);
              }
          },

          // 🍂section Public methods
          // You will generally access them by the `map.editTools`
          // instance:
          //
          // `map.editTools.startPolyline();`

          // 🍂method drawing(): boolean
          // Return true if any drawing action is ongoing.
          drawing: function () {
              return this._drawingEditor && this._drawingEditor.drawing();
          },

          // 🍂method stopDrawing()
          // When you need to stop any ongoing drawing, without needing to know which editor is active.
          stopDrawing: function () {
              this.unregisterForDrawing();
          },

          // 🍂method commitDrawing()
          // When you need to commit any ongoing drawing, without needing to know which editor is active.
          commitDrawing: function (e) {
              if (!this._drawingEditor) return;
              this._drawingEditor.commitDrawing(e);
          },

          connectCreatedToMap: function (layer) {
              return this.featuresLayer.addLayer(layer);
          },

          // 🍂method startPolyline(latlng: L.LatLng, options: hash): L.Polyline
          // Start drawing a Polyline. If `latlng` is given, a first point will be added. In any case, continuing on user click.
          // If `options` is given, it will be passed to the Polyline class constructor.
          startPolyline: function (latlng, options) {
              var line = this.createPolyline([], options);
              line.enableEdit(this.map).newShape(latlng);
              return line;
          },

          // 🍂method startPolygon(latlng: L.LatLng, options: hash): L.Polygon
          // Start drawing a Polygon. If `latlng` is given, a first point will be added. In any case, continuing on user click.
          // If `options` is given, it will be passed to the Polygon class constructor.
          startPolygon: function (latlng, options) {
              var polygon = this.createPolygon([], options);
              polygon.enableEdit(this.map).newShape(latlng);
              return polygon;
          },

          // 🍂method startMarker(latlng: L.LatLng, options: hash): L.Marker
          // Start adding a Marker. If `latlng` is given, the Marker will be shown first at this point.
          // In any case, it will follow the user mouse, and will have a final `latlng` on next click (or touch).
          // If `options` is given, it will be passed to the Marker class constructor.
          startMarker: function (latlng, options) {
              latlng = latlng || this.map.getCenter().clone();
              var marker = this.createMarker(latlng, options);
              marker.enableEdit(this.map).startDrawing();
              return marker;
          },

          // 🍂method startRectangle(latlng: L.LatLng, options: hash): L.Rectangle
          // Start drawing a Rectangle. If `latlng` is given, the Rectangle anchor will be added. In any case, continuing on user drag.
          // If `options` is given, it will be passed to the Rectangle class constructor.
          startRectangle: function(latlng, options) {
              var corner = latlng || L.latLng([0, 0]);
              var bounds = new L.LatLngBounds(corner, corner);
              var rectangle = this.createRectangle(bounds, options);
              rectangle.enableEdit(this.map).startDrawing();
              return rectangle;
          },

          // 🍂method startCircle(latlng: L.LatLng, options: hash): L.Circle
          // Start drawing a Circle. If `latlng` is given, the Circle anchor will be added. In any case, continuing on user drag.
          // If `options` is given, it will be passed to the Circle class constructor.
          startCircle: function (latlng, options) {
              latlng = latlng || this.map.getCenter().clone();
              var circle = this.createCircle(latlng, options);
              circle.enableEdit(this.map).startDrawing();
              return circle;
          },

          startHole: function (editor, latlng) {
              editor.newHole(latlng);
          },

          createLayer: function (klass, latlngs, options) {
              options = L.Util.extend({editOptions: {editTools: this}}, options);
              var layer = new klass(latlngs, options);
              // 🍂namespace Editable
              // 🍂event editable:created: LayerEvent
              // Fired when a new feature (Marker, Polyline…) is created.
              this.fireAndForward('editable:created', {layer: layer});
              return layer;
          },

          createPolyline: function (latlngs, options) {
              return this.createLayer(options && options.polylineClass || this.options.polylineClass, latlngs, options);
          },

          createPolygon: function (latlngs, options) {
              return this.createLayer(options && options.polygonClass || this.options.polygonClass, latlngs, options);
          },

          createMarker: function (latlng, options) {
              return this.createLayer(options && options.markerClass || this.options.markerClass, latlng, options);
          },

          createRectangle: function (bounds, options) {
              return this.createLayer(options && options.rectangleClass || this.options.rectangleClass, bounds, options);
          },

          createCircle: function (latlng, options) {
              return this.createLayer(options && options.circleClass || this.options.circleClass, latlng, options);
          }

      });

      L.extend(L.Editable, {

          makeCancellable: function (e) {
              e.cancel = function () {
                  e._cancelled = true;
              };
          }

      });

      // 🍂namespace Map; 🍂class Map
      // Leaflet.Editable add options and events to the `L.Map` object.
      // See `Editable` events for the list of events fired on the Map.
      // 🍂example
      //
      // ```js
      // var map = L.map('map', {
      //  editable: true,
      //  editOptions: {
      //    …
      // }
      // });
      // ```
      // 🍂section Editable Map Options
      L.Map.mergeOptions({

          // 🍂namespace Map
          // 🍂section Map Options
          // 🍂option editToolsClass: class = L.Editable
          // Class to be used as vertex, for path editing.
          editToolsClass: L.Editable,

          // 🍂option editable: boolean = false
          // Whether to create a L.Editable instance at map init.
          editable: false,

          // 🍂option editOptions: hash = {}
          // Options to pass to L.Editable when instanciating.
          editOptions: {}

      });

      L.Map.addInitHook(function () {

          this.whenReady(function () {
              if (this.options.editable) {
                  this.editTools = new this.options.editToolsClass(this, this.options.editOptions);
              }
          });

      });

      L.Editable.VertexIcon = L.DivIcon.extend({

          options: {
              iconSize: new L.Point(8, 8)
          }

      });

      L.Editable.TouchVertexIcon = L.Editable.VertexIcon.extend({

          options: {
              iconSize: new L.Point(20, 20)
          }

      });


      // 🍂namespace Editable; 🍂class VertexMarker; Handler for dragging path vertices.
      L.Editable.VertexMarker = L.Marker.extend({

          options: {
              draggable: true,
              className: 'leaflet-div-icon leaflet-vertex-icon'
          },


          // 🍂section Public methods
          // The marker used to handle path vertex. You will usually interact with a `VertexMarker`
          // instance when listening for events like `editable:vertex:ctrlclick`.

          initialize: function (latlng, latlngs, editor, options) {
              // We don't use this._latlng, because on drag Leaflet replace it while
              // we want to keep reference.
              this.latlng = latlng;
              this.latlngs = latlngs;
              this.editor = editor;
              L.Marker.prototype.initialize.call(this, latlng, options);
              this.options.icon = this.editor.tools.createVertexIcon({className: this.options.className});
              this.latlng.__vertex = this;
              this.editor.editLayer.addLayer(this);
              this.setZIndexOffset(editor.tools._lastZIndex + 1);
          },

          onAdd: function (map) {
              L.Marker.prototype.onAdd.call(this, map);
              this.on('drag', this.onDrag);
              this.on('dragstart', this.onDragStart);
              this.on('dragend', this.onDragEnd);
              this.on('mouseup', this.onMouseup);
              this.on('click', this.onClick);
              this.on('contextmenu', this.onContextMenu);
              this.on('mousedown touchstart', this.onMouseDown);
              this.addMiddleMarkers();
          },

          onRemove: function (map) {
              if (this.middleMarker) this.middleMarker.delete();
              delete this.latlng.__vertex;
              this.off('drag', this.onDrag);
              this.off('dragstart', this.onDragStart);
              this.off('dragend', this.onDragEnd);
              this.off('mouseup', this.onMouseup);
              this.off('click', this.onClick);
              this.off('contextmenu', this.onContextMenu);
              this.off('mousedown touchstart', this.onMouseDown);
              L.Marker.prototype.onRemove.call(this, map);
          },

          onDrag: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerDrag(e);
              var iconPos = L.DomUtil.getPosition(this._icon),
                  latlng = this._map.layerPointToLatLng(iconPos);
              this.latlng.update(latlng);
              this._latlng = this.latlng;  // Push back to Leaflet our reference.
              this.editor.refresh();
              if (this.middleMarker) this.middleMarker.updateLatLng();
              var next = this.getNext();
              if (next && next.middleMarker) next.middleMarker.updateLatLng();
          },

          onDragStart: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerDragStart(e);
          },

          onDragEnd: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerDragEnd(e);
          },

          onClick: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerClick(e);
          },

          onMouseup: function (e) {
              L.DomEvent.stop(e);
              e.vertex = this;
              this.editor.map.fire('mouseup', e);
          },

          onContextMenu: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerContextMenu(e);
          },

          onMouseDown: function (e) {
              e.vertex = this;
              this.editor.onVertexMarkerMouseDown(e);
          },

          // 🍂method delete()
          // Delete a vertex and the related LatLng.
          delete: function () {
              var next = this.getNext();  // Compute before changing latlng
              this.latlngs.splice(this.getIndex(), 1);
              this.editor.editLayer.removeLayer(this);
              this.editor.onVertexDeleted({latlng: this.latlng, vertex: this});
              if (!this.latlngs.length) this.editor.deleteShape(this.latlngs);
              if (next) next.resetMiddleMarker();
              this.editor.refresh();
          },

          // 🍂method getIndex(): int
          // Get the index of the current vertex among others of the same LatLngs group.
          getIndex: function () {
              return this.latlngs.indexOf(this.latlng);
          },

          // 🍂method getLastIndex(): int
          // Get last vertex index of the LatLngs group of the current vertex.
          getLastIndex: function () {
              return this.latlngs.length - 1;
          },

          // 🍂method getPrevious(): VertexMarker
          // Get the previous VertexMarker in the same LatLngs group.
          getPrevious: function () {
              if (this.latlngs.length < 2) return;
              var index = this.getIndex(),
                  previousIndex = index - 1;
              if (index === 0 && this.editor.CLOSED) previousIndex = this.getLastIndex();
              var previous = this.latlngs[previousIndex];
              if (previous) return previous.__vertex;
          },

          // 🍂method getNext(): VertexMarker
          // Get the next VertexMarker in the same LatLngs group.
          getNext: function () {
              if (this.latlngs.length < 2) return;
              var index = this.getIndex(),
                  nextIndex = index + 1;
              if (index === this.getLastIndex() && this.editor.CLOSED) nextIndex = 0;
              var next = this.latlngs[nextIndex];
              if (next) return next.__vertex;
          },

          addMiddleMarker: function (previous) {
              if (!this.editor.hasMiddleMarkers()) return;
              previous = previous || this.getPrevious();
              if (previous && !this.middleMarker) this.middleMarker = this.editor.addMiddleMarker(previous, this, this.latlngs, this.editor);
          },

          addMiddleMarkers: function () {
              if (!this.editor.hasMiddleMarkers()) return;
              var previous = this.getPrevious();
              if (previous) this.addMiddleMarker(previous);
              var next = this.getNext();
              if (next) next.resetMiddleMarker();
          },

          resetMiddleMarker: function () {
              if (this.middleMarker) this.middleMarker.delete();
              this.addMiddleMarker();
          },

          // 🍂method split()
          // Split the vertex LatLngs group at its index, if possible.
          split: function () {
              if (!this.editor.splitShape) return;  // Only for PolylineEditor
              this.editor.splitShape(this.latlngs, this.getIndex());
          },

          // 🍂method continue()
          // Continue the vertex LatLngs from this vertex. Only active for first and last vertices of a Polyline.
          continue: function () {
              if (!this.editor.continueBackward) return;  // Only for PolylineEditor
              var index = this.getIndex();
              if (index === 0) this.editor.continueBackward(this.latlngs);
              else if (index === this.getLastIndex()) this.editor.continueForward(this.latlngs);
          }

      });

      L.Editable.mergeOptions({

          // 🍂namespace Editable
          // 🍂option vertexMarkerClass: class = VertexMarker
          // Class to be used as vertex, for path editing.
          vertexMarkerClass: L.Editable.VertexMarker

      });

      L.Editable.MiddleMarker = L.Marker.extend({

          options: {
              opacity: 0.5,
              className: 'leaflet-div-icon leaflet-middle-icon',
              draggable: true
          },

          initialize: function (left, right, latlngs, editor, options) {
              this.left = left;
              this.right = right;
              this.editor = editor;
              this.latlngs = latlngs;
              L.Marker.prototype.initialize.call(this, this.computeLatLng(), options);
              this._opacity = this.options.opacity;
              this.options.icon = this.editor.tools.createVertexIcon({className: this.options.className});
              this.editor.editLayer.addLayer(this);
              this.setVisibility();
          },

          setVisibility: function () {
              var leftPoint = this._map.latLngToContainerPoint(this.left.latlng),
                  rightPoint = this._map.latLngToContainerPoint(this.right.latlng),
                  size = L.point(this.options.icon.options.iconSize);
              if (leftPoint.distanceTo(rightPoint) < size.x * 3) this.hide();
              else this.show();
          },

          show: function () {
              this.setOpacity(this._opacity);
          },

          hide: function () {
              this.setOpacity(0);
          },

          updateLatLng: function () {
              this.setLatLng(this.computeLatLng());
              this.setVisibility();
          },

          computeLatLng: function () {
              var leftPoint = this.editor.map.latLngToContainerPoint(this.left.latlng),
                  rightPoint = this.editor.map.latLngToContainerPoint(this.right.latlng),
                  y = (leftPoint.y + rightPoint.y) / 2,
                  x = (leftPoint.x + rightPoint.x) / 2;
              return this.editor.map.containerPointToLatLng([x, y]);
          },

          onAdd: function (map) {
              L.Marker.prototype.onAdd.call(this, map);
              L.DomEvent.on(this._icon, 'mousedown touchstart', this.onMouseDown, this);
              map.on('zoomend', this.setVisibility, this);
          },

          onRemove: function (map) {
              delete this.right.middleMarker;
              L.DomEvent.off(this._icon, 'mousedown touchstart', this.onMouseDown, this);
              map.off('zoomend', this.setVisibility, this);
              L.Marker.prototype.onRemove.call(this, map);
          },

          onMouseDown: function (e) {
              var iconPos = L.DomUtil.getPosition(this._icon),
                  latlng = this.editor.map.layerPointToLatLng(iconPos);
              e = {
                  originalEvent: e,
                  latlng: latlng
              };
              if (this.options.opacity === 0) return;
              L.Editable.makeCancellable(e);
              this.editor.onMiddleMarkerMouseDown(e);
              if (e._cancelled) return;
              this.latlngs.splice(this.index(), 0, e.latlng);
              this.editor.refresh();
              var icon = this._icon;
              var marker = this.editor.addVertexMarker(e.latlng, this.latlngs);
              this.editor.onNewVertex(marker);
              /* Hack to workaround browser not firing touchend when element is no more on DOM */
              var parent = marker._icon.parentNode;
              parent.removeChild(marker._icon);
              marker._icon = icon;
              parent.appendChild(marker._icon);
              marker._initIcon();
              marker._initInteraction();
              marker.setOpacity(1);
              /* End hack */
              // Transfer ongoing dragging to real marker
              L.Draggable._dragging = false;
              marker.dragging._draggable._onDown(e.originalEvent);
              this.delete();
          },

          delete: function () {
              this.editor.editLayer.removeLayer(this);
          },

          index: function () {
              return this.latlngs.indexOf(this.right.latlng);
          }

      });

      L.Editable.mergeOptions({

          // 🍂namespace Editable
          // 🍂option middleMarkerClass: class = VertexMarker
          // Class to be used as middle vertex, pulled by the user to create a new point in the middle of a path.
          middleMarkerClass: L.Editable.MiddleMarker

      });

      // 🍂namespace Editable; 🍂class BaseEditor; 🍂aka L.Editable.BaseEditor
      // When editing a feature (Marker, Polyline…), an editor is attached to it. This
      // editor basically knows how to handle the edition.
      L.Editable.BaseEditor = L.Handler.extend({

          initialize: function (map, feature, options) {
              L.setOptions(this, options);
              this.map = map;
              this.feature = feature;
              this.feature.editor = this;
              this.editLayer = new L.LayerGroup();
              this.tools = this.options.editTools || map.editTools;
          },

          // 🍂method enable(): this
          // Set up the drawing tools for the feature to be editable.
          addHooks: function () {
              if (this.isConnected()) this.onFeatureAdd();
              else this.feature.once('add', this.onFeatureAdd, this);
              this.onEnable();
              this.feature.on(this._getEvents(), this);
              return;
          },

          // 🍂method disable(): this
          // Remove the drawing tools for the feature.
          removeHooks: function () {
              this.feature.off(this._getEvents(), this);
              if (this.feature.dragging) this.feature.dragging.disable();
              this.editLayer.clearLayers();
              this.tools.editLayer.removeLayer(this.editLayer);
              this.onDisable();
              if (this._drawing) this.cancelDrawing();
              return;
          },

          // 🍂method drawing(): boolean
          // Return true if any drawing action is ongoing with this editor.
          drawing: function () {
              return !!this._drawing;
          },

          reset: function () {},

          onFeatureAdd: function () {
              this.tools.editLayer.addLayer(this.editLayer);
              if (this.feature.dragging) this.feature.dragging.enable();
          },

          hasMiddleMarkers: function () {
              return !this.options.skipMiddleMarkers && !this.tools.options.skipMiddleMarkers;
          },

          fireAndForward: function (type, e) {
              e = e || {};
              e.layer = this.feature;
              this.feature.fire(type, e);
              this.tools.fireAndForward(type, e);
          },

          onEnable: function () {
              // 🍂namespace Editable
              // 🍂event editable:enable: Event
              // Fired when an existing feature is ready to be edited.
              this.fireAndForward('editable:enable');
          },

          onDisable: function () {
              // 🍂namespace Editable
              // 🍂event editable:disable: Event
              // Fired when an existing feature is not ready anymore to be edited.
              this.fireAndForward('editable:disable');
          },

          onEditing: function () {
              // 🍂namespace Editable
              // 🍂event editable:editing: Event
              // Fired as soon as any change is made to the feature geometry.
              this.fireAndForward('editable:editing');
          },

          onStartDrawing: function () {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:start: Event
              // Fired when a feature is to be drawn.
              this.fireAndForward('editable:drawing:start');
          },

          onEndDrawing: function () {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:end: Event
              // Fired when a feature is not drawn anymore.
              this.fireAndForward('editable:drawing:end');
          },

          onCancelDrawing: function () {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:cancel: Event
              // Fired when user cancel drawing while a feature is being drawn.
              this.fireAndForward('editable:drawing:cancel');
          },

          onCommitDrawing: function (e) {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:commit: Event
              // Fired when user finish drawing a feature.
              this.fireAndForward('editable:drawing:commit', e);
          },

          onDrawingMouseDown: function (e) {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:mousedown: Event
              // Fired when user `mousedown` while drawing.
              this.fireAndForward('editable:drawing:mousedown', e);
          },

          onDrawingMouseUp: function (e) {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:mouseup: Event
              // Fired when user `mouseup` while drawing.
              this.fireAndForward('editable:drawing:mouseup', e);
          },

          startDrawing: function () {
              if (!this._drawing) this._drawing = L.Editable.FORWARD;
              this.tools.registerForDrawing(this);
              this.onStartDrawing();
          },

          commitDrawing: function (e) {
              this.onCommitDrawing(e);
              this.endDrawing();
          },

          cancelDrawing: function () {
              // If called during a vertex drag, the vertex will be removed before
              // the mouseup fires on it. This is a workaround. Maybe better fix is
              // To have L.Draggable reset it's status on disable (Leaflet side).
              L.Draggable._dragging = false;
              this.onCancelDrawing();
              this.endDrawing();
          },

          endDrawing: function () {
              this._drawing = false;
              this.tools.unregisterForDrawing(this);
              this.onEndDrawing();
          },

          onDrawingClick: function (e) {
              if (!this.drawing()) return;
              L.Editable.makeCancellable(e);
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:click: CancelableEvent
              // Fired when user `click` while drawing, before any internal action is being processed.
              this.fireAndForward('editable:drawing:click', e);
              if (e._cancelled) return;
              if (!this.isConnected()) this.connect(e);
              this.processDrawingClick(e);
          },

          isConnected: function () {
              return this.map.hasLayer(this.feature);
          },

          connect: function (e) {
              this.tools.connectCreatedToMap(this.feature);
              this.tools.editLayer.addLayer(this.editLayer);
          },

          onMove: function (e) {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:move: Event
              // Fired when `move` mouse while drawing, while dragging a marker, and while dragging a vertex.
              this.fireAndForward('editable:drawing:move', e);
          },

          onDrawingMouseMove: function (e) {
              this.onMove(e);
          },

          _getEvents: function () {
              return {
                  dragstart: this.onDragStart,
                  drag: this.onDrag,
                  dragend: this.onDragEnd,
                  remove: this.disable
              };
          },

          onDragStart: function (e) {
              this.onEditing();
              // 🍂namespace Editable
              // 🍂event editable:dragstart: Event
              // Fired before a path feature is dragged.
              this.fireAndForward('editable:dragstart', e);
          },

          onDrag: function (e) {
              this.onMove(e);
              // 🍂namespace Editable
              // 🍂event editable:drag: Event
              // Fired when a path feature is being dragged.
              this.fireAndForward('editable:drag', e);
          },

          onDragEnd: function (e) {
              // 🍂namespace Editable
              // 🍂event editable:dragend: Event
              // Fired after a path feature has been dragged.
              this.fireAndForward('editable:dragend', e);
          }

      });

      // 🍂namespace Editable; 🍂class MarkerEditor; 🍂aka L.Editable.MarkerEditor
      // 🍂inherits BaseEditor
      // Editor for Marker.
      L.Editable.MarkerEditor = L.Editable.BaseEditor.extend({

          onDrawingMouseMove: function (e) {
              L.Editable.BaseEditor.prototype.onDrawingMouseMove.call(this, e);
              if (this._drawing) this.feature.setLatLng(e.latlng);
          },

          processDrawingClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Drawing events
              // 🍂event editable:drawing:clicked: Event
              // Fired when user `click` while drawing, after all internal actions.
              this.fireAndForward('editable:drawing:clicked', e);
              this.commitDrawing(e);
          },

          connect: function (e) {
              // On touch, the latlng has not been updated because there is
              // no mousemove.
              if (e) this.feature._latlng = e.latlng;
              L.Editable.BaseEditor.prototype.connect.call(this, e);
          }

      });

      // 🍂namespace Editable; 🍂class PathEditor; 🍂aka L.Editable.PathEditor
      // 🍂inherits BaseEditor
      // Base class for all path editors.
      L.Editable.PathEditor = L.Editable.BaseEditor.extend({

          CLOSED: false,
          MIN_VERTEX: 2,

          addHooks: function () {
              L.Editable.BaseEditor.prototype.addHooks.call(this);
              if (this.feature) this.initVertexMarkers();
              return this;
          },

          initVertexMarkers: function (latlngs) {
              if (!this.enabled()) return;
              latlngs = latlngs || this.getLatLngs();
              if (isFlat(latlngs)) this.addVertexMarkers(latlngs);
              else for (var i = 0; i < latlngs.length; i++) this.initVertexMarkers(latlngs[i]);
          },

          getLatLngs: function () {
              return this.feature.getLatLngs();
          },

          // 🍂method reset()
          // Rebuild edit elements (Vertex, MiddleMarker, etc.).
          reset: function () {
              this.editLayer.clearLayers();
              this.initVertexMarkers();
          },

          addVertexMarker: function (latlng, latlngs) {
              return new this.tools.options.vertexMarkerClass(latlng, latlngs, this);
          },

          onNewVertex: function (vertex) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:new: VertexEvent
              // Fired when a new vertex is created.
              this.fireAndForward('editable:vertex:new', {latlng: vertex.latlng, vertex: vertex});
          },

          addVertexMarkers: function (latlngs) {
              for (var i = 0; i < latlngs.length; i++) {
                  this.addVertexMarker(latlngs[i], latlngs);
              }
          },

          refreshVertexMarkers: function (latlngs) {
              latlngs = latlngs || this.getDefaultLatLngs();
              for (var i = 0; i < latlngs.length; i++) {
                  latlngs[i].__vertex.update();
              }
          },

          addMiddleMarker: function (left, right, latlngs) {
              return new this.tools.options.middleMarkerClass(left, right, latlngs, this);
          },

          onVertexMarkerClick: function (e) {
              L.Editable.makeCancellable(e);
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:click: CancelableVertexEvent
              // Fired when a `click` is issued on a vertex, before any internal action is being processed.
              this.fireAndForward('editable:vertex:click', e);
              if (e._cancelled) return;
              if (this.tools.drawing() && this.tools._drawingEditor !== this) return;
              var index = e.vertex.getIndex(), commit;
              if (e.originalEvent.ctrlKey) {
                  this.onVertexMarkerCtrlClick(e);
              } else if (e.originalEvent.altKey) {
                  this.onVertexMarkerAltClick(e);
              } else if (e.originalEvent.shiftKey) {
                  this.onVertexMarkerShiftClick(e);
              } else if (e.originalEvent.metaKey) {
                  this.onVertexMarkerMetaKeyClick(e);
              } else if (index === e.vertex.getLastIndex() && this._drawing === L.Editable.FORWARD) {
                  if (index >= this.MIN_VERTEX - 1) commit = true;
              } else if (index === 0 && this._drawing === L.Editable.BACKWARD && this._drawnLatLngs.length >= this.MIN_VERTEX) {
                  commit = true;
              } else if (index === 0 && this._drawing === L.Editable.FORWARD && this._drawnLatLngs.length >= this.MIN_VERTEX && this.CLOSED) {
                  commit = true;  // Allow to close on first point also for polygons
              } else {
                  this.onVertexRawMarkerClick(e);
              }
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:clicked: VertexEvent
              // Fired when a `click` is issued on a vertex, after all internal actions.
              this.fireAndForward('editable:vertex:clicked', e);
              if (commit) this.commitDrawing(e);
          },

          onVertexRawMarkerClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:rawclick: CancelableVertexEvent
              // Fired when a `click` is issued on a vertex without any special key and without being in drawing mode.
              this.fireAndForward('editable:vertex:rawclick', e);
              if (e._cancelled) return;
              if (!this.vertexCanBeDeleted(e.vertex)) return;
              e.vertex.delete();
          },

          vertexCanBeDeleted: function (vertex) {
              return vertex.latlngs.length > this.MIN_VERTEX;
          },

          onVertexDeleted: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:deleted: VertexEvent
              // Fired after a vertex has been deleted by user.
              this.fireAndForward('editable:vertex:deleted', e);
          },

          onVertexMarkerCtrlClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:ctrlclick: VertexEvent
              // Fired when a `click` with `ctrlKey` is issued on a vertex.
              this.fireAndForward('editable:vertex:ctrlclick', e);
          },

          onVertexMarkerShiftClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:shiftclick: VertexEvent
              // Fired when a `click` with `shiftKey` is issued on a vertex.
              this.fireAndForward('editable:vertex:shiftclick', e);
          },

          onVertexMarkerMetaKeyClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:metakeyclick: VertexEvent
              // Fired when a `click` with `metaKey` is issued on a vertex.
              this.fireAndForward('editable:vertex:metakeyclick', e);
          },

          onVertexMarkerAltClick: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:altclick: VertexEvent
              // Fired when a `click` with `altKey` is issued on a vertex.
              this.fireAndForward('editable:vertex:altclick', e);
          },

          onVertexMarkerContextMenu: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:contextmenu: VertexEvent
              // Fired when a `contextmenu` is issued on a vertex.
              this.fireAndForward('editable:vertex:contextmenu', e);
          },

          onVertexMarkerMouseDown: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:mousedown: VertexEvent
              // Fired when user `mousedown` a vertex.
              this.fireAndForward('editable:vertex:mousedown', e);
          },

          onMiddleMarkerMouseDown: function (e) {
              // 🍂namespace Editable
              // 🍂section MiddleMarker events
              // 🍂event editable:middlemarker:mousedown: VertexEvent
              // Fired when user `mousedown` a middle marker.
              this.fireAndForward('editable:middlemarker:mousedown', e);
          },

          onVertexMarkerDrag: function (e) {
              this.onMove(e);
              if (this.feature._bounds) this.extendBounds(e);
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:drag: VertexEvent
              // Fired when a vertex is dragged by user.
              this.fireAndForward('editable:vertex:drag', e);
          },

          onVertexMarkerDragStart: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:dragstart: VertexEvent
              // Fired before a vertex is dragged by user.
              this.fireAndForward('editable:vertex:dragstart', e);
          },

          onVertexMarkerDragEnd: function (e) {
              // 🍂namespace Editable
              // 🍂section Vertex events
              // 🍂event editable:vertex:dragend: VertexEvent
              // Fired after a vertex is dragged by user.
              this.fireAndForward('editable:vertex:dragend', e);
          },

          setDrawnLatLngs: function (latlngs) {
              this._drawnLatLngs = latlngs || this.getDefaultLatLngs();
          },

          startDrawing: function () {
              if (!this._drawnLatLngs) this.setDrawnLatLngs();
              L.Editable.BaseEditor.prototype.startDrawing.call(this);
          },

          startDrawingForward: function () {
              this.startDrawing();
          },

          endDrawing: function () {
              this.tools.detachForwardLineGuide();
              this.tools.detachBackwardLineGuide();
              if (this._drawnLatLngs && this._drawnLatLngs.length < this.MIN_VERTEX) this.deleteShape(this._drawnLatLngs);
              L.Editable.BaseEditor.prototype.endDrawing.call(this);
              delete this._drawnLatLngs;
          },

          addLatLng: function (latlng) {
              if (this._drawing === L.Editable.FORWARD) this._drawnLatLngs.push(latlng);
              else this._drawnLatLngs.unshift(latlng);
              this.feature._bounds.extend(latlng);
              var vertex = this.addVertexMarker(latlng, this._drawnLatLngs);
              this.onNewVertex(vertex);
              this.refresh();
          },

          newPointForward: function (latlng) {
              this.addLatLng(latlng);
              this.tools.attachForwardLineGuide();
              this.tools.anchorForwardLineGuide(latlng);
          },

          newPointBackward: function (latlng) {
              this.addLatLng(latlng);
              this.tools.anchorBackwardLineGuide(latlng);
          },

          // 🍂namespace PathEditor
          // 🍂method push()
          // Programmatically add a point while drawing.
          push: function (latlng) {
              if (!latlng) return console.error('L.Editable.PathEditor.push expect a vaild latlng as parameter');
              if (this._drawing === L.Editable.FORWARD) this.newPointForward(latlng);
              else this.newPointBackward(latlng);
          },

          removeLatLng: function (latlng) {
              latlng.__vertex.delete();
              this.refresh();
          },

          // 🍂method pop(): L.LatLng or null
          // Programmatically remove last point (if any) while drawing.
          pop: function () {
              if (this._drawnLatLngs.length <= 1) return;
              var latlng;
              if (this._drawing === L.Editable.FORWARD) latlng = this._drawnLatLngs[this._drawnLatLngs.length - 1];
              else latlng = this._drawnLatLngs[0];
              this.removeLatLng(latlng);
              if (this._drawing === L.Editable.FORWARD) this.tools.anchorForwardLineGuide(this._drawnLatLngs[this._drawnLatLngs.length - 1]);
              else this.tools.anchorForwardLineGuide(this._drawnLatLngs[0]);
              return latlng;
          },

          processDrawingClick: function (e) {
              if (e.vertex && e.vertex.editor === this) return;
              if (this._drawing === L.Editable.FORWARD) this.newPointForward(e.latlng);
              else this.newPointBackward(e.latlng);
              this.fireAndForward('editable:drawing:clicked', e);
          },

          onDrawingMouseMove: function (e) {
              L.Editable.BaseEditor.prototype.onDrawingMouseMove.call(this, e);
              if (this._drawing) {
                  this.tools.moveForwardLineGuide(e.latlng);
                  this.tools.moveBackwardLineGuide(e.latlng);
              }
          },

          refresh: function () {
              this.feature.redraw();
              this.onEditing();
          },

          // 🍂namespace PathEditor
          // 🍂method newShape(latlng?: L.LatLng)
          // Add a new shape (Polyline, Polygon) in a multi, and setup up drawing tools to draw it;
          // if optional `latlng` is given, start a path at this point.
          newShape: function (latlng) {
              var shape = this.addNewEmptyShape();
              if (!shape) return;
              this.setDrawnLatLngs(shape[0] || shape);  // Polygon or polyline
              this.startDrawingForward();
              // 🍂namespace Editable
              // 🍂section Shape events
              // 🍂event editable:shape:new: ShapeEvent
              // Fired when a new shape is created in a multi (Polygon or Polyline).
              this.fireAndForward('editable:shape:new', {shape: shape});
              if (latlng) this.newPointForward(latlng);
          },

          deleteShape: function (shape, latlngs) {
              var e = {shape: shape};
              L.Editable.makeCancellable(e);
              // 🍂namespace Editable
              // 🍂section Shape events
              // 🍂event editable:shape:delete: CancelableShapeEvent
              // Fired before a new shape is deleted in a multi (Polygon or Polyline).
              this.fireAndForward('editable:shape:delete', e);
              if (e._cancelled) return;
              shape = this._deleteShape(shape, latlngs);
              if (this.ensureNotFlat) this.ensureNotFlat();  // Polygon.
              this.feature.setLatLngs(this.getLatLngs());  // Force bounds reset.
              this.refresh();
              this.reset();
              // 🍂namespace Editable
              // 🍂section Shape events
              // 🍂event editable:shape:deleted: ShapeEvent
              // Fired after a new shape is deleted in a multi (Polygon or Polyline).
              this.fireAndForward('editable:shape:deleted', {shape: shape});
              return shape;
          },

          _deleteShape: function (shape, latlngs) {
              latlngs = latlngs || this.getLatLngs();
              if (!latlngs.length) return;
              var self = this,
                  inplaceDelete = function (latlngs, shape) {
                      // Called when deleting a flat latlngs
                      shape = latlngs.splice(0, Number.MAX_VALUE);
                      return shape;
                  },
                  spliceDelete = function (latlngs, shape) {
                      // Called when removing a latlngs inside an array
                      latlngs.splice(latlngs.indexOf(shape), 1);
                      if (!latlngs.length) self._deleteShape(latlngs);
                      return shape;
                  };
              if (latlngs === shape) return inplaceDelete(latlngs, shape);
              for (var i = 0; i < latlngs.length; i++) {
                  if (latlngs[i] === shape) return spliceDelete(latlngs, shape);
                  else if (latlngs[i].indexOf(shape) !== -1) return spliceDelete(latlngs[i], shape);
              }
          },

          // 🍂namespace PathEditor
          // 🍂method deleteShapeAt(latlng: L.LatLng): Array
          // Remove a path shape at the given `latlng`.
          deleteShapeAt: function (latlng) {
              var shape = this.feature.shapeAt(latlng);
              if (shape) return this.deleteShape(shape);
          },

          // 🍂method appendShape(shape: Array)
          // Append a new shape to the Polygon or Polyline.
          appendShape: function (shape) {
              this.insertShape(shape);
          },

          // 🍂method prependShape(shape: Array)
          // Prepend a new shape to the Polygon or Polyline.
          prependShape: function (shape) {
              this.insertShape(shape, 0);
          },

          // 🍂method insertShape(shape: Array, index: int)
          // Insert a new shape to the Polygon or Polyline at given index (default is to append).
          insertShape: function (shape, index) {
              this.ensureMulti();
              shape = this.formatShape(shape);
              if (typeof index === 'undefined') index = this.feature._latlngs.length;
              this.feature._latlngs.splice(index, 0, shape);
              this.feature.redraw();
              if (this._enabled) this.reset();
          },

          extendBounds: function (e) {
              this.feature._bounds.extend(e.vertex.latlng);
          },

          onDragStart: function (e) {
              this.editLayer.clearLayers();
              L.Editable.BaseEditor.prototype.onDragStart.call(this, e);
          },

          onDragEnd: function (e) {
              this.initVertexMarkers();
              L.Editable.BaseEditor.prototype.onDragEnd.call(this, e);
          }

      });

      // 🍂namespace Editable; 🍂class PolylineEditor; 🍂aka L.Editable.PolylineEditor
      // 🍂inherits PathEditor
      L.Editable.PolylineEditor = L.Editable.PathEditor.extend({

          startDrawingBackward: function () {
              this._drawing = L.Editable.BACKWARD;
              this.startDrawing();
          },

          // 🍂method continueBackward(latlngs?: Array)
          // Set up drawing tools to continue the line backward.
          continueBackward: function (latlngs) {
              if (this.drawing()) return;
              latlngs = latlngs || this.getDefaultLatLngs();
              this.setDrawnLatLngs(latlngs);
              if (latlngs.length > 0) {
                  this.tools.attachBackwardLineGuide();
                  this.tools.anchorBackwardLineGuide(latlngs[0]);
              }
              this.startDrawingBackward();
          },

          // 🍂method continueForward(latlngs?: Array)
          // Set up drawing tools to continue the line forward.
          continueForward: function (latlngs) {
              if (this.drawing()) return;
              latlngs = latlngs || this.getDefaultLatLngs();
              this.setDrawnLatLngs(latlngs);
              if (latlngs.length > 0) {
                  this.tools.attachForwardLineGuide();
                  this.tools.anchorForwardLineGuide(latlngs[latlngs.length - 1]);
              }
              this.startDrawingForward();
          },

          getDefaultLatLngs: function (latlngs) {
              latlngs = latlngs || this.feature._latlngs;
              if (!latlngs.length || latlngs[0] instanceof L.LatLng) return latlngs;
              else return this.getDefaultLatLngs(latlngs[0]);
          },

          ensureMulti: function () {
              if (this.feature._latlngs.length && isFlat(this.feature._latlngs)) {
                  this.feature._latlngs = [this.feature._latlngs];
              }
          },

          addNewEmptyShape: function () {
              if (this.feature._latlngs.length) {
                  var shape = [];
                  this.appendShape(shape);
                  return shape;
              } else {
                  return this.feature._latlngs;
              }
          },

          formatShape: function (shape) {
              if (isFlat(shape)) return shape;
              else if (shape[0]) return this.formatShape(shape[0]);
          },

          // 🍂method splitShape(latlngs?: Array, index: int)
          // Split the given `latlngs` shape at index `index` and integrate new shape in instance `latlngs`.
          splitShape: function (shape, index) {
              if (!index || index >= shape.length - 1) return;
              this.ensureMulti();
              var shapeIndex = this.feature._latlngs.indexOf(shape);
              if (shapeIndex === -1) return;
              var first = shape.slice(0, index + 1),
                  second = shape.slice(index);
              // We deal with reference, we don't want twice the same latlng around.
              second[0] = L.latLng(second[0].lat, second[0].lng, second[0].alt);
              this.feature._latlngs.splice(shapeIndex, 1, first, second);
              this.refresh();
              this.reset();
          }

      });

      // 🍂namespace Editable; 🍂class PolygonEditor; 🍂aka L.Editable.PolygonEditor
      // 🍂inherits PathEditor
      L.Editable.PolygonEditor = L.Editable.PathEditor.extend({

          CLOSED: true,
          MIN_VERTEX: 3,

          newPointForward: function (latlng) {
              L.Editable.PathEditor.prototype.newPointForward.call(this, latlng);
              if (!this.tools.backwardLineGuide._latlngs.length) this.tools.anchorBackwardLineGuide(latlng);
              if (this._drawnLatLngs.length === 2) this.tools.attachBackwardLineGuide();
          },

          addNewEmptyHole: function (latlng) {
              this.ensureNotFlat();
              var latlngs = this.feature.shapeAt(latlng);
              if (!latlngs) return;
              var holes = [];
              latlngs.push(holes);
              return holes;
          },

          // 🍂method newHole(latlng?: L.LatLng, index: int)
          // Set up drawing tools for creating a new hole on the Polygon. If the `latlng` param is given, a first point is created.
          newHole: function (latlng) {
              var holes = this.addNewEmptyHole(latlng);
              if (!holes) return;
              this.setDrawnLatLngs(holes);
              this.startDrawingForward();
              if (latlng) this.newPointForward(latlng);
          },

          addNewEmptyShape: function () {
              if (this.feature._latlngs.length && this.feature._latlngs[0].length) {
                  var shape = [];
                  this.appendShape(shape);
                  return shape;
              } else {
                  return this.feature._latlngs;
              }
          },

          ensureMulti: function () {
              if (this.feature._latlngs.length && isFlat(this.feature._latlngs[0])) {
                  this.feature._latlngs = [this.feature._latlngs];
              }
          },

          ensureNotFlat: function () {
              if (!this.feature._latlngs.length || isFlat(this.feature._latlngs)) this.feature._latlngs = [this.feature._latlngs];
          },

          vertexCanBeDeleted: function (vertex) {
              var parent = this.feature.parentShape(vertex.latlngs),
                  idx = L.Util.indexOf(parent, vertex.latlngs);
              if (idx > 0) return true;  // Holes can be totally deleted without removing the layer itself.
              return L.Editable.PathEditor.prototype.vertexCanBeDeleted.call(this, vertex);
          },

          getDefaultLatLngs: function () {
              if (!this.feature._latlngs.length) this.feature._latlngs.push([]);
              return this.feature._latlngs[0];
          },

          formatShape: function (shape) {
              // [[1, 2], [3, 4]] => must be nested
              // [] => must be nested
              // [[]] => is already nested
              if (isFlat(shape) && (!shape[0] || shape[0].length !== 0)) return [shape];
              else return shape;
          }

      });

      // 🍂namespace Editable; 🍂class RectangleEditor; 🍂aka L.Editable.RectangleEditor
      // 🍂inherits PathEditor
      L.Editable.RectangleEditor = L.Editable.PathEditor.extend({

          CLOSED: true,
          MIN_VERTEX: 4,

          options: {
              skipMiddleMarkers: true
          },

          extendBounds: function (e) {
              var index = e.vertex.getIndex(),
                  next = e.vertex.getNext(),
                  previous = e.vertex.getPrevious(),
                  oppositeIndex = (index + 2) % 4,
                  opposite = e.vertex.latlngs[oppositeIndex],
                  bounds = new L.LatLngBounds(e.latlng, opposite);
              // Update latlngs by hand to preserve order.
              previous.latlng.update([e.latlng.lat, opposite.lng]);
              next.latlng.update([opposite.lat, e.latlng.lng]);
              this.updateBounds(bounds);
              this.refreshVertexMarkers();
          },

          onDrawingMouseDown: function (e) {
              L.Editable.PathEditor.prototype.onDrawingMouseDown.call(this, e);
              this.connect();
              var latlngs = this.getDefaultLatLngs();
              // L.Polygon._convertLatLngs removes last latlng if it equals first point,
              // which is the case here as all latlngs are [0, 0]
              if (latlngs.length === 3) latlngs.push(e.latlng);
              var bounds = new L.LatLngBounds(e.latlng, e.latlng);
              this.updateBounds(bounds);
              this.updateLatLngs(bounds);
              this.refresh();
              this.reset();
              // Stop dragging map.
              // L.Draggable has two workflows:
              // - mousedown => mousemove => mouseup
              // - touchstart => touchmove => touchend
              // Problem: L.Map.Tap does not allow us to listen to touchstart, so we only
              // can deal with mousedown, but then when in a touch device, we are dealing with
              // simulated events (actually simulated by L.Map.Tap), which are no more taken
              // into account by L.Draggable.
              // Ref.: https://github.com/Leaflet/Leaflet.Editable/issues/103
              e.originalEvent._simulated = false;
              this.map.dragging._draggable._onUp(e.originalEvent);
              // Now transfer ongoing drag action to the bottom right corner.
              // Should we refine which corne will handle the drag according to
              // drag direction?
              latlngs[3].__vertex.dragging._draggable._onDown(e.originalEvent);
          },

          onDrawingMouseUp: function (e) {
              this.commitDrawing(e);
              e.originalEvent._simulated = false;
              L.Editable.PathEditor.prototype.onDrawingMouseUp.call(this, e);
          },

          onDrawingMouseMove: function (e) {
              e.originalEvent._simulated = false;
              L.Editable.PathEditor.prototype.onDrawingMouseMove.call(this, e);
          },


          getDefaultLatLngs: function (latlngs) {
              return latlngs || this.feature._latlngs[0];
          },

          updateBounds: function (bounds) {
              this.feature._bounds = bounds;
          },

          updateLatLngs: function (bounds) {
              var latlngs = this.getDefaultLatLngs(),
                  newLatlngs = this.feature._boundsToLatLngs(bounds);
              // Keep references.
              for (var i = 0; i < latlngs.length; i++) {
                  latlngs[i].update(newLatlngs[i]);
              }        }

      });

      // 🍂namespace Editable; 🍂class CircleEditor; 🍂aka L.Editable.CircleEditor
      // 🍂inherits PathEditor
      L.Editable.CircleEditor = L.Editable.PathEditor.extend({

          MIN_VERTEX: 2,

          options: {
              skipMiddleMarkers: true
          },

          initialize: function (map, feature, options) {
              L.Editable.PathEditor.prototype.initialize.call(this, map, feature, options);
              this._resizeLatLng = this.computeResizeLatLng();
          },

          computeResizeLatLng: function () {
              // While circle is not added to the map, _radius is not set.
              var delta = (this.feature._radius || this.feature._mRadius) * Math.cos(Math.PI / 4),
                  point = this.map.project(this.feature._latlng);
              return this.map.unproject([point.x + delta, point.y - delta]);
          },

          updateResizeLatLng: function () {
              this._resizeLatLng.update(this.computeResizeLatLng());
              this._resizeLatLng.__vertex.update();
          },

          getLatLngs: function () {
              return [this.feature._latlng, this._resizeLatLng];
          },

          getDefaultLatLngs: function () {
              return this.getLatLngs();
          },

          onVertexMarkerDrag: function (e) {
              if (e.vertex.getIndex() === 1) this.resize(e);
              else this.updateResizeLatLng(e);
              L.Editable.PathEditor.prototype.onVertexMarkerDrag.call(this, e);
          },

          resize: function (e) {
              var radius = this.feature._latlng.distanceTo(e.latlng);
              this.feature.setRadius(radius);
          },

          onDrawingMouseDown: function (e) {
              L.Editable.PathEditor.prototype.onDrawingMouseDown.call(this, e);
              this._resizeLatLng.update(e.latlng);
              this.feature._latlng.update(e.latlng);
              this.connect();
              // Stop dragging map.
              e.originalEvent._simulated = false;
              this.map.dragging._draggable._onUp(e.originalEvent);
              // Now transfer ongoing drag action to the radius handler.
              this._resizeLatLng.__vertex.dragging._draggable._onDown(e.originalEvent);
          },

          onDrawingMouseUp: function (e) {
              this.commitDrawing(e);
              e.originalEvent._simulated = false;
              L.Editable.PathEditor.prototype.onDrawingMouseUp.call(this, e);
          },

          onDrawingMouseMove: function (e) {
              e.originalEvent._simulated = false;
              L.Editable.PathEditor.prototype.onDrawingMouseMove.call(this, e);
          },

          onDrag: function (e) {
              L.Editable.PathEditor.prototype.onDrag.call(this, e);
              this.feature.dragging.updateLatLng(this._resizeLatLng);
          }

      });

      // 🍂namespace Editable; 🍂class EditableMixin
      // `EditableMixin` is included to `L.Polyline`, `L.Polygon`, `L.Rectangle`, `L.Circle`
      // and `L.Marker`. It adds some methods to them.
      // *When editing is enabled, the editor is accessible on the instance with the
      // `editor` property.*
      var EditableMixin = {

          createEditor: function (map) {
              map = map || this._map;
              var tools = (this.options.editOptions || {}).editTools || map.editTools;
              if (!tools) throw Error('Unable to detect Editable instance.')
              var Klass = this.options.editorClass || this.getEditorClass(tools);
              return new Klass(map, this, this.options.editOptions);
          },

          // 🍂method enableEdit(map?: L.Map): this.editor
          // Enable editing, by creating an editor if not existing, and then calling `enable` on it.
          enableEdit: function (map) {
              if (!this.editor) this.createEditor(map);
              this.editor.enable();
              return this.editor;
          },

          // 🍂method editEnabled(): boolean
          // Return true if current instance has an editor attached, and this editor is enabled.
          editEnabled: function () {
              return this.editor && this.editor.enabled();
          },

          // 🍂method disableEdit()
          // Disable editing, also remove the editor property reference.
          disableEdit: function () {
              if (this.editor) {
                  this.editor.disable();
                  delete this.editor;
              }
          },

          // 🍂method toggleEdit()
          // Enable or disable editing, according to current status.
          toggleEdit: function () {
              if (this.editEnabled()) this.disableEdit();
              else this.enableEdit();
          },

          _onEditableAdd: function () {
              if (this.editor) this.enableEdit();
          }

      };

      var PolylineMixin = {

          getEditorClass: function (tools) {
              return (tools && tools.options.polylineEditorClass) ? tools.options.polylineEditorClass : L.Editable.PolylineEditor;
          },

          shapeAt: function (latlng, latlngs) {
              // We can have those cases:
              // - latlngs are just a flat array of latlngs, use this
              // - latlngs is an array of arrays of latlngs, loop over
              var shape = null;
              latlngs = latlngs || this._latlngs;
              if (!latlngs.length) return shape;
              else if (isFlat(latlngs) && this.isInLatLngs(latlng, latlngs)) shape = latlngs;
              else for (var i = 0; i < latlngs.length; i++) if (this.isInLatLngs(latlng, latlngs[i])) return latlngs[i];
              return shape;
          },

          isInLatLngs: function (l, latlngs) {
              if (!latlngs) return false;
              var i, k, len, part = [], p,
                  w = this._clickTolerance();
              this._projectLatlngs(latlngs, part, this._pxBounds);
              part = part[0];
              p = this._map.latLngToLayerPoint(l);

              if (!this._pxBounds.contains(p)) { return false; }
              for (i = 1, len = part.length, k = 0; i < len; k = i++) {

                  if (L.LineUtil.pointToSegmentDistance(p, part[k], part[i]) <= w) {
                      return true;
                  }
              }
              return false;
          }

      };

      var PolygonMixin = {

          getEditorClass: function (tools) {
              return (tools && tools.options.polygonEditorClass) ? tools.options.polygonEditorClass : L.Editable.PolygonEditor;
          },

          shapeAt: function (latlng, latlngs) {
              // We can have those cases:
              // - latlngs are just a flat array of latlngs, use this
              // - latlngs is an array of arrays of latlngs, this is a simple polygon (maybe with holes), use the first
              // - latlngs is an array of arrays of arrays, this is a multi, loop over
              var shape = null;
              latlngs = latlngs || this._latlngs;
              if (!latlngs.length) return shape;
              else if (isFlat(latlngs) && this.isInLatLngs(latlng, latlngs)) shape = latlngs;
              else if (isFlat(latlngs[0]) && this.isInLatLngs(latlng, latlngs[0])) shape = latlngs;
              else for (var i = 0; i < latlngs.length; i++) if (this.isInLatLngs(latlng, latlngs[i][0])) return latlngs[i];
              return shape;
          },

          isInLatLngs: function (l, latlngs) {
              var inside = false, l1, l2, j, k, len2;

              for (j = 0, len2 = latlngs.length, k = len2 - 1; j < len2; k = j++) {
                  l1 = latlngs[j];
                  l2 = latlngs[k];

                  if (((l1.lat > l.lat) !== (l2.lat > l.lat)) &&
                          (l.lng < (l2.lng - l1.lng) * (l.lat - l1.lat) / (l2.lat - l1.lat) + l1.lng)) {
                      inside = !inside;
                  }
              }

              return inside;
          },

          parentShape: function (shape, latlngs) {
              latlngs = latlngs || this._latlngs;
              if (!latlngs) return;
              var idx = L.Util.indexOf(latlngs, shape);
              if (idx !== -1) return latlngs;
              for (var i = 0; i < latlngs.length; i++) {
                  idx = L.Util.indexOf(latlngs[i], shape);
                  if (idx !== -1) return latlngs[i];
              }
          }

      };


      var MarkerMixin = {

          getEditorClass: function (tools) {
              return (tools && tools.options.markerEditorClass) ? tools.options.markerEditorClass : L.Editable.MarkerEditor;
          }

      };

      var RectangleMixin = {

          getEditorClass: function (tools) {
              return (tools && tools.options.rectangleEditorClass) ? tools.options.rectangleEditorClass : L.Editable.RectangleEditor;
          }

      };

      var CircleMixin = {

          getEditorClass: function (tools) {
              return (tools && tools.options.circleEditorClass) ? tools.options.circleEditorClass : L.Editable.CircleEditor;
          }

      };

      var keepEditable = function () {
          // Make sure you can remove/readd an editable layer.
          this.on('add', this._onEditableAdd);
      };

      var isFlat = L.LineUtil.isFlat || L.LineUtil._flat || L.Polyline._flat;  // <=> 1.1 compat.


      if (L.Polyline) {
          L.Polyline.include(EditableMixin);
          L.Polyline.include(PolylineMixin);
          L.Polyline.addInitHook(keepEditable);
      }
      if (L.Polygon) {
          L.Polygon.include(EditableMixin);
          L.Polygon.include(PolygonMixin);
      }
      if (L.Marker) {
          L.Marker.include(EditableMixin);
          L.Marker.include(MarkerMixin);
          L.Marker.addInitHook(keepEditable);
      }
      if (L.Rectangle) {
          L.Rectangle.include(EditableMixin);
          L.Rectangle.include(RectangleMixin);
      }
      if (L.Circle) {
          L.Circle.include(EditableMixin);
          L.Circle.include(CircleMixin);
      }

      L.LatLng.prototype.update = function (latlng) {
          latlng = L.latLng(latlng);
          this.lat = latlng.lat;
          this.lng = latlng.lng;
      };

  }, window));

  /* A Draggable that does not update the element position
  and takes care of only bubbling to targetted path in Canvas mode. */
  L.PathDraggable = L.Draggable.extend({

    initialize: function (path) {
      this._path = path;
      this._canvas = (path._map.getRenderer(path) instanceof L.Canvas);
      var element = this._canvas ? this._path._map.getRenderer(this._path)._container : this._path._path;
      L.Draggable.prototype.initialize.call(this, element, element, true);
    },

    _updatePosition: function () {
      var e = {originalEvent: this._lastEvent};
      this.fire('drag', e);
    },

    _onDown: function (e) {
      var first = e.touches ? e.touches[0] : e;
      this._startPoint = new L.Point(first.clientX, first.clientY);
      if (this._canvas && !this._path._containsPoint(this._path._map.mouseEventToLayerPoint(first))) { return; }
      L.Draggable.prototype._onDown.call(this, e);
    }

  });


  L.Handler.PathDrag = L.Handler.extend({

    initialize: function (path) {
      this._path = path;
    },

    getEvents: function () {
      return {
        dragstart: this._onDragStart,
        drag: this._onDrag,
        dragend: this._onDragEnd
      };
    },

    addHooks: function () {
      if (!this._draggable) { this._draggable = new L.PathDraggable(this._path); }
      this._draggable.on(this.getEvents(), this).enable();
      L.DomUtil.addClass(this._draggable._element, 'leaflet-path-draggable');
    },

    removeHooks: function () {
      this._draggable.off(this.getEvents(), this).disable();
      L.DomUtil.removeClass(this._draggable._element, 'leaflet-path-draggable');
    },

    moved: function () {
      return this._draggable && this._draggable._moved;
    },

    _onDragStart: function () {
      this._startPoint = this._draggable._startPoint;
      this._path
          .closePopup()
          .fire('movestart')
          .fire('dragstart');
    },

    _onDrag: function (e) {
      var path = this._path,
          event = (e.originalEvent.touches && e.originalEvent.touches.length === 1 ? e.originalEvent.touches[0] : e.originalEvent),
          newPoint = L.point(event.clientX, event.clientY),
          latlng = path._map.layerPointToLatLng(newPoint);

      this._offset = newPoint.subtract(this._startPoint);
      this._startPoint = newPoint;

      this._path.eachLatLng(this.updateLatLng, this);
      path.redraw();

      e.latlng = latlng;
      e.offset = this._offset;
      path.fire('move', e)
          .fire('drag', e);
    },

    _onDragEnd: function (e) {
      if (this._path._bounds) this.resetBounds();
      this._path.fire('moveend')
          .fire('dragend', e);
    },

    latLngToLayerPoint: function (latlng) {
      // Same as map.latLngToLayerPoint, but without the round().
      var projectedPoint = this._path._map.project(L.latLng(latlng));
      return projectedPoint._subtract(this._path._map.getPixelOrigin());
    },

    updateLatLng: function (latlng) {
      var oldPoint = this.latLngToLayerPoint(latlng);
      oldPoint._add(this._offset);
      var newLatLng = this._path._map.layerPointToLatLng(oldPoint);
      latlng.lat = newLatLng.lat;
      latlng.lng = newLatLng.lng;
    },

    resetBounds: function () {
      this._path._bounds = new L.LatLngBounds();
      this._path.eachLatLng(function (latlng) {
        this._bounds.extend(latlng);
      });
    }

  });

  L.Path.include({

    eachLatLng: function (callback, context) {
      context = context || this;
      var loop = function (latlngs) {
        for (var i = 0; i < latlngs.length; i++) {
          if (L.Util.isArray(latlngs[i])) loop(latlngs[i]);
          else callback.call(context, latlngs[i]);
        }
      };
      loop(this.getLatLngs ? this.getLatLngs() : [this.getLatLng()]);
    }

  });

  L.Path.addInitHook(function () {

    this.dragging = new L.Handler.PathDrag(this);
    if (this.options.draggable) {
      this.once('add', function () {
        this.dragging.enable();
      });
    }

  });

  class AddAnother {
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

  class AddNewButton {
    connect() {
      $("[data-expanded-add-button]").each((_i, el) => this.addExpandBehaviorToButton($(el)));
    }

    addExpandBehaviorToButton(button){
      var settings = {
        speed: (button.data('speed') || 450),
        animate_width: (button.data('animate_width') || 425)
      };
      var target = $(button.data('field-target'));
      var save   = $("input[data-behavior='save']", target);
      var cancel = $("input[data-behavior='cancel']", target);
      var input  = $("input[type='text']", target);
      var original_width  = button.outerWidth();
      var expanded = false;

      // Animate button open when the mouse enters or
      // the button is given focus (i.e. clicked/tabbed)
      button.on("mouseenter focus", function(){
        expandButton();
      });

      // Don't allow blank titles
      save.on('click', function(){
        if ( inputEmpty() ) {
          return false;
        }
      });

      // Empty input and collapse
      // button on cancel click
      cancel.on('click', function(e){
        e.preventDefault();
        input.val('');
        collapseButton();
      });

      // Collapse the button on when
      // an empty input loses focus
      input.on("blur", function(){
        if ( inputEmpty() ) {
          collapseButton();
        }
      });
      function expandButton(){
        // If this has not yet been expanded, recalculate original_width to 
        // handle things that may have been originally hidden.
        if (!expanded) {
          original_width  = button.outerWidth();
        }
        if(button.outerWidth() <= (original_width + 5)) {
          expanded = true;
          button.animate(
            {width: settings.animate_width + 'px'}, settings.speed, function(){
              target.show(0, function(){
                input.focus();
                // Set the button to auto width to make
                // sure it has room for any inputs
                button.width("auto");
                // Explicitly set the width of the button
                // so the close animation works properly
                button.width(button.width());
              });
            }
          );
        }
      }
      function collapseButton(){
        target.hide();
        button.animate({width: original_width + 'px'}, settings.speed);
      }
      function inputEmpty(){
        return $.trim(input.val()) == "";
      }
    }
  }

  class Appearance {
    connect(){
      $("[data-behavior='restore-default']").each(function(){
        var hidden = $("[data-default-value]", $(this));
        var value = $($("[data-in-place-edit-target]", $(this)).data('in-place-edit-target'), $(this));
        var button = $("[data-restore-default]", $(this));
        hidden.on('blur', function(){
          if( $(this).val() == $(this).data('default-value') ) {
            button.addClass('d-none');
          } else {
            button.removeClass('d-none');
          }
        });
        button.on('click', function(e){
          e.preventDefault();
          hidden.val(hidden.data('default-value'));
          value.text(hidden.data('default-value'));
          button.hide();
        });
      });
    }
  }

  class BlacklightConfiguration {
    connect() {
      // Add Select/Deselect all button behavior
      this.addCheckboxToggleBehavior();
      this.addEnableToggleBehavior();
    }
    
    // Add Select/Deselect all button behavior
    addCheckboxToggleBehavior() {
      $("[data-behavior='metadata-select']").each(function(){
        var button = $(this);
        var parentCell = button.parents("th");
        var table = parentCell.closest("table");
        var columnRows = $("tr td:nth-child(" + (parentCell.index() + 1) + ")", table);
        var checkboxes = $("input[type='checkbox']", columnRows);
        swapSelectAllButtonText(button, columnRows);
        // Add the check/uncheck behavior to the button
        // and swap the button text if necessary
        button.on('click', function(e){
          e.preventDefault();
          var allChecked = allCheckboxesChecked(columnRows);
          columnRows.each(function(){
            $("input[type='checkbox']", $(this)).prop('checked', !allChecked);
            swapSelectAllButtonText(button, columnRows);
          });
        });
        // Swap button text when a checkbox value changes
        checkboxes.each(function(){
          $(this).on('change', function(){
            swapSelectAllButtonText(button, columnRows);
          });
        });
      });
      // Check number of checkboxes against the number of checked
      // checkboxes to determine if all of them are checked or not
      function allCheckboxesChecked(elements) {
        return ($("input[type='checkbox']", elements).length == $("input[type='checkbox']:checked", elements).length)
      }
      // Swap the button text to "Deselect all"
      // when all the checkboxes are checked and
      // "Select all" when any are unchecked
      function swapSelectAllButtonText(button, elements) {
        if ( allCheckboxesChecked(elements) ) {
          button.text(button.data('deselect-text'));
        } else {
          button.text(button.data('select-text'));
        }
      }
    }

    addEnableToggleBehavior() {
      $("[data-behavior='enable-feature']").each(function(){
        var checkbox = $(this);
        var target = $($(this).data('target'));

        checkbox.on('change', function() {
          if ($(this).is(':checked')) {
            target.find('input:checkbox').not("[data-behavior='enable-feature']").prop('checked', true).attr('disabled', false);
          } else {
            target.find('input:checkbox').not("[data-behavior='enable-feature']").prop('checked', false).attr('disabled', true);
          }
        });
      });
    }
  }

  class CopyEmailAddress {
      connect() {
          new Clipboard('.copy-email-addresses');
      }
  }

  class Iiif {
    constructor(manifestUrl, manifest) {
      this.manifestUrl = manifestUrl;
      this.manifest = manifest;
    }

    sequences() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function*() {
        for (let sequence of context.manifest.sequences) {
          yield sequence;
        }    };
      return it;
    }

    canvases() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function*() {
        for (let sequence of context.sequences()) {
          for (let canvas of sequence.canvases) {
            yield canvas;
          }
        }
      };
      return it;
    }

    images() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function*() {
        for (let canvas of context.canvases()) {
          for (let image of canvas.images) {
            var iiifService = image.resource.service['@id'];
            yield {
              'thumb': iiifService + '/full/!100,100/0/default.jpg',
              'tilesource': iiifService + '/info.json',
              'manifest': context.manifestUrl,
              'canvasId': canvas['@id'],
              'imageId': image['@id']
            };
          }
        }
      };
      return it;
    }

    imagesArray() {
      return Array.from(this.images())
    }
  }

  function addImageSelector(input, panel, manifestUrl, initialize) {
    if (!manifestUrl) {
      showNonIiifAlert(input);
      return;
    }
    var cropper = input.data('iiifCropper');
    $.ajax(manifestUrl).done(
      function(manifest) {
        var iiifManifest = new Iiif(manifestUrl, manifest);

        var thumbs = iiifManifest.imagesArray();

        hideNonIiifAlert(input);

        if (initialize) {
          cropper.setIiifFields(thumbs[0]);
          panel.multiImageSelector(); // Clears out existing selector
        }

        if(thumbs.length > 1) {
          panel.show();
          panel.multiImageSelector(thumbs, function(selectorImage) {
            cropper.setIiifFields(selectorImage);
          }, cropper.iiifImageField.val());
        }
      }
    );
  }

  function showNonIiifAlert(input){
    input.parent().prev('[data-behavior="non-iiif-alert"]').show();
  }

  function hideNonIiifAlert(input){
    input.parent().prev('[data-behavior="non-iiif-alert"]').hide();
  }

  const Spotlight$1 = function() {
    var buffer = [];
    return {
      onLoad: function(func) {
        buffer.push(func);
      },

      activate: function() {
        for(var i = 0; i < buffer.length; i++) {
          buffer[i].call();
        }
      },
      csrfToken: function () {
        return document.querySelector('meta[name=csrf-token]')?.content
      },
      ZprLinks: {
        close: "<svg xmlns=\"http://www.w3.org/2000/svg\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\"><path d=\"M0 0h24v24H0V0z\" fill=\"none\"/><path d=\"M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z\"/></svg>",
        zoomIn: "<svg xmlns=\"http://www.w3.org/2000/svg\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\"><path d=\"M0 0h24v24H0V0z\" fill=\"none\"/><path d=\"M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zm.5-7H9v2H7v1h2v2h1v-2h2V9h-2z\"/></svg>\n",
        zoomOut: "<svg xmlns=\"http://www.w3.org/2000/svg\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\"><path d=\"M0 0h24v24H0V0z\" fill=\"none\"/><path d=\"M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zM7 9h5v1H7V9z\"/></svg>\n"
      }
    };
  }();

  // This allows us to configure Spotlight in app/views/layouts/base.html.erb
  window.Spotlight = Spotlight$1;

  Blacklight.onLoad(function() {
    Spotlight$1.activate();
  });

  class Crop {
    constructor(cropArea) {
      this.cropArea = cropArea;
      this.cropArea.data('iiifCropper', this);
      this.cropSelector = '[data-cropper="' + cropArea.data('cropperKey') + '"]';
      this.cropTool = $(this.cropSelector);
      this.formPrefix = this.cropTool.data('form-prefix');
      this.iiifUrlField = $('#' + this.formPrefix + '_iiif_tilesource');
      this.iiifRegionField = $('#' + this.formPrefix + '_iiif_region');
      this.iiifManifestField = $('#' + this.formPrefix + '_iiif_manifest_url');
      this.iiifCanvasField = $('#' + this.formPrefix + '_iiif_canvas_id');
      this.iiifImageField = $('#' + this.formPrefix + '_iiif_image_id');

      this.form = cropArea.closest('form');
      this.tileSource = null;
    }

    // Render the cropper environment and add hooks into the autocomplete and upload forms
    render() {
      this.setupAutoCompletes();
      this.setupAjaxFileUpload();
      this.setupExistingIiifCropper();
    }

    // Setup the cropper on page load if the field
    // that holds the IIIF url is populated
    setupExistingIiifCropper() {
      if(this.iiifUrlField.val() === '') {
        return;
      }

      this.addImageSelectorToExistingCropTool();
      this.setTileSource(this.iiifUrlField.val());
    }

    // Display the IIIF Cropper map with the current IIIF Layer (and cropbox, once the layer is available)
    setupIiifCropper() {
      this.loaded = false;

      this.renderCropperMap();

      if (this.imageLayer) {
        // Force a broken layer's container to be an element before removing.
        // Code in leaflet-iiif land calls delete on the image layer's container when removing,
        // which errors if there is an issue fetching the info.json and stops further necessary steps to execute.
        if(!this.imageLayer._container) {
          this.imageLayer._container = $('<div></div>');
        }
        this.cropperMap.removeLayer(this.imageLayer);
      }

      this.imageLayer = L.tileLayer.iiif(this.tileSource).addTo(this.cropperMap);

      var self = this;
      this.imageLayer.on('load', function() {
        if (!self.loaded) {
          var region = self.getCropRegion();
          self.positionIiifCropBox(region);
          self.loaded = true;
        }
      });

      this.cropArea.data('initiallyVisible', this.cropArea.is(':visible'));
    }

    // Get (or initialize) the current crop region from the form data
    getCropRegion() {
      var regionFieldValue = this.iiifRegionField.val();
      if(!regionFieldValue || regionFieldValue === '') {
        var region = this.defaultCropRegion();
        this.iiifRegionField.val(region);
        return region;
      } else {
        return regionFieldValue.split(',');
      }
    }

    // Calculate a default crop region in the center of the image using the correct aspect ratio
    defaultCropRegion() {
      var imageWidth = this.imageLayer.x;
      var imageHeight = this.imageLayer.y;

      var boxWidth = Math.floor(imageWidth / 2);
      var boxHeight = Math.floor(boxWidth / this.aspectRatio());

      return [
        Math.floor((imageWidth - boxWidth) / 2),
        Math.floor((imageHeight - boxHeight) / 2),
        boxWidth,
        boxHeight
      ];
    }

    // Calculate the required aspect ratio for the crop area
    aspectRatio() {
      var cropWidth = parseInt(this.cropArea.data('crop-width'));
      var cropHeight = parseInt(this.cropArea.data('crop-height'));
      return cropWidth / cropHeight;
    }

    // Position the IIIF Crop Box at the given IIIF region
    positionIiifCropBox(region) {
      var bounds = this.unprojectIIIFRegionToBounds(region);

      if (!this.cropBox) {
        this.renderCropBox(bounds);
      }

      this.cropBox.setBounds(bounds);
      this.cropperMap.invalidateSize();
      this.cropperMap.fitBounds(bounds);

      this.cropBox.editor.editLayer.clearLayers();
      this.cropBox.editor.refresh();
      this.cropBox.editor.initVertexMarkers();
    }

    // Set all of the various input fields to
    // the appropriate IIIF URL or identifier
    setIiifFields(iiifObject) {
      this.setTileSource(iiifObject.tilesource);
      this.iiifManifestField.val(iiifObject.manifest);
      this.iiifCanvasField.val(iiifObject.canvasId);
      this.iiifImageField.val(iiifObject.imageId);
    }

    // Set the Crop tileSource and setup the cropper
    setTileSource(source) {
      if (source == this.tileSource) {
        return;
      }

      if (source === null || source === undefined) {
        console.error('No tilesource provided when setting up IIIF Cropper');
        return;
      }

      if (this.cropBox) {
        this.iiifRegionField.val("");
      }

      this.tileSource = source;
      this.iiifUrlField.val(source);
      this.setupIiifCropper();
    }

    // Render the Leaflet Map into the crop area
    renderCropperMap() {
      if (this.cropperMap) {
        return;
      }
      this.cropperMap = L.map(this.cropArea.attr('id'), {
        editable: true,
        center: [0, 0],
        crs: L.CRS.Simple,
        zoom: 0,
        editOptions: {
          rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(this.aspectRatio())
        }
      });
      this.invalidateMapSizeOnTabToggle();
    }

    // Render the crop box (a Leaflet editable rectangle) onto the canvas
    renderCropBox(initialBounds) {
      this.cropBox = L.rectangle(initialBounds);
      this.cropBox.addTo(this.cropperMap);
      this.cropBox.enableEdit();
      this.cropBox.on('dblclick', L.DomEvent.stop).on('dblclick', this.cropBox.toggleEdit);

      var self = this;
      this.cropperMap.on('editable:dragend editable:vertex:dragend', function(e) {
        var bounds = e.layer.getBounds();
        var region = self.projectBoundsToIIIFRegion(bounds);

        self.iiifRegionField.val(region.join(','));
      });
    }

    // Get the maximum zoom level for the IIIF Layer (always 1:1 image pixel to canvas?)
    maxZoom() {
      if(this.imageLayer) {
        return this.imageLayer.maxZoom;
      }
    }

    // Take a Leaflet LatLngBounds object and transform it into a IIIF [x, y, w, h] region
    projectBoundsToIIIFRegion(bounds) {
      var min = this.cropperMap.project(bounds.getNorthWest(), this.maxZoom());
      var max = this.cropperMap.project(bounds.getSouthEast(), this.maxZoom());
      return [
        Math.max(Math.floor(min.x), 0),
        Math.max(Math.floor(min.y), 0),
        Math.floor(max.x - min.x),
        Math.floor(max.y - min.y)
      ];
    }

    // Take a IIIF [x, y, w, h] region and transform it into a Leaflet LatLngBounds
    unprojectIIIFRegionToBounds(region) {
      var minPoint = L.point(parseInt(region[0]), parseInt(region[1]));
      var maxPoint = L.point(parseInt(region[0]) + parseInt(region[2]), parseInt(region[1]) + parseInt(region[3]));

      var min = this.cropperMap.unproject(minPoint, this.maxZoom());
      var max = this.cropperMap.unproject(maxPoint, this.maxZoom());
      return L.latLngBounds(min, max);
    }

    // TODO: Add accessors to update hidden inputs with IIIF uri/ids?

    // Setup autocomplete inputs to have the iiif_cropper context
    setupAutoCompletes() {
      var input = $('[data-behavior="autocomplete"]', this.cropTool);
      input.data('iiifCropper', this);
    }

    setupAjaxFileUpload() {
      this.fileInput = $('input[type="file"]', this.cropTool);
      this.fileInput.change(() => this.uploadFile());
    }

    addImageSelectorToExistingCropTool() {
      if(this.iiifManifestField.val() === '') {
        return;
      }

      var input = $('[data-behavior="autocomplete"]', this.cropTool);
      var panel = $(input.data('target-panel'));

      addImageSelector(input, panel, this.iiifManifestField.val(), !this.iiifImageField.val());
    }

    invalidateMapSizeOnTabToggle() {
      var tabs = $('[role="tablist"]', this.form);
      var self = this;
      tabs.on('shown.bs.tab', function() {
        if(self.cropArea.data('initiallyVisible') === false && self.cropArea.is(':visible')) {
          self.cropperMap.invalidateSize();
          // Because the map size is 0,0 when image is loading (not visible) we need to refit the bounds of the layer
          self.imageLayer._fitBounds();
          self.cropArea.data('initiallyVisible', null);
        }
      });
    }

    // Get all the form data with the exception of the _method field.
    getData() {
      var data = new FormData(this.form[0]);
      data.append('_method', null);
      return data;
    }

    uploadFile() {
      var url = this.fileInput.data('endpoint');
      // Every post creates a new image/masthead.
      // Because they create IIIF urls which are heavily cached.
      $.ajax({
        url: url,  //Server script to process data
        type: 'POST',
        success: (data, stat, xhr) => this.successHandler(data, stat, xhr),
        // error: errorHandler,
        // Form data
        data: this.getData(),
        headers: {
          'X-CSRF-Token': Spotlight$1.csrfToken() || ''
        },
        //Options to tell jQuery not to process data or worry about content-type.
        cache: false,
        contentType: false,
        processData: false
      });
    }

    successHandler(data, stat, xhr) {
      this.setIiifFields({ tilesource: data.tilesource });
      this.setUploadId(data.id);
    }

    setUploadId(id) {
      $('#' + this.formPrefix + "_upload_id").val(id);
    }

    aspectRatioPreservingRectangleEditor(aspect) {
      return L.Editable.RectangleEditor.extend({
        extendBounds: function (e) {
          var index = e.vertex.getIndex(),
              next = e.vertex.getNext(),
              previous = e.vertex.getPrevious(),
              oppositeIndex = (index + 2) % 4,
              opposite = e.vertex.latlngs[oppositeIndex];

          if ((index % 2) == 1) {
            // calculate horiz. displacement
            e.latlng.update([opposite.lat + ((1 / aspect) * (opposite.lng - e.latlng.lng)), e.latlng.lng]);
          } else {
            // calculate vert. displacement
            e.latlng.update([e.latlng.lat, (opposite.lng - (aspect * (opposite.lat - e.latlng.lat)))]);
          }
          var bounds = new L.LatLngBounds(e.latlng, opposite);
          // Update latlngs by hand to preserve order.
          previous.latlng.update([e.latlng.lat, opposite.lng]);
          next.latlng.update([opposite.lat, e.latlng.lng]);
          this.updateBounds(bounds);
          this.refreshVertexMarkers();
        }
      });
    }
  }

  class Croppable {
    connect() {
      $('[data-behavior="iiif-cropper"]').each(function() {
        var cropElement = $(this);
        new Crop(cropElement).render();
      });
    }
  }

  /*
    Simple plugin add edit-in-place behavior
  */
  class EditInPlace {
    connect() {
      $('[data-in-place-edit-target]').each(function() {
        $(this).on('click.inplaceedit', function() {
          var $label = $(this).find($(this).data('in-place-edit-target'));
          var $input = $(this).find($(this).data('in-place-edit-field-target'));

          // hide the edit-in-place affordance icon while in edit mode
          $(this).addClass('hide-edit-icon');
          $label.hide();
          $input.val($label.text());
          $input.attr('type', 'text');
          $input.select();
          $input.focus();

          $input.on('keypress', function(e) {
            if(e.which == 13) {
              $input.trigger('blur.inplaceedit');
              return false;
            }
          });

          $input.on('blur.inplaceedit', function() {
            var value = $input.val();

            if ($.trim(value).length == 0) {
              $input.val($label.text());
            } else {
              $label.text(value);
            }

            $label.show();
            $input.attr('type', 'hidden');
            // when leaving edit mode, should no longer hide edit-in-place affordance icon
            $("[data-in-place-edit-target]").removeClass('hide-edit-icon');

            return false;
          });

          return false;
        });
      });
    }
  }

  /**
  * Tom Select v2.3.1
  * Licensed under the Apache License, Version 2.0 (the "License");
  */

  /**
   * MicroEvent - to make any js object an event emitter
   *
   * - pure javascript - server compatible, browser compatible
   * - dont rely on the browser doms
   * - super simple - you get it immediatly, no mistery, no magic involved
   *
   * @author Jerome Etienne (https://github.com/jeromeetienne)
   */

  /**
   * Execute callback for each event in space separated list of event names
   *
   */
  function forEvents(events, callback) {
    events.split(/\s+/).forEach(event => {
      callback(event);
    });
  }
  class MicroEvent {
    constructor() {
      this._events = void 0;
      this._events = {};
    }
    on(events, fct) {
      forEvents(events, event => {
        const event_array = this._events[event] || [];
        event_array.push(fct);
        this._events[event] = event_array;
      });
    }
    off(events, fct) {
      var n = arguments.length;
      if (n === 0) {
        this._events = {};
        return;
      }
      forEvents(events, event => {
        if (n === 1) {
          delete this._events[event];
          return;
        }
        const event_array = this._events[event];
        if (event_array === undefined) return;
        event_array.splice(event_array.indexOf(fct), 1);
        this._events[event] = event_array;
      });
    }
    trigger(events, ...args) {
      var self = this;
      forEvents(events, event => {
        const event_array = self._events[event];
        if (event_array === undefined) return;
        event_array.forEach(fct => {
          fct.apply(self, args);
        });
      });
    }
  }

  /**
   * microplugin.js
   * Copyright (c) 2013 Brian Reavis & contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   * @author Brian Reavis <brian@thirdroute.com>
   */

  function MicroPlugin(Interface) {
    Interface.plugins = {};
    return class extends Interface {
      constructor(...args) {
        super(...args);
        this.plugins = {
          names: [],
          settings: {},
          requested: {},
          loaded: {}
        };
      }
      /**
       * Registers a plugin.
       *
       * @param {function} fn
       */
      static define(name, fn) {
        Interface.plugins[name] = {
          'name': name,
          'fn': fn
        };
      }

      /**
       * Initializes the listed plugins (with options).
       * Acceptable formats:
       *
       * List (without options):
       *   ['a', 'b', 'c']
       *
       * List (with options):
       *   [{'name': 'a', options: {}}, {'name': 'b', options: {}}]
       *
       * Hash (with options):
       *   {'a': { ... }, 'b': { ... }, 'c': { ... }}
       *
       * @param {array|object} plugins
       */
      initializePlugins(plugins) {
        var key, name;
        const self = this;
        const queue = [];
        if (Array.isArray(plugins)) {
          plugins.forEach(plugin => {
            if (typeof plugin === 'string') {
              queue.push(plugin);
            } else {
              self.plugins.settings[plugin.name] = plugin.options;
              queue.push(plugin.name);
            }
          });
        } else if (plugins) {
          for (key in plugins) {
            if (plugins.hasOwnProperty(key)) {
              self.plugins.settings[key] = plugins[key];
              queue.push(key);
            }
          }
        }
        while (name = queue.shift()) {
          self.require(name);
        }
      }
      loadPlugin(name) {
        var self = this;
        var plugins = self.plugins;
        var plugin = Interface.plugins[name];
        if (!Interface.plugins.hasOwnProperty(name)) {
          throw new Error('Unable to find "' + name + '" plugin');
        }
        plugins.requested[name] = true;
        plugins.loaded[name] = plugin.fn.apply(self, [self.plugins.settings[name] || {}]);
        plugins.names.push(name);
      }

      /**
       * Initializes a plugin.
       *
       */
      require(name) {
        var self = this;
        var plugins = self.plugins;
        if (!self.plugins.loaded.hasOwnProperty(name)) {
          if (plugins.requested[name]) {
            throw new Error('Plugin has circular dependency ("' + name + '")');
          }
          self.loadPlugin(name);
        }
        return plugins.loaded[name];
      }
    };
  }

  /*! @orchidjs/unicode-variants | https://github.com/orchidjs/unicode-variants | Apache License (v2) */
  /**
   * Convert array of strings to a regular expression
   *	ex ['ab','a'] => (?:ab|a)
   * 	ex ['a','b'] => [ab]
   * @param {string[]} chars
   * @return {string}
   */
  const arrayToPattern = chars => {
    chars = chars.filter(Boolean);

    if (chars.length < 2) {
      return chars[0] || '';
    }

    return maxValueLength(chars) == 1 ? '[' + chars.join('') + ']' : '(?:' + chars.join('|') + ')';
  };
  /**
   * @param {string[]} array
   * @return {string}
   */

  const sequencePattern = array => {
    if (!hasDuplicates(array)) {
      return array.join('');
    }

    let pattern = '';
    let prev_char_count = 0;

    const prev_pattern = () => {
      if (prev_char_count > 1) {
        pattern += '{' + prev_char_count + '}';
      }
    };

    array.forEach((char, i) => {
      if (char === array[i - 1]) {
        prev_char_count++;
        return;
      }

      prev_pattern();
      pattern += char;
      prev_char_count = 1;
    });
    prev_pattern();
    return pattern;
  };
  /**
   * Convert array of strings to a regular expression
   *	ex ['ab','a'] => (?:ab|a)
   * 	ex ['a','b'] => [ab]
   * @param {Set<string>} chars
   * @return {string}
   */

  const setToPattern = chars => {
    let array = toArray(chars);
    return arrayToPattern(array);
  };
  /**
   *
   * https://stackoverflow.com/questions/7376598/in-javascript-how-do-i-check-if-an-array-has-duplicate-values
   * @param {any[]} array
   */

  const hasDuplicates = array => {
    return new Set(array).size !== array.length;
  };
  /**
   * https://stackoverflow.com/questions/63006601/why-does-u-throw-an-invalid-escape-error
   * @param {string} str
   * @return {string}
   */

  const escape_regex = str => {
    return (str + '').replace(/([\$\(\)\*\+\.\?\[\]\^\{\|\}\\])/gu, '\\$1');
  };
  /**
   * Return the max length of array values
   * @param {string[]} array
   *
   */

  const maxValueLength = array => {
    return array.reduce((longest, value) => Math.max(longest, unicodeLength(value)), 0);
  };
  /**
   * @param {string} str
   */

  const unicodeLength = str => {
    return toArray(str).length;
  };
  /**
   * @param {any} p
   * @return {any[]}
   */

  const toArray = p => Array.from(p);

  /*! @orchidjs/unicode-variants | https://github.com/orchidjs/unicode-variants | Apache License (v2) */
  /**
   * Get all possible combinations of substrings that add up to the given string
   * https://stackoverflow.com/questions/30169587/find-all-the-combination-of-substrings-that-add-up-to-the-given-string
   * @param {string} input
   * @return {string[][]}
   */
  const allSubstrings = input => {
    if (input.length === 1) return [[input]];
    /** @type {string[][]} */

    let result = [];
    const start = input.substring(1);
    const suba = allSubstrings(start);
    suba.forEach(function (subresult) {
      let tmp = subresult.slice(0);
      tmp[0] = input.charAt(0) + tmp[0];
      result.push(tmp);
      tmp = subresult.slice(0);
      tmp.unshift(input.charAt(0));
      result.push(tmp);
    });
    return result;
  };

  /*! @orchidjs/unicode-variants | https://github.com/orchidjs/unicode-variants | Apache License (v2) */

  /**
   * @typedef {{[key:string]:string}} TUnicodeMap
   * @typedef {{[key:string]:Set<string>}} TUnicodeSets
   * @typedef {[[number,number]]} TCodePoints
   * @typedef {{folded:string,composed:string,code_point:number}} TCodePointObj
   * @typedef {{start:number,end:number,length:number,substr:string}} TSequencePart
   */
  /** @type {TCodePoints} */

  const code_points = [[0, 65535]];
  const accent_pat = '[\u0300-\u036F\u{b7}\u{2be}\u{2bc}]';
  /** @type {TUnicodeMap} */

  let unicode_map;
  /** @type {RegExp} */

  let multi_char_reg;
  const max_char_length = 3;
  /** @type {TUnicodeMap} */

  const latin_convert = {};
  /** @type {TUnicodeMap} */

  const latin_condensed = {
    '/': '⁄∕',
    '0': '߀',
    "a": "ⱥɐɑ",
    "aa": "ꜳ",
    "ae": "æǽǣ",
    "ao": "ꜵ",
    "au": "ꜷ",
    "av": "ꜹꜻ",
    "ay": "ꜽ",
    "b": "ƀɓƃ",
    "c": "ꜿƈȼↄ",
    "d": "đɗɖᴅƌꮷԁɦ",
    "e": "ɛǝᴇɇ",
    "f": "ꝼƒ",
    "g": "ǥɠꞡᵹꝿɢ",
    "h": "ħⱨⱶɥ",
    "i": "ɨı",
    "j": "ɉȷ",
    "k": "ƙⱪꝁꝃꝅꞣ",
    "l": "łƚɫⱡꝉꝇꞁɭ",
    "m": "ɱɯϻ",
    "n": "ꞥƞɲꞑᴎлԉ",
    "o": "øǿɔɵꝋꝍᴑ",
    "oe": "œ",
    "oi": "ƣ",
    "oo": "ꝏ",
    "ou": "ȣ",
    "p": "ƥᵽꝑꝓꝕρ",
    "q": "ꝗꝙɋ",
    "r": "ɍɽꝛꞧꞃ",
    "s": "ßȿꞩꞅʂ",
    "t": "ŧƭʈⱦꞇ",
    "th": "þ",
    "tz": "ꜩ",
    "u": "ʉ",
    "v": "ʋꝟʌ",
    "vy": "ꝡ",
    "w": "ⱳ",
    "y": "ƴɏỿ",
    "z": "ƶȥɀⱬꝣ",
    "hv": "ƕ"
  };

  for (let latin in latin_condensed) {
    let unicode = latin_condensed[latin] || '';

    for (let i = 0; i < unicode.length; i++) {
      let char = unicode.substring(i, i + 1);
      latin_convert[char] = latin;
    }
  }

  const convert_pat = new RegExp(Object.keys(latin_convert).join('|') + '|' + accent_pat, 'gu');
  /**
   * Initialize the unicode_map from the give code point ranges
   *
   * @param {TCodePoints=} _code_points
   */

  const initialize = _code_points => {
    if (unicode_map !== undefined) return;
    unicode_map = generateMap(_code_points || code_points);
  };
  /**
   * Helper method for normalize a string
   * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/normalize
   * @param {string} str
   * @param {string} form
   */

  const normalize = (str, form = 'NFKD') => str.normalize(form);
  /**
   * Remove accents without reordering string
   * calling str.normalize('NFKD') on \u{594}\u{595}\u{596} becomes \u{596}\u{594}\u{595}
   * via https://github.com/krisk/Fuse/issues/133#issuecomment-318692703
   * @param {string} str
   * @return {string}
   */

  const asciifold = str => {
    return toArray(str).reduce(
    /**
     * @param {string} result
     * @param {string} char
     */
    (result, char) => {
      return result + _asciifold(char);
    }, '');
  };
  /**
   * @param {string} str
   * @return {string}
   */

  const _asciifold = str => {
    str = normalize(str).toLowerCase().replace(convert_pat, (
    /** @type {string} */
    char) => {
      return latin_convert[char] || '';
    }); //return str;

    return normalize(str, 'NFC');
  };
  /**
   * Generate a list of unicode variants from the list of code points
   * @param {TCodePoints} code_points
   * @yield {TCodePointObj}
   */

  function* generator(code_points) {
    for (const [code_point_min, code_point_max] of code_points) {
      for (let i = code_point_min; i <= code_point_max; i++) {
        let composed = String.fromCharCode(i);
        let folded = asciifold(composed);

        if (folded == composed.toLowerCase()) {
          continue;
        } // skip when folded is a string longer than 3 characters long
        // bc the resulting regex patterns will be long
        // eg:
        // folded صلى الله عليه وسلم length 18 code point 65018
        // folded جل جلاله length 8 code point 65019


        if (folded.length > max_char_length) {
          continue;
        }

        if (folded.length == 0) {
          continue;
        }

        yield {
          folded: folded,
          composed: composed,
          code_point: i
        };
      }
    }
  }
  /**
   * Generate a unicode map from the list of code points
   * @param {TCodePoints} code_points
   * @return {TUnicodeSets}
   */

  const generateSets = code_points => {
    /** @type {{[key:string]:Set<string>}} */
    const unicode_sets = {};
    /**
     * @param {string} folded
     * @param {string} to_add
     */

    const addMatching = (folded, to_add) => {
      /** @type {Set<string>} */
      const folded_set = unicode_sets[folded] || new Set();
      const patt = new RegExp('^' + setToPattern(folded_set) + '$', 'iu');

      if (to_add.match(patt)) {
        return;
      }

      folded_set.add(escape_regex(to_add));
      unicode_sets[folded] = folded_set;
    };

    for (let value of generator(code_points)) {
      addMatching(value.folded, value.folded);
      addMatching(value.folded, value.composed);
    }

    return unicode_sets;
  };
  /**
   * Generate a unicode map from the list of code points
   * ae => (?:(?:ae|Æ|Ǽ|Ǣ)|(?:A|Ⓐ|Ａ...)(?:E|ɛ|Ⓔ...))
   *
   * @param {TCodePoints} code_points
   * @return {TUnicodeMap}
   */

  const generateMap = code_points => {
    /** @type {TUnicodeSets} */
    const unicode_sets = generateSets(code_points);
    /** @type {TUnicodeMap} */

    const unicode_map = {};
    /** @type {string[]} */

    let multi_char = [];

    for (let folded in unicode_sets) {
      let set = unicode_sets[folded];

      if (set) {
        unicode_map[folded] = setToPattern(set);
      }

      if (folded.length > 1) {
        multi_char.push(escape_regex(folded));
      }
    }

    multi_char.sort((a, b) => b.length - a.length);
    const multi_char_patt = arrayToPattern(multi_char);
    multi_char_reg = new RegExp('^' + multi_char_patt, 'u');
    return unicode_map;
  };
  /**
   * Map each element of an array from it's folded value to all possible unicode matches
   * @param {string[]} strings
   * @param {number} min_replacement
   * @return {string}
   */

  const mapSequence = (strings, min_replacement = 1) => {
    let chars_replaced = 0;
    strings = strings.map(str => {
      if (unicode_map[str]) {
        chars_replaced += str.length;
      }

      return unicode_map[str] || str;
    });

    if (chars_replaced >= min_replacement) {
      return sequencePattern(strings);
    }

    return '';
  };
  /**
   * Convert a short string and split it into all possible patterns
   * Keep a pattern only if min_replacement is met
   *
   * 'abc'
   * 		=> [['abc'],['ab','c'],['a','bc'],['a','b','c']]
   *		=> ['abc-pattern','ab-c-pattern'...]
   *
   *
   * @param {string} str
   * @param {number} min_replacement
   * @return {string}
   */

  const substringsToPattern = (str, min_replacement = 1) => {
    min_replacement = Math.max(min_replacement, str.length - 1);
    return arrayToPattern(allSubstrings(str).map(sub_pat => {
      return mapSequence(sub_pat, min_replacement);
    }));
  };
  /**
   * Convert an array of sequences into a pattern
   * [{start:0,end:3,length:3,substr:'iii'}...] => (?:iii...)
   *
   * @param {Sequence[]} sequences
   * @param {boolean} all
   */

  const sequencesToPattern = (sequences, all = true) => {
    let min_replacement = sequences.length > 1 ? 1 : 0;
    return arrayToPattern(sequences.map(sequence => {
      let seq = [];
      const len = all ? sequence.length() : sequence.length() - 1;

      for (let j = 0; j < len; j++) {
        seq.push(substringsToPattern(sequence.substrs[j] || '', min_replacement));
      }

      return sequencePattern(seq);
    }));
  };
  /**
   * Return true if the sequence is already in the sequences
   * @param {Sequence} needle_seq
   * @param {Sequence[]} sequences
   */


  const inSequences = (needle_seq, sequences) => {
    for (const seq of sequences) {
      if (seq.start != needle_seq.start || seq.end != needle_seq.end) {
        continue;
      }

      if (seq.substrs.join('') !== needle_seq.substrs.join('')) {
        continue;
      }

      let needle_parts = needle_seq.parts;
      /**
       * @param {TSequencePart} part
       */

      const filter = part => {
        for (const needle_part of needle_parts) {
          if (needle_part.start === part.start && needle_part.substr === part.substr) {
            return false;
          }

          if (part.length == 1 || needle_part.length == 1) {
            continue;
          } // check for overlapping parts
          // a = ['::=','==']
          // b = ['::','===']
          // a = ['r','sm']
          // b = ['rs','m']


          if (part.start < needle_part.start && part.end > needle_part.start) {
            return true;
          }

          if (needle_part.start < part.start && needle_part.end > part.start) {
            return true;
          }
        }

        return false;
      };

      let filtered = seq.parts.filter(filter);

      if (filtered.length > 0) {
        continue;
      }

      return true;
    }

    return false;
  };

  class Sequence {
    constructor() {
      /** @type {TSequencePart[]} */
      this.parts = [];
      /** @type {string[]} */

      this.substrs = [];
      this.start = 0;
      this.end = 0;
    }
    /**
     * @param {TSequencePart|undefined} part
     */


    add(part) {
      if (part) {
        this.parts.push(part);
        this.substrs.push(part.substr);
        this.start = Math.min(part.start, this.start);
        this.end = Math.max(part.end, this.end);
      }
    }

    last() {
      return this.parts[this.parts.length - 1];
    }

    length() {
      return this.parts.length;
    }
    /**
     * @param {number} position
     * @param {TSequencePart} last_piece
     */


    clone(position, last_piece) {
      let clone = new Sequence();
      let parts = JSON.parse(JSON.stringify(this.parts));
      let last_part = parts.pop();

      for (const part of parts) {
        clone.add(part);
      }

      let last_substr = last_piece.substr.substring(0, position - last_part.start);
      let clone_last_len = last_substr.length;
      clone.add({
        start: last_part.start,
        end: last_part.start + clone_last_len,
        length: clone_last_len,
        substr: last_substr
      });
      return clone;
    }

  }
  /**
   * Expand a regular expression pattern to include unicode variants
   * 	eg /a/ becomes /aⓐａẚàáâầấẫẩãāăằắẵẳȧǡäǟảåǻǎȁȃạậặḁąⱥɐɑAⒶＡÀÁÂẦẤẪẨÃĀĂẰẮẴẲȦǠÄǞẢÅǺǍȀȂẠẬẶḀĄȺⱯ/
   *
   * Issue:
   *  ﺊﺋ [ 'ﺊ = \\u{fe8a}', 'ﺋ = \\u{fe8b}' ]
   *	becomes:	ئئ [ 'ي = \\u{64a}', 'ٔ = \\u{654}', 'ي = \\u{64a}', 'ٔ = \\u{654}' ]
   *
   *	İĲ = IIJ = ⅡJ
   *
   * 	1/2/4
   *
   * @param {string} str
   * @return {string|undefined}
   */


  const getPattern = str => {
    initialize();
    str = asciifold(str);
    let pattern = '';
    let sequences = [new Sequence()];

    for (let i = 0; i < str.length; i++) {
      let substr = str.substring(i);
      let match = substr.match(multi_char_reg);
      const char = str.substring(i, i + 1);
      const match_str = match ? match[0] : null; // loop through sequences
      // add either the char or multi_match

      let overlapping = [];
      let added_types = new Set();

      for (const sequence of sequences) {
        const last_piece = sequence.last();

        if (!last_piece || last_piece.length == 1 || last_piece.end <= i) {
          // if we have a multi match
          if (match_str) {
            const len = match_str.length;
            sequence.add({
              start: i,
              end: i + len,
              length: len,
              substr: match_str
            });
            added_types.add('1');
          } else {
            sequence.add({
              start: i,
              end: i + 1,
              length: 1,
              substr: char
            });
            added_types.add('2');
          }
        } else if (match_str) {
          let clone = sequence.clone(i, last_piece);
          const len = match_str.length;
          clone.add({
            start: i,
            end: i + len,
            length: len,
            substr: match_str
          });
          overlapping.push(clone);
        } else {
          // don't add char
          // adding would create invalid patterns: 234 => [2,34,4]
          added_types.add('3');
        }
      } // if we have overlapping


      if (overlapping.length > 0) {
        // ['ii','iii'] before ['i','i','iii']
        overlapping = overlapping.sort((a, b) => {
          return a.length() - b.length();
        });

        for (let clone of overlapping) {
          // don't add if we already have an equivalent sequence
          if (inSequences(clone, sequences)) {
            continue;
          }

          sequences.push(clone);
        }

        continue;
      } // if we haven't done anything unique
      // clean up the patterns
      // helps keep patterns smaller
      // if str = 'r₨㎧aarss', pattern will be 446 instead of 655


      if (i > 0 && added_types.size == 1 && !added_types.has('3')) {
        pattern += sequencesToPattern(sequences, false);
        let new_seq = new Sequence();
        const old_seq = sequences[0];

        if (old_seq) {
          new_seq.add(old_seq.last());
        }

        sequences = [new_seq];
      }
    }

    pattern += sequencesToPattern(sequences, true);
    return pattern;
  };

  /*! sifter.js | https://github.com/orchidjs/sifter.js | Apache License (v2) */

  /**
   * A property getter resolving dot-notation
   * @param  {Object}  obj     The root object to fetch property on
   * @param  {String}  name    The optionally dotted property name to fetch
   * @return {Object}          The resolved property value
   */
  const getAttr = (obj, name) => {
    if (!obj) return;
    return obj[name];
  };
  /**
   * A property getter resolving dot-notation
   * @param  {Object}  obj     The root object to fetch property on
   * @param  {String}  name    The optionally dotted property name to fetch
   * @return {Object}          The resolved property value
   */

  const getAttrNesting = (obj, name) => {
    if (!obj) return;
    var part,
        names = name.split(".");

    while ((part = names.shift()) && (obj = obj[part]));

    return obj;
  };
  /**
   * Calculates how close of a match the
   * given value is against a search token.
   *
   */

  const scoreValue = (value, token, weight) => {
    var score, pos;
    if (!value) return 0;
    value = value + '';
    if (token.regex == null) return 0;
    pos = value.search(token.regex);
    if (pos === -1) return 0;
    score = token.string.length / value.length;
    if (pos === 0) score += 0.5;
    return score * weight;
  };
  /**
   * Cast object property to an array if it exists and has a value
   *
   */

  const propToArray = (obj, key) => {
    var value = obj[key];
    if (typeof value == 'function') return value;

    if (value && !Array.isArray(value)) {
      obj[key] = [value];
    }
  };
  /**
   * Iterates over arrays and hashes.
   *
   * ```
   * iterate(this.items, function(item, id) {
   *    // invoked for each item
   * });
   * ```
   *
   */

  const iterate$1 = (object, callback) => {
    if (Array.isArray(object)) {
      object.forEach(callback);
    } else {
      for (var key in object) {
        if (object.hasOwnProperty(key)) {
          callback(object[key], key);
        }
      }
    }
  };
  const cmp = (a, b) => {
    if (typeof a === 'number' && typeof b === 'number') {
      return a > b ? 1 : a < b ? -1 : 0;
    }

    a = asciifold(a + '').toLowerCase();
    b = asciifold(b + '').toLowerCase();
    if (a > b) return 1;
    if (b > a) return -1;
    return 0;
  };

  /*! sifter.js | https://github.com/orchidjs/sifter.js | Apache License (v2) */

  /**
   * sifter.js
   * Copyright (c) 2013–2020 Brian Reavis & contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   * @author Brian Reavis <brian@thirdroute.com>
   */

  class Sifter {
    // []|{};

    /**
     * Textually searches arrays and hashes of objects
     * by property (or multiple properties). Designed
     * specifically for autocomplete.
     *
     */
    constructor(items, settings) {
      this.items = void 0;
      this.settings = void 0;
      this.items = items;
      this.settings = settings || {
        diacritics: true
      };
    }

    /**
     * Splits a search string into an array of individual
     * regexps to be used to match results.
     *
     */
    tokenize(query, respect_word_boundaries, weights) {
      if (!query || !query.length) return [];
      const tokens = [];
      const words = query.split(/\s+/);
      var field_regex;

      if (weights) {
        field_regex = new RegExp('^(' + Object.keys(weights).map(escape_regex).join('|') + ')\:(.*)$');
      }

      words.forEach(word => {
        let field_match;
        let field = null;
        let regex = null; // look for "field:query" tokens

        if (field_regex && (field_match = word.match(field_regex))) {
          field = field_match[1];
          word = field_match[2];
        }

        if (word.length > 0) {
          if (this.settings.diacritics) {
            regex = getPattern(word) || null;
          } else {
            regex = escape_regex(word);
          }

          if (regex && respect_word_boundaries) regex = "\\b" + regex;
        }

        tokens.push({
          string: word,
          regex: regex ? new RegExp(regex, 'iu') : null,
          field: field
        });
      });
      return tokens;
    }

    /**
     * Returns a function to be used to score individual results.
     *
     * Good matches will have a higher score than poor matches.
     * If an item is not a match, 0 will be returned by the function.
     *
     * @returns {T.ScoreFn}
     */
    getScoreFunction(query, options) {
      var search = this.prepareSearch(query, options);
      return this._getScoreFunction(search);
    }
    /**
     * @returns {T.ScoreFn}
     *
     */


    _getScoreFunction(search) {
      const tokens = search.tokens,
            token_count = tokens.length;

      if (!token_count) {
        return function () {
          return 0;
        };
      }

      const fields = search.options.fields,
            weights = search.weights,
            field_count = fields.length,
            getAttrFn = search.getAttrFn;

      if (!field_count) {
        return function () {
          return 1;
        };
      }
      /**
       * Calculates the score of an object
       * against the search query.
       *
       */


      const scoreObject = function () {
        if (field_count === 1) {
          return function (token, data) {
            const field = fields[0].field;
            return scoreValue(getAttrFn(data, field), token, weights[field] || 1);
          };
        }

        return function (token, data) {
          var sum = 0; // is the token specific to a field?

          if (token.field) {
            const value = getAttrFn(data, token.field);

            if (!token.regex && value) {
              sum += 1 / field_count;
            } else {
              sum += scoreValue(value, token, 1);
            }
          } else {
            iterate$1(weights, (weight, field) => {
              sum += scoreValue(getAttrFn(data, field), token, weight);
            });
          }

          return sum / field_count;
        };
      }();

      if (token_count === 1) {
        return function (data) {
          return scoreObject(tokens[0], data);
        };
      }

      if (search.options.conjunction === 'and') {
        return function (data) {
          var score,
              sum = 0;

          for (let token of tokens) {
            score = scoreObject(token, data);
            if (score <= 0) return 0;
            sum += score;
          }

          return sum / token_count;
        };
      } else {
        return function (data) {
          var sum = 0;
          iterate$1(tokens, token => {
            sum += scoreObject(token, data);
          });
          return sum / token_count;
        };
      }
    }

    /**
     * Returns a function that can be used to compare two
     * results, for sorting purposes. If no sorting should
     * be performed, `null` will be returned.
     *
     * @return function(a,b)
     */
    getSortFunction(query, options) {
      var search = this.prepareSearch(query, options);
      return this._getSortFunction(search);
    }

    _getSortFunction(search) {
      var implicit_score,
          sort_flds = [];
      const self = this,
            options = search.options,
            sort = !search.query && options.sort_empty ? options.sort_empty : options.sort;

      if (typeof sort == 'function') {
        return sort.bind(this);
      }
      /**
       * Fetches the specified sort field value
       * from a search result item.
       *
       */


      const get_field = function get_field(name, result) {
        if (name === '$score') return result.score;
        return search.getAttrFn(self.items[result.id], name);
      }; // parse options


      if (sort) {
        for (let s of sort) {
          if (search.query || s.field !== '$score') {
            sort_flds.push(s);
          }
        }
      } // the "$score" field is implied to be the primary
      // sort field, unless it's manually specified


      if (search.query) {
        implicit_score = true;

        for (let fld of sort_flds) {
          if (fld.field === '$score') {
            implicit_score = false;
            break;
          }
        }

        if (implicit_score) {
          sort_flds.unshift({
            field: '$score',
            direction: 'desc'
          });
        } // without a search.query, all items will have the same score

      } else {
        sort_flds = sort_flds.filter(fld => fld.field !== '$score');
      } // build function


      const sort_flds_count = sort_flds.length;

      if (!sort_flds_count) {
        return null;
      }

      return function (a, b) {
        var result, field;

        for (let sort_fld of sort_flds) {
          field = sort_fld.field;
          let multiplier = sort_fld.direction === 'desc' ? -1 : 1;
          result = multiplier * cmp(get_field(field, a), get_field(field, b));
          if (result) return result;
        }

        return 0;
      };
    }

    /**
     * Parses a search query and returns an object
     * with tokens and fields ready to be populated
     * with results.
     *
     */
    prepareSearch(query, optsUser) {
      const weights = {};
      var options = Object.assign({}, optsUser);
      propToArray(options, 'sort');
      propToArray(options, 'sort_empty'); // convert fields to new format

      if (options.fields) {
        propToArray(options, 'fields');
        const fields = [];
        options.fields.forEach(field => {
          if (typeof field == 'string') {
            field = {
              field: field,
              weight: 1
            };
          }

          fields.push(field);
          weights[field.field] = 'weight' in field ? field.weight : 1;
        });
        options.fields = fields;
      }

      return {
        options: options,
        query: query.toLowerCase().trim(),
        tokens: this.tokenize(query, options.respect_word_boundaries, weights),
        total: 0,
        items: [],
        weights: weights,
        getAttrFn: options.nesting ? getAttrNesting : getAttr
      };
    }

    /**
     * Searches through all items and returns a sorted array of matches.
     *
     */
    search(query, options) {
      var self = this,
          score,
          search;
      search = this.prepareSearch(query, options);
      options = search.options;
      query = search.query; // generate result scoring function

      const fn_score = options.score || self._getScoreFunction(search); // perform search and sort


      if (query.length) {
        iterate$1(self.items, (item, id) => {
          score = fn_score(item);

          if (options.filter === false || score > 0) {
            search.items.push({
              'score': score,
              'id': id
            });
          }
        });
      } else {
        iterate$1(self.items, (_, id) => {
          search.items.push({
            'score': 1,
            'id': id
          });
        });
      }

      const fn_sort = self._getSortFunction(search);

      if (fn_sort) search.items.sort(fn_sort); // apply limits

      search.total = search.items.length;

      if (typeof options.limit === 'number') {
        search.items = search.items.slice(0, options.limit);
      }

      return search;
    }

  }

  /**
   * Iterates over arrays and hashes.
   *
   * ```
   * iterate(this.items, function(item, id) {
   *    // invoked for each item
   * });
   * ```
   *
   */
  const iterate = (object, callback) => {
    if (Array.isArray(object)) {
      object.forEach(callback);
    } else {
      for (var key in object) {
        if (object.hasOwnProperty(key)) {
          callback(object[key], key);
        }
      }
    }
  };

  /**
   * Return a dom element from either a dom query string, jQuery object, a dom element or html string
   * https://stackoverflow.com/questions/494143/creating-a-new-dom-element-from-an-html-string-using-built-in-dom-methods-or-pro/35385518#35385518
   *
   * param query should be {}
   */
  const getDom = query => {
    if (query.jquery) {
      return query[0];
    }
    if (query instanceof HTMLElement) {
      return query;
    }
    if (isHtmlString(query)) {
      var tpl = document.createElement('template');
      tpl.innerHTML = query.trim(); // Never return a text node of whitespace as the result
      return tpl.content.firstChild;
    }
    return document.querySelector(query);
  };
  const isHtmlString = arg => {
    if (typeof arg === 'string' && arg.indexOf('<') > -1) {
      return true;
    }
    return false;
  };
  const escapeQuery = query => {
    return query.replace(/['"\\]/g, '\\$&');
  };

  /**
   * Dispatch an event
   *
   */
  const triggerEvent = (dom_el, event_name) => {
    var event = document.createEvent('HTMLEvents');
    event.initEvent(event_name, true, false);
    dom_el.dispatchEvent(event);
  };

  /**
   * Apply CSS rules to a dom element
   *
   */
  const applyCSS = (dom_el, css) => {
    Object.assign(dom_el.style, css);
  };

  /**
   * Add css classes
   *
   */
  const addClasses = (elmts, ...classes) => {
    var norm_classes = classesArray(classes);
    elmts = castAsArray(elmts);
    elmts.map(el => {
      norm_classes.map(cls => {
        el.classList.add(cls);
      });
    });
  };

  /**
   * Remove css classes
   *
   */
  const removeClasses = (elmts, ...classes) => {
    var norm_classes = classesArray(classes);
    elmts = castAsArray(elmts);
    elmts.map(el => {
      norm_classes.map(cls => {
        el.classList.remove(cls);
      });
    });
  };

  /**
   * Return arguments
   *
   */
  const classesArray = args => {
    var classes = [];
    iterate(args, _classes => {
      if (typeof _classes === 'string') {
        _classes = _classes.trim().split(/[\11\12\14\15\40]/);
      }
      if (Array.isArray(_classes)) {
        classes = classes.concat(_classes);
      }
    });
    return classes.filter(Boolean);
  };

  /**
   * Create an array from arg if it's not already an array
   *
   */
  const castAsArray = arg => {
    if (!Array.isArray(arg)) {
      arg = [arg];
    }
    return arg;
  };

  /**
   * Get the closest node to the evt.target matching the selector
   * Stops at wrapper
   *
   */
  const parentMatch = (target, selector, wrapper) => {
    if (wrapper && !wrapper.contains(target)) {
      return;
    }
    while (target && target.matches) {
      if (target.matches(selector)) {
        return target;
      }
      target = target.parentNode;
    }
  };

  /**
   * Get the first or last item from an array
   *
   * > 0 - right (last)
   * <= 0 - left (first)
   *
   */
  const getTail = (list, direction = 0) => {
    if (direction > 0) {
      return list[list.length - 1];
    }
    return list[0];
  };

  /**
   * Return true if an object is empty
   *
   */
  const isEmptyObject = obj => {
    return Object.keys(obj).length === 0;
  };

  /**
   * Get the index of an element amongst sibling nodes of the same type
   *
   */
  const nodeIndex = (el, amongst) => {
    if (!el) return -1;
    amongst = amongst || el.nodeName;
    var i = 0;
    while (el = el.previousElementSibling) {
      if (el.matches(amongst)) {
        i++;
      }
    }
    return i;
  };

  /**
   * Set attributes of an element
   *
   */
  const setAttr = (el, attrs) => {
    iterate(attrs, (val, attr) => {
      if (val == null) {
        el.removeAttribute(attr);
      } else {
        el.setAttribute(attr, '' + val);
      }
    });
  };

  /**
   * Replace a node
   */
  const replaceNode = (existing, replacement) => {
    if (existing.parentNode) existing.parentNode.replaceChild(replacement, existing);
  };

  /**
   * highlight v3 | MIT license | Johann Burkard <jb@eaio.com>
   * Highlights arbitrary terms in a node.
   *
   * - Modified by Marshal <beatgates@gmail.com> 2011-6-24 (added regex)
   * - Modified by Brian Reavis <brian@thirdroute.com> 2012-8-27 (cleanup)
   */

  const highlight = (element, regex) => {
    if (regex === null) return;

    // convet string to regex
    if (typeof regex === 'string') {
      if (!regex.length) return;
      regex = new RegExp(regex, 'i');
    }

    // Wrap matching part of text node with highlighting <span>, e.g.
    // Soccer  ->  <span class="highlight">Soc</span>cer  for regex = /soc/i
    const highlightText = node => {
      var match = node.data.match(regex);
      if (match && node.data.length > 0) {
        var spannode = document.createElement('span');
        spannode.className = 'highlight';
        var middlebit = node.splitText(match.index);
        middlebit.splitText(match[0].length);
        var middleclone = middlebit.cloneNode(true);
        spannode.appendChild(middleclone);
        replaceNode(middlebit, spannode);
        return 1;
      }
      return 0;
    };

    // Recurse element node, looking for child text nodes to highlight, unless element
    // is childless, <script>, <style>, or already highlighted: <span class="hightlight">
    const highlightChildren = node => {
      if (node.nodeType === 1 && node.childNodes && !/(script|style)/i.test(node.tagName) && (node.className !== 'highlight' || node.tagName !== 'SPAN')) {
        Array.from(node.childNodes).forEach(element => {
          highlightRecursive(element);
        });
      }
    };
    const highlightRecursive = node => {
      if (node.nodeType === 3) {
        return highlightText(node);
      }
      highlightChildren(node);
      return 0;
    };
    highlightRecursive(element);
  };

  /**
   * removeHighlight fn copied from highlight v5 and
   * edited to remove with(), pass js strict mode, and use without jquery
   */
  const removeHighlight = el => {
    var elements = el.querySelectorAll("span.highlight");
    Array.prototype.forEach.call(elements, function (el) {
      var parent = el.parentNode;
      parent.replaceChild(el.firstChild, el);
      parent.normalize();
    });
  };

  const KEY_A = 65;
  const KEY_RETURN = 13;
  const KEY_ESC = 27;
  const KEY_LEFT = 37;
  const KEY_UP = 38;
  const KEY_RIGHT = 39;
  const KEY_DOWN = 40;
  const KEY_BACKSPACE = 8;
  const KEY_DELETE = 46;
  const KEY_TAB = 9;
  const IS_MAC = typeof navigator === 'undefined' ? false : /Mac/.test(navigator.userAgent);
  const KEY_SHORTCUT = IS_MAC ? 'metaKey' : 'ctrlKey'; // ctrl key or apple key for ma

  var defaults = {
    options: [],
    optgroups: [],
    plugins: [],
    delimiter: ',',
    splitOn: null,
    // regexp or string for splitting up values from a paste command
    persist: true,
    diacritics: true,
    create: null,
    createOnBlur: false,
    createFilter: null,
    highlight: true,
    openOnFocus: true,
    shouldOpen: null,
    maxOptions: 50,
    maxItems: null,
    hideSelected: null,
    duplicates: false,
    addPrecedence: false,
    selectOnTab: false,
    preload: null,
    allowEmptyOption: false,
    //closeAfterSelect: false,
    refreshThrottle: 300,
    loadThrottle: 300,
    loadingClass: 'loading',
    dataAttr: null,
    //'data-data',
    optgroupField: 'optgroup',
    valueField: 'value',
    labelField: 'text',
    disabledField: 'disabled',
    optgroupLabelField: 'label',
    optgroupValueField: 'value',
    lockOptgroupOrder: false,
    sortField: '$order',
    searchField: ['text'],
    searchConjunction: 'and',
    mode: null,
    wrapperClass: 'ts-wrapper',
    controlClass: 'ts-control',
    dropdownClass: 'ts-dropdown',
    dropdownContentClass: 'ts-dropdown-content',
    itemClass: 'item',
    optionClass: 'option',
    dropdownParent: null,
    controlInput: '<input type="text" autocomplete="off" size="1" />',
    copyClassesToDropdown: false,
    placeholder: null,
    hidePlaceholder: null,
    shouldLoad: function (query) {
      return query.length > 0;
    },
    /*
    load                 : null, // function(query, callback) { ... }
    score                : null, // function(search) { ... }
    onInitialize         : null, // function() { ... }
    onChange             : null, // function(value) { ... }
    onItemAdd            : null, // function(value, $item) { ... }
    onItemRemove         : null, // function(value) { ... }
    onClear              : null, // function() { ... }
    onOptionAdd          : null, // function(value, data) { ... }
    onOptionRemove       : null, // function(value) { ... }
    onOptionClear        : null, // function() { ... }
    onOptionGroupAdd     : null, // function(id, data) { ... }
    onOptionGroupRemove  : null, // function(id) { ... }
    onOptionGroupClear   : null, // function() { ... }
    onDropdownOpen       : null, // function(dropdown) { ... }
    onDropdownClose      : null, // function(dropdown) { ... }
    onType               : null, // function(str) { ... }
    onDelete             : null, // function(values) { ... }
    */

    render: {
      /*
      item: null,
      optgroup: null,
      optgroup_header: null,
      option: null,
      option_create: null
      */
    }
  };

  /**
   * Converts a scalar to its best string representation
   * for hash keys and HTML attribute values.
   *
   * Transformations:
   *   'str'     -> 'str'
   *   null      -> ''
   *   undefined -> ''
   *   true      -> '1'
   *   false     -> '0'
   *   0         -> '0'
   *   1         -> '1'
   *
   */
  const hash_key = value => {
    if (typeof value === 'undefined' || value === null) return null;
    return get_hash(value);
  };
  const get_hash = value => {
    if (typeof value === 'boolean') return value ? '1' : '0';
    return value + '';
  };

  /**
   * Escapes a string for use within HTML.
   *
   */
  const escape_html = str => {
    return (str + '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  };

  /**
   * use setTimeout if timeout > 0 
   */
  const timeout = (fn, timeout) => {
    if (timeout > 0) {
      return setTimeout(fn, timeout);
    }
    fn.call(null);
    return null;
  };

  /**
   * Debounce the user provided load function
   *
   */
  const loadDebounce = (fn, delay) => {
    var timeout;
    return function (value, callback) {
      var self = this;
      if (timeout) {
        self.loading = Math.max(self.loading - 1, 0);
        clearTimeout(timeout);
      }
      timeout = setTimeout(function () {
        timeout = null;
        self.loadedSearches[value] = true;
        fn.call(self, value, callback);
      }, delay);
    };
  };

  /**
   * Debounce all fired events types listed in `types`
   * while executing the provided `fn`.
   *
   */
  const debounce_events = (self, types, fn) => {
    var type;
    var trigger = self.trigger;
    var event_args = {};

    // override trigger method
    self.trigger = function () {
      var type = arguments[0];
      if (types.indexOf(type) !== -1) {
        event_args[type] = arguments;
      } else {
        return trigger.apply(self, arguments);
      }
    };

    // invoke provided function
    fn.apply(self, []);
    self.trigger = trigger;

    // trigger queued events
    for (type of types) {
      if (type in event_args) {
        trigger.apply(self, event_args[type]);
      }
    }
  };

  /**
   * Determines the current selection within a text input control.
   * Returns an object containing:
   *   - start
   *   - length
   *
   * Note: "selectionStart, selectionEnd ... apply only to inputs of types text, search, URL, tel and password"
   * 	- https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/setSelectionRange
   */
  const getSelection = input => {
    return {
      start: input.selectionStart || 0,
      length: (input.selectionEnd || 0) - (input.selectionStart || 0)
    };
  };

  /**
   * Prevent default
   *
   */
  const preventDefault = (evt, stop = false) => {
    if (evt) {
      evt.preventDefault();
      if (stop) {
        evt.stopPropagation();
      }
    }
  };

  /**
   * Add event helper
   *
   */
  const addEvent = (target, type, callback, options) => {
    target.addEventListener(type, callback, options);
  };

  /**
   * Return true if the requested key is down
   * Will return false if more than one control character is pressed ( when [ctrl+shift+a] != [ctrl+a] )
   * The current evt may not always set ( eg calling advanceSelection() )
   *
   */
  const isKeyDown = (key_name, evt) => {
    if (!evt) {
      return false;
    }
    if (!evt[key_name]) {
      return false;
    }
    var count = (evt.altKey ? 1 : 0) + (evt.ctrlKey ? 1 : 0) + (evt.shiftKey ? 1 : 0) + (evt.metaKey ? 1 : 0);
    if (count === 1) {
      return true;
    }
    return false;
  };

  /**
   * Get the id of an element
   * If the id attribute is not set, set the attribute with the given id
   *
   */
  const getId = (el, id) => {
    const existing_id = el.getAttribute('id');
    if (existing_id) {
      return existing_id;
    }
    el.setAttribute('id', id);
    return id;
  };

  /**
   * Returns a string with backslashes added before characters that need to be escaped.
   */
  const addSlashes = str => {
    return str.replace(/[\\"']/g, '\\$&');
  };

  /**
   *
   */
  const append = (parent, node) => {
    if (node) parent.append(node);
  };

  function getSettings(input, settings_user) {
    var settings = Object.assign({}, defaults, settings_user);
    var attr_data = settings.dataAttr;
    var field_label = settings.labelField;
    var field_value = settings.valueField;
    var field_disabled = settings.disabledField;
    var field_optgroup = settings.optgroupField;
    var field_optgroup_label = settings.optgroupLabelField;
    var field_optgroup_value = settings.optgroupValueField;
    var tag_name = input.tagName.toLowerCase();
    var placeholder = input.getAttribute('placeholder') || input.getAttribute('data-placeholder');
    if (!placeholder && !settings.allowEmptyOption) {
      let option = input.querySelector('option[value=""]');
      if (option) {
        placeholder = option.textContent;
      }
    }
    var settings_element = {
      placeholder: placeholder,
      options: [],
      optgroups: [],
      items: [],
      maxItems: null
    };

    /**
     * Initialize from a <select> element.
     *
     */
    var init_select = () => {
      var tagName;
      var options = settings_element.options;
      var optionsMap = {};
      var group_count = 1;
      let $order = 0;
      var readData = el => {
        var data = Object.assign({}, el.dataset); // get plain object from DOMStringMap
        var json = attr_data && data[attr_data];
        if (typeof json === 'string' && json.length) {
          data = Object.assign(data, JSON.parse(json));
        }
        return data;
      };
      var addOption = (option, group) => {
        var value = hash_key(option.value);
        if (value == null) return;
        if (!value && !settings.allowEmptyOption) return;

        // if the option already exists, it's probably been
        // duplicated in another optgroup. in this case, push
        // the current group to the "optgroup" property on the
        // existing option so that it's rendered in both places.
        if (optionsMap.hasOwnProperty(value)) {
          if (group) {
            var arr = optionsMap[value][field_optgroup];
            if (!arr) {
              optionsMap[value][field_optgroup] = group;
            } else if (!Array.isArray(arr)) {
              optionsMap[value][field_optgroup] = [arr, group];
            } else {
              arr.push(group);
            }
          }
        } else {
          var option_data = readData(option);
          option_data[field_label] = option_data[field_label] || option.textContent;
          option_data[field_value] = option_data[field_value] || value;
          option_data[field_disabled] = option_data[field_disabled] || option.disabled;
          option_data[field_optgroup] = option_data[field_optgroup] || group;
          option_data.$option = option;
          option_data.$order = option_data.$order || ++$order;
          optionsMap[value] = option_data;
          options.push(option_data);
        }
        if (option.selected) {
          settings_element.items.push(value);
        }
      };
      var addGroup = optgroup => {
        var id, optgroup_data;
        optgroup_data = readData(optgroup);
        optgroup_data[field_optgroup_label] = optgroup_data[field_optgroup_label] || optgroup.getAttribute('label') || '';
        optgroup_data[field_optgroup_value] = optgroup_data[field_optgroup_value] || group_count++;
        optgroup_data[field_disabled] = optgroup_data[field_disabled] || optgroup.disabled;
        optgroup_data.$order = optgroup_data.$order || ++$order;
        settings_element.optgroups.push(optgroup_data);
        id = optgroup_data[field_optgroup_value];
        iterate(optgroup.children, option => {
          addOption(option, id);
        });
      };
      settings_element.maxItems = input.hasAttribute('multiple') ? null : 1;
      iterate(input.children, child => {
        tagName = child.tagName.toLowerCase();
        if (tagName === 'optgroup') {
          addGroup(child);
        } else if (tagName === 'option') {
          addOption(child);
        }
      });
    };

    /**
     * Initialize from a <input type="text"> element.
     *
     */
    var init_textbox = () => {
      const data_raw = input.getAttribute(attr_data);
      if (!data_raw) {
        var value = input.value.trim() || '';
        if (!settings.allowEmptyOption && !value.length) return;
        const values = value.split(settings.delimiter);
        iterate(values, value => {
          const option = {};
          option[field_label] = value;
          option[field_value] = value;
          settings_element.options.push(option);
        });
        settings_element.items = values;
      } else {
        settings_element.options = JSON.parse(data_raw);
        iterate(settings_element.options, opt => {
          settings_element.items.push(opt[field_value]);
        });
      }
    };
    if (tag_name === 'select') {
      init_select();
    } else {
      init_textbox();
    }
    return Object.assign({}, defaults, settings_element, settings_user);
  }

  var instance_i = 0;
  class TomSelect extends MicroPlugin(MicroEvent) {
    constructor(input_arg, user_settings) {
      super();
      this.control_input = void 0;
      this.wrapper = void 0;
      this.dropdown = void 0;
      this.control = void 0;
      this.dropdown_content = void 0;
      this.focus_node = void 0;
      this.order = 0;
      this.settings = void 0;
      this.input = void 0;
      this.tabIndex = void 0;
      this.is_select_tag = void 0;
      this.rtl = void 0;
      this.inputId = void 0;
      this._destroy = void 0;
      this.sifter = void 0;
      this.isOpen = false;
      this.isDisabled = false;
      this.isReadOnly = false;
      this.isRequired = void 0;
      this.isInvalid = false;
      // @deprecated 1.8
      this.isValid = true;
      this.isLocked = false;
      this.isFocused = false;
      this.isInputHidden = false;
      this.isSetup = false;
      this.ignoreFocus = false;
      this.ignoreHover = false;
      this.hasOptions = false;
      this.currentResults = void 0;
      this.lastValue = '';
      this.caretPos = 0;
      this.loading = 0;
      this.loadedSearches = {};
      this.activeOption = null;
      this.activeItems = [];
      this.optgroups = {};
      this.options = {};
      this.userOptions = {};
      this.items = [];
      this.refreshTimeout = null;
      instance_i++;
      var dir;
      var input = getDom(input_arg);
      if (input.tomselect) {
        throw new Error('Tom Select already initialized on this element');
      }
      input.tomselect = this;

      // detect rtl environment
      var computedStyle = window.getComputedStyle && window.getComputedStyle(input, null);
      dir = computedStyle.getPropertyValue('direction');

      // setup default state
      const settings = getSettings(input, user_settings);
      this.settings = settings;
      this.input = input;
      this.tabIndex = input.tabIndex || 0;
      this.is_select_tag = input.tagName.toLowerCase() === 'select';
      this.rtl = /rtl/i.test(dir);
      this.inputId = getId(input, 'tomselect-' + instance_i);
      this.isRequired = input.required;

      // search system
      this.sifter = new Sifter(this.options, {
        diacritics: settings.diacritics
      });

      // option-dependent defaults
      settings.mode = settings.mode || (settings.maxItems === 1 ? 'single' : 'multi');
      if (typeof settings.hideSelected !== 'boolean') {
        settings.hideSelected = settings.mode === 'multi';
      }
      if (typeof settings.hidePlaceholder !== 'boolean') {
        settings.hidePlaceholder = settings.mode !== 'multi';
      }

      // set up createFilter callback
      var filter = settings.createFilter;
      if (typeof filter !== 'function') {
        if (typeof filter === 'string') {
          filter = new RegExp(filter);
        }
        if (filter instanceof RegExp) {
          settings.createFilter = input => filter.test(input);
        } else {
          settings.createFilter = value => {
            return this.settings.duplicates || !this.options[value];
          };
        }
      }
      this.initializePlugins(settings.plugins);
      this.setupCallbacks();
      this.setupTemplates();

      // Create all elements
      const wrapper = getDom('<div>');
      const control = getDom('<div>');
      const dropdown = this._render('dropdown');
      const dropdown_content = getDom(`<div role="listbox" tabindex="-1">`);
      const classes = this.input.getAttribute('class') || '';
      const inputMode = settings.mode;
      var control_input;
      addClasses(wrapper, settings.wrapperClass, classes, inputMode);
      addClasses(control, settings.controlClass);
      append(wrapper, control);
      addClasses(dropdown, settings.dropdownClass, inputMode);
      if (settings.copyClassesToDropdown) {
        addClasses(dropdown, classes);
      }
      addClasses(dropdown_content, settings.dropdownContentClass);
      append(dropdown, dropdown_content);
      getDom(settings.dropdownParent || wrapper).appendChild(dropdown);

      // default controlInput
      if (isHtmlString(settings.controlInput)) {
        control_input = getDom(settings.controlInput);

        // set attributes
        var attrs = ['autocorrect', 'autocapitalize', 'autocomplete', 'spellcheck'];
        iterate$1(attrs, attr => {
          if (input.getAttribute(attr)) {
            setAttr(control_input, {
              [attr]: input.getAttribute(attr)
            });
          }
        });
        control_input.tabIndex = -1;
        control.appendChild(control_input);
        this.focus_node = control_input;

        // dom element
      } else if (settings.controlInput) {
        control_input = getDom(settings.controlInput);
        this.focus_node = control_input;
      } else {
        control_input = getDom('<input/>');
        this.focus_node = control;
      }
      this.wrapper = wrapper;
      this.dropdown = dropdown;
      this.dropdown_content = dropdown_content;
      this.control = control;
      this.control_input = control_input;
      this.setup();
    }

    /**
     * set up event bindings.
     *
     */
    setup() {
      const self = this;
      const settings = self.settings;
      const control_input = self.control_input;
      const dropdown = self.dropdown;
      const dropdown_content = self.dropdown_content;
      const wrapper = self.wrapper;
      const control = self.control;
      const input = self.input;
      const focus_node = self.focus_node;
      const passive_event = {
        passive: true
      };
      const listboxId = self.inputId + '-ts-dropdown';
      setAttr(dropdown_content, {
        id: listboxId
      });
      setAttr(focus_node, {
        role: 'combobox',
        'aria-haspopup': 'listbox',
        'aria-expanded': 'false',
        'aria-controls': listboxId
      });
      const control_id = getId(focus_node, self.inputId + '-ts-control');
      const query = "label[for='" + escapeQuery(self.inputId) + "']";
      const label = document.querySelector(query);
      const label_click = self.focus.bind(self);
      if (label) {
        addEvent(label, 'click', label_click);
        setAttr(label, {
          for: control_id
        });
        const label_id = getId(label, self.inputId + '-ts-label');
        setAttr(focus_node, {
          'aria-labelledby': label_id
        });
        setAttr(dropdown_content, {
          'aria-labelledby': label_id
        });
      }
      wrapper.style.width = input.style.width;
      if (self.plugins.names.length) {
        const classes_plugins = 'plugin-' + self.plugins.names.join(' plugin-');
        addClasses([wrapper, dropdown], classes_plugins);
      }
      if ((settings.maxItems === null || settings.maxItems > 1) && self.is_select_tag) {
        setAttr(input, {
          multiple: 'multiple'
        });
      }
      if (settings.placeholder) {
        setAttr(control_input, {
          placeholder: settings.placeholder
        });
      }

      // if splitOn was not passed in, construct it from the delimiter to allow pasting universally
      if (!settings.splitOn && settings.delimiter) {
        settings.splitOn = new RegExp('\\s*' + escape_regex(settings.delimiter) + '+\\s*');
      }

      // debounce user defined load() if loadThrottle > 0
      // after initializePlugins() so plugins can create/modify user defined loaders
      if (settings.load && settings.loadThrottle) {
        settings.load = loadDebounce(settings.load, settings.loadThrottle);
      }
      addEvent(dropdown, 'mousemove', () => {
        self.ignoreHover = false;
      });
      addEvent(dropdown, 'mouseenter', e => {
        var target_match = parentMatch(e.target, '[data-selectable]', dropdown);
        if (target_match) self.onOptionHover(e, target_match);
      }, {
        capture: true
      });

      // clicking on an option should select it
      addEvent(dropdown, 'click', evt => {
        const option = parentMatch(evt.target, '[data-selectable]');
        if (option) {
          self.onOptionSelect(evt, option);
          preventDefault(evt, true);
        }
      });
      addEvent(control, 'click', evt => {
        var target_match = parentMatch(evt.target, '[data-ts-item]', control);
        if (target_match && self.onItemSelect(evt, target_match)) {
          preventDefault(evt, true);
          return;
        }

        // retain focus (see control_input mousedown)
        if (control_input.value != '') {
          return;
        }
        self.onClick();
        preventDefault(evt, true);
      });

      // keydown on focus_node for arrow_down/arrow_up
      addEvent(focus_node, 'keydown', e => self.onKeyDown(e));

      // keypress and input/keyup
      addEvent(control_input, 'keypress', e => self.onKeyPress(e));
      addEvent(control_input, 'input', e => self.onInput(e));
      addEvent(focus_node, 'blur', e => self.onBlur(e));
      addEvent(focus_node, 'focus', e => self.onFocus(e));
      addEvent(control_input, 'paste', e => self.onPaste(e));
      const doc_mousedown = evt => {
        // blur if target is outside of this instance
        // dropdown is not always inside wrapper
        const target = evt.composedPath()[0];
        if (!wrapper.contains(target) && !dropdown.contains(target)) {
          if (self.isFocused) {
            self.blur();
          }
          self.inputState();
          return;
        }

        // retain focus by preventing native handling. if the
        // event target is the input it should not be modified.
        // otherwise, text selection within the input won't work.
        // Fixes bug #212 which is no covered by tests
        if (target == control_input && self.isOpen) {
          evt.stopPropagation();

          // clicking anywhere in the control should not blur the control_input (which would close the dropdown)
        } else {
          preventDefault(evt, true);
        }
      };
      const win_scroll = () => {
        if (self.isOpen) {
          self.positionDropdown();
        }
      };
      addEvent(document, 'mousedown', doc_mousedown);
      addEvent(window, 'scroll', win_scroll, passive_event);
      addEvent(window, 'resize', win_scroll, passive_event);
      this._destroy = () => {
        document.removeEventListener('mousedown', doc_mousedown);
        window.removeEventListener('scroll', win_scroll);
        window.removeEventListener('resize', win_scroll);
        if (label) label.removeEventListener('click', label_click);
      };

      // store original html and tab index so that they can be
      // restored when the destroy() method is called.
      this.revertSettings = {
        innerHTML: input.innerHTML,
        tabIndex: input.tabIndex
      };
      input.tabIndex = -1;
      input.insertAdjacentElement('afterend', self.wrapper);
      self.sync(false);
      settings.items = [];
      delete settings.optgroups;
      delete settings.options;
      addEvent(input, 'invalid', () => {
        if (self.isValid) {
          self.isValid = false;
          self.isInvalid = true;
          self.refreshState();
        }
      });
      self.updateOriginalInput();
      self.refreshItems();
      self.close(false);
      self.inputState();
      self.isSetup = true;
      if (input.disabled) {
        self.disable();
      } else if (input.readOnly) {
        self.setReadOnly(true);
      } else {
        self.enable(); //sets tabIndex
      }

      self.on('change', this.onChange);
      addClasses(input, 'tomselected', 'ts-hidden-accessible');
      self.trigger('initialize');

      // preload options
      if (settings.preload === true) {
        self.preload();
      }
    }

    /**
     * Register options and optgroups
     *
     */
    setupOptions(options = [], optgroups = []) {
      // build options table
      this.addOptions(options);

      // build optgroup table
      iterate$1(optgroups, optgroup => {
        this.registerOptionGroup(optgroup);
      });
    }

    /**
     * Sets up default rendering functions.
     */
    setupTemplates() {
      var self = this;
      var field_label = self.settings.labelField;
      var field_optgroup = self.settings.optgroupLabelField;
      var templates = {
        'optgroup': data => {
          let optgroup = document.createElement('div');
          optgroup.className = 'optgroup';
          optgroup.appendChild(data.options);
          return optgroup;
        },
        'optgroup_header': (data, escape) => {
          return '<div class="optgroup-header">' + escape(data[field_optgroup]) + '</div>';
        },
        'option': (data, escape) => {
          return '<div>' + escape(data[field_label]) + '</div>';
        },
        'item': (data, escape) => {
          return '<div>' + escape(data[field_label]) + '</div>';
        },
        'option_create': (data, escape) => {
          return '<div class="create">Add <strong>' + escape(data.input) + '</strong>&hellip;</div>';
        },
        'no_results': () => {
          return '<div class="no-results">No results found</div>';
        },
        'loading': () => {
          return '<div class="spinner"></div>';
        },
        'not_loading': () => {},
        'dropdown': () => {
          return '<div></div>';
        }
      };
      self.settings.render = Object.assign({}, templates, self.settings.render);
    }

    /**
     * Maps fired events to callbacks provided
     * in the settings used when creating the control.
     */
    setupCallbacks() {
      var key, fn;
      var callbacks = {
        'initialize': 'onInitialize',
        'change': 'onChange',
        'item_add': 'onItemAdd',
        'item_remove': 'onItemRemove',
        'item_select': 'onItemSelect',
        'clear': 'onClear',
        'option_add': 'onOptionAdd',
        'option_remove': 'onOptionRemove',
        'option_clear': 'onOptionClear',
        'optgroup_add': 'onOptionGroupAdd',
        'optgroup_remove': 'onOptionGroupRemove',
        'optgroup_clear': 'onOptionGroupClear',
        'dropdown_open': 'onDropdownOpen',
        'dropdown_close': 'onDropdownClose',
        'type': 'onType',
        'load': 'onLoad',
        'focus': 'onFocus',
        'blur': 'onBlur'
      };
      for (key in callbacks) {
        fn = this.settings[callbacks[key]];
        if (fn) this.on(key, fn);
      }
    }

    /**
     * Sync the Tom Select instance with the original input or select
     *
     */
    sync(get_settings = true) {
      const self = this;
      const settings = get_settings ? getSettings(self.input, {
        delimiter: self.settings.delimiter
      }) : self.settings;
      self.setupOptions(settings.options, settings.optgroups);
      self.setValue(settings.items || [], true); // silent prevents recursion

      self.lastQuery = null; // so updated options will be displayed in dropdown
    }

    /**
     * Triggered when the main control element
     * has a click event.
     *
     */
    onClick() {
      var self = this;
      if (self.activeItems.length > 0) {
        self.clearActiveItems();
        self.focus();
        return;
      }
      if (self.isFocused && self.isOpen) {
        self.blur();
      } else {
        self.focus();
      }
    }

    /**
     * @deprecated v1.7
     *
     */
    onMouseDown() {}

    /**
     * Triggered when the value of the control has been changed.
     * This should propagate the event to the original DOM
     * input / select element.
     */
    onChange() {
      triggerEvent(this.input, 'input');
      triggerEvent(this.input, 'change');
    }

    /**
     * Triggered on <input> paste.
     *
     */
    onPaste(e) {
      var self = this;
      if (self.isInputHidden || self.isLocked) {
        preventDefault(e);
        return;
      }

      // If a regex or string is included, this will split the pasted
      // input and create Items for each separate value
      if (!self.settings.splitOn) {
        return;
      }

      // Wait for pasted text to be recognized in value
      setTimeout(() => {
        var pastedText = self.inputValue();
        if (!pastedText.match(self.settings.splitOn)) {
          return;
        }
        var splitInput = pastedText.trim().split(self.settings.splitOn);
        iterate$1(splitInput, piece => {
          const hash = hash_key(piece);
          if (hash) {
            if (this.options[piece]) {
              self.addItem(piece);
            } else {
              self.createItem(piece);
            }
          }
        });
      }, 0);
    }

    /**
     * Triggered on <input> keypress.
     *
     */
    onKeyPress(e) {
      var self = this;
      if (self.isLocked) {
        preventDefault(e);
        return;
      }
      var character = String.fromCharCode(e.keyCode || e.which);
      if (self.settings.create && self.settings.mode === 'multi' && character === self.settings.delimiter) {
        self.createItem();
        preventDefault(e);
        return;
      }
    }

    /**
     * Triggered on <input> keydown.
     *
     */
    onKeyDown(e) {
      var self = this;
      self.ignoreHover = true;
      if (self.isLocked) {
        if (e.keyCode !== KEY_TAB) {
          preventDefault(e);
        }
        return;
      }
      switch (e.keyCode) {
        // ctrl+A: select all
        case KEY_A:
          if (isKeyDown(KEY_SHORTCUT, e)) {
            if (self.control_input.value == '') {
              preventDefault(e);
              self.selectAll();
              return;
            }
          }
          break;

        // esc: close dropdown
        case KEY_ESC:
          if (self.isOpen) {
            preventDefault(e, true);
            self.close();
          }
          self.clearActiveItems();
          return;

        // down: open dropdown or move selection down
        case KEY_DOWN:
          if (!self.isOpen && self.hasOptions) {
            self.open();
          } else if (self.activeOption) {
            let next = self.getAdjacent(self.activeOption, 1);
            if (next) self.setActiveOption(next);
          }
          preventDefault(e);
          return;

        // up: move selection up
        case KEY_UP:
          if (self.activeOption) {
            let prev = self.getAdjacent(self.activeOption, -1);
            if (prev) self.setActiveOption(prev);
          }
          preventDefault(e);
          return;

        // return: select active option
        case KEY_RETURN:
          if (self.canSelect(self.activeOption)) {
            self.onOptionSelect(e, self.activeOption);
            preventDefault(e);

            // if the option_create=null, the dropdown might be closed
          } else if (self.settings.create && self.createItem()) {
            preventDefault(e);

            // don't submit form when searching for a value
          } else if (document.activeElement == self.control_input && self.isOpen) {
            preventDefault(e);
          }
          return;

        // left: modifiy item selection to the left
        case KEY_LEFT:
          self.advanceSelection(-1, e);
          return;

        // right: modifiy item selection to the right
        case KEY_RIGHT:
          self.advanceSelection(1, e);
          return;

        // tab: select active option and/or create item
        case KEY_TAB:
          if (self.settings.selectOnTab) {
            if (self.canSelect(self.activeOption)) {
              self.onOptionSelect(e, self.activeOption);

              // prevent default [tab] behaviour of jump to the next field
              // if select isFull, then the dropdown won't be open and [tab] will work normally
              preventDefault(e);
            }
            if (self.settings.create && self.createItem()) {
              preventDefault(e);
            }
          }
          return;

        // delete|backspace: delete items
        case KEY_BACKSPACE:
        case KEY_DELETE:
          self.deleteSelection(e);
          return;
      }

      // don't enter text in the control_input when active items are selected
      if (self.isInputHidden && !isKeyDown(KEY_SHORTCUT, e)) {
        preventDefault(e);
      }
    }

    /**
     * Triggered on <input> keyup.
     *
     */
    onInput(e) {
      if (this.isLocked) {
        return;
      }
      const value = this.inputValue();
      if (this.lastValue === value) return;
      this.lastValue = value;
      if (value == '') {
        this._onInput();
        return;
      }
      if (this.refreshTimeout) {
        clearTimeout(this.refreshTimeout);
      }
      this.refreshTimeout = timeout(() => {
        this.refreshTimeout = null;
        this._onInput();
      }, this.settings.refreshThrottle);
    }
    _onInput() {
      const value = this.lastValue;
      if (this.settings.shouldLoad.call(this, value)) {
        this.load(value);
      }
      this.refreshOptions();
      this.trigger('type', value);
    }

    /**
     * Triggered when the user rolls over
     * an option in the autocomplete dropdown menu.
     *
     */
    onOptionHover(evt, option) {
      if (this.ignoreHover) return;
      this.setActiveOption(option, false);
    }

    /**
     * Triggered on <input> focus.
     *
     */
    onFocus(e) {
      var self = this;
      var wasFocused = self.isFocused;
      if (self.isDisabled || self.isReadOnly) {
        self.blur();
        preventDefault(e);
        return;
      }
      if (self.ignoreFocus) return;
      self.isFocused = true;
      if (self.settings.preload === 'focus') self.preload();
      if (!wasFocused) self.trigger('focus');
      if (!self.activeItems.length) {
        self.inputState();
        self.refreshOptions(!!self.settings.openOnFocus);
      }
      self.refreshState();
    }

    /**
     * Triggered on <input> blur.
     *
     */
    onBlur(e) {
      if (document.hasFocus() === false) return;
      var self = this;
      if (!self.isFocused) return;
      self.isFocused = false;
      self.ignoreFocus = false;
      var deactivate = () => {
        self.close();
        self.setActiveItem();
        self.setCaret(self.items.length);
        self.trigger('blur');
      };
      if (self.settings.create && self.settings.createOnBlur) {
        self.createItem(null, deactivate);
      } else {
        deactivate();
      }
    }

    /**
     * Triggered when the user clicks on an option
     * in the autocomplete dropdown menu.
     *
     */
    onOptionSelect(evt, option) {
      var value,
        self = this;

      // should not be possible to trigger a option under a disabled optgroup
      if (option.parentElement && option.parentElement.matches('[data-disabled]')) {
        return;
      }
      if (option.classList.contains('create')) {
        self.createItem(null, () => {
          if (self.settings.closeAfterSelect) {
            self.close();
          }
        });
      } else {
        value = option.dataset.value;
        if (typeof value !== 'undefined') {
          self.lastQuery = null;
          self.addItem(value);
          if (self.settings.closeAfterSelect) {
            self.close();
          }
          if (!self.settings.hideSelected && evt.type && /click/.test(evt.type)) {
            self.setActiveOption(option);
          }
        }
      }
    }

    /**
     * Return true if the given option can be selected
     *
     */
    canSelect(option) {
      if (this.isOpen && option && this.dropdown_content.contains(option)) {
        return true;
      }
      return false;
    }

    /**
     * Triggered when the user clicks on an item
     * that has been selected.
     *
     */
    onItemSelect(evt, item) {
      var self = this;
      if (!self.isLocked && self.settings.mode === 'multi') {
        preventDefault(evt);
        self.setActiveItem(item, evt);
        return true;
      }
      return false;
    }

    /**
     * Determines whether or not to invoke
     * the user-provided option provider / loader
     *
     * Note, there is a subtle difference between
     * this.canLoad() and this.settings.shouldLoad();
     *
     *	- settings.shouldLoad() is a user-input validator.
     *	When false is returned, the not_loading template
     *	will be added to the dropdown
     *
     *	- canLoad() is lower level validator that checks
     * 	the Tom Select instance. There is no inherent user
     *	feedback when canLoad returns false
     *
     */
    canLoad(value) {
      if (!this.settings.load) return false;
      if (this.loadedSearches.hasOwnProperty(value)) return false;
      return true;
    }

    /**
     * Invokes the user-provided option provider / loader.
     *
     */
    load(value) {
      const self = this;
      if (!self.canLoad(value)) return;
      addClasses(self.wrapper, self.settings.loadingClass);
      self.loading++;
      const callback = self.loadCallback.bind(self);
      self.settings.load.call(self, value, callback);
    }

    /**
     * Invoked by the user-provided option provider
     *
     */
    loadCallback(options, optgroups) {
      const self = this;
      self.loading = Math.max(self.loading - 1, 0);
      self.lastQuery = null;
      self.clearActiveOption(); // when new results load, focus should be on first option
      self.setupOptions(options, optgroups);
      self.refreshOptions(self.isFocused && !self.isInputHidden);
      if (!self.loading) {
        removeClasses(self.wrapper, self.settings.loadingClass);
      }
      self.trigger('load', options, optgroups);
    }
    preload() {
      var classList = this.wrapper.classList;
      if (classList.contains('preloaded')) return;
      classList.add('preloaded');
      this.load('');
    }

    /**
     * Sets the input field of the control to the specified value.
     *
     */
    setTextboxValue(value = '') {
      var input = this.control_input;
      var changed = input.value !== value;
      if (changed) {
        input.value = value;
        triggerEvent(input, 'update');
        this.lastValue = value;
      }
    }

    /**
     * Returns the value of the control. If multiple items
     * can be selected (e.g. <select multiple>), this returns
     * an array. If only one item can be selected, this
     * returns a string.
     *
     */
    getValue() {
      if (this.is_select_tag && this.input.hasAttribute('multiple')) {
        return this.items;
      }
      return this.items.join(this.settings.delimiter);
    }

    /**
     * Resets the selected items to the given value.
     *
     */
    setValue(value, silent) {
      var events = silent ? [] : ['change'];
      debounce_events(this, events, () => {
        this.clear(silent);
        this.addItems(value, silent);
      });
    }

    /**
     * Resets the number of max items to the given value
     *
     */
    setMaxItems(value) {
      if (value === 0) value = null; //reset to unlimited items.
      this.settings.maxItems = value;
      this.refreshState();
    }

    /**
     * Sets the selected item.
     *
     */
    setActiveItem(item, e) {
      var self = this;
      var eventName;
      var i, begin, end, swap;
      var last;
      if (self.settings.mode === 'single') return;

      // clear the active selection
      if (!item) {
        self.clearActiveItems();
        if (self.isFocused) {
          self.inputState();
        }
        return;
      }

      // modify selection
      eventName = e && e.type.toLowerCase();
      if (eventName === 'click' && isKeyDown('shiftKey', e) && self.activeItems.length) {
        last = self.getLastActive();
        begin = Array.prototype.indexOf.call(self.control.children, last);
        end = Array.prototype.indexOf.call(self.control.children, item);
        if (begin > end) {
          swap = begin;
          begin = end;
          end = swap;
        }
        for (i = begin; i <= end; i++) {
          item = self.control.children[i];
          if (self.activeItems.indexOf(item) === -1) {
            self.setActiveItemClass(item);
          }
        }
        preventDefault(e);
      } else if (eventName === 'click' && isKeyDown(KEY_SHORTCUT, e) || eventName === 'keydown' && isKeyDown('shiftKey', e)) {
        if (item.classList.contains('active')) {
          self.removeActiveItem(item);
        } else {
          self.setActiveItemClass(item);
        }
      } else {
        self.clearActiveItems();
        self.setActiveItemClass(item);
      }

      // ensure control has focus
      self.inputState();
      if (!self.isFocused) {
        self.focus();
      }
    }

    /**
     * Set the active and last-active classes
     *
     */
    setActiveItemClass(item) {
      const self = this;
      const last_active = self.control.querySelector('.last-active');
      if (last_active) removeClasses(last_active, 'last-active');
      addClasses(item, 'active last-active');
      self.trigger('item_select', item);
      if (self.activeItems.indexOf(item) == -1) {
        self.activeItems.push(item);
      }
    }

    /**
     * Remove active item
     *
     */
    removeActiveItem(item) {
      var idx = this.activeItems.indexOf(item);
      this.activeItems.splice(idx, 1);
      removeClasses(item, 'active');
    }

    /**
     * Clears all the active items
     *
     */
    clearActiveItems() {
      removeClasses(this.activeItems, 'active');
      this.activeItems = [];
    }

    /**
     * Sets the selected item in the dropdown menu
     * of available options.
     *
     */
    setActiveOption(option, scroll = true) {
      if (option === this.activeOption) {
        return;
      }
      this.clearActiveOption();
      if (!option) return;
      this.activeOption = option;
      setAttr(this.focus_node, {
        'aria-activedescendant': option.getAttribute('id')
      });
      setAttr(option, {
        'aria-selected': 'true'
      });
      addClasses(option, 'active');
      if (scroll) this.scrollToOption(option);
    }

    /**
     * Sets the dropdown_content scrollTop to display the option
     *
     */
    scrollToOption(option, behavior) {
      if (!option) return;
      const content = this.dropdown_content;
      const height_menu = content.clientHeight;
      const scrollTop = content.scrollTop || 0;
      const height_item = option.offsetHeight;
      const y = option.getBoundingClientRect().top - content.getBoundingClientRect().top + scrollTop;
      if (y + height_item > height_menu + scrollTop) {
        this.scroll(y - height_menu + height_item, behavior);
      } else if (y < scrollTop) {
        this.scroll(y, behavior);
      }
    }

    /**
     * Scroll the dropdown to the given position
     *
     */
    scroll(scrollTop, behavior) {
      const content = this.dropdown_content;
      if (behavior) {
        content.style.scrollBehavior = behavior;
      }
      content.scrollTop = scrollTop;
      content.style.scrollBehavior = '';
    }

    /**
     * Clears the active option
     *
     */
    clearActiveOption() {
      if (this.activeOption) {
        removeClasses(this.activeOption, 'active');
        setAttr(this.activeOption, {
          'aria-selected': null
        });
      }
      this.activeOption = null;
      setAttr(this.focus_node, {
        'aria-activedescendant': null
      });
    }

    /**
     * Selects all items (CTRL + A).
     */
    selectAll() {
      const self = this;
      if (self.settings.mode === 'single') return;
      const activeItems = self.controlChildren();
      if (!activeItems.length) return;
      self.inputState();
      self.close();
      self.activeItems = activeItems;
      iterate$1(activeItems, item => {
        self.setActiveItemClass(item);
      });
    }

    /**
     * Determines if the control_input should be in a hidden or visible state
     *
     */
    inputState() {
      var self = this;
      if (!self.control.contains(self.control_input)) return;
      setAttr(self.control_input, {
        placeholder: self.settings.placeholder
      });
      if (self.activeItems.length > 0 || !self.isFocused && self.settings.hidePlaceholder && self.items.length > 0) {
        self.setTextboxValue();
        self.isInputHidden = true;
      } else {
        if (self.settings.hidePlaceholder && self.items.length > 0) {
          setAttr(self.control_input, {
            placeholder: ''
          });
        }
        self.isInputHidden = false;
      }
      self.wrapper.classList.toggle('input-hidden', self.isInputHidden);
    }

    /**
     * Get the input value
     */
    inputValue() {
      return this.control_input.value.trim();
    }

    /**
     * Gives the control focus.
     */
    focus() {
      var self = this;
      if (self.isDisabled || self.isReadOnly) return;
      self.ignoreFocus = true;
      if (self.control_input.offsetWidth) {
        self.control_input.focus();
      } else {
        self.focus_node.focus();
      }
      setTimeout(() => {
        self.ignoreFocus = false;
        self.onFocus();
      }, 0);
    }

    /**
     * Forces the control out of focus.
     *
     */
    blur() {
      this.focus_node.blur();
      this.onBlur();
    }

    /**
     * Returns a function that scores an object
     * to show how good of a match it is to the
     * provided query.
     *
     * @return {function}
     */
    getScoreFunction(query) {
      return this.sifter.getScoreFunction(query, this.getSearchOptions());
    }

    /**
     * Returns search options for sifter (the system
     * for scoring and sorting results).
     *
     * @see https://github.com/orchidjs/sifter.js
     * @return {object}
     */
    getSearchOptions() {
      var settings = this.settings;
      var sort = settings.sortField;
      if (typeof settings.sortField === 'string') {
        sort = [{
          field: settings.sortField
        }];
      }
      return {
        fields: settings.searchField,
        conjunction: settings.searchConjunction,
        sort: sort,
        nesting: settings.nesting
      };
    }

    /**
     * Searches through available options and returns
     * a sorted array of matches.
     *
     */
    search(query) {
      var result, calculateScore;
      var self = this;
      var options = this.getSearchOptions();

      // validate user-provided result scoring function
      if (self.settings.score) {
        calculateScore = self.settings.score.call(self, query);
        if (typeof calculateScore !== 'function') {
          throw new Error('Tom Select "score" setting must be a function that returns a function');
        }
      }

      // perform search
      if (query !== self.lastQuery) {
        self.lastQuery = query;
        result = self.sifter.search(query, Object.assign(options, {
          score: calculateScore
        }));
        self.currentResults = result;
      } else {
        result = Object.assign({}, self.currentResults);
      }

      // filter out selected items
      if (self.settings.hideSelected) {
        result.items = result.items.filter(item => {
          let hashed = hash_key(item.id);
          return !(hashed && self.items.indexOf(hashed) !== -1);
        });
      }
      return result;
    }

    /**
     * Refreshes the list of available options shown
     * in the autocomplete dropdown menu.
     *
     */
    refreshOptions(triggerDropdown = true) {
      var i, j, k, n, optgroup, optgroups, html, has_create_option, active_group;
      var create;
      const groups = {};
      const groups_order = [];
      var self = this;
      var query = self.inputValue();
      const same_query = query === self.lastQuery || query == '' && self.lastQuery == null;
      var results = self.search(query);
      var active_option = null;
      var show_dropdown = self.settings.shouldOpen || false;
      var dropdown_content = self.dropdown_content;
      if (same_query) {
        active_option = self.activeOption;
        if (active_option) {
          active_group = active_option.closest('[data-group]');
        }
      }

      // build markup
      n = results.items.length;
      if (typeof self.settings.maxOptions === 'number') {
        n = Math.min(n, self.settings.maxOptions);
      }
      if (n > 0) {
        show_dropdown = true;
      }

      // get fragment for group and the position of the group in group_order
      const getGroupFragment = (optgroup, order) => {
        let group_order_i = groups[optgroup];
        if (group_order_i !== undefined) {
          let order_group = groups_order[group_order_i];
          if (order_group !== undefined) {
            return [group_order_i, order_group.fragment];
          }
        }
        let group_fragment = document.createDocumentFragment();
        group_order_i = groups_order.length;
        groups_order.push({
          fragment: group_fragment,
          order,
          optgroup
        });
        return [group_order_i, group_fragment];
      };

      // render and group available options individually
      for (i = 0; i < n; i++) {
        // get option dom element
        let item = results.items[i];
        if (!item) continue;
        let opt_value = item.id;
        let option = self.options[opt_value];
        if (option === undefined) continue;
        let opt_hash = get_hash(opt_value);
        let option_el = self.getOption(opt_hash, true);

        // toggle 'selected' class
        if (!self.settings.hideSelected) {
          option_el.classList.toggle('selected', self.items.includes(opt_hash));
        }
        optgroup = option[self.settings.optgroupField] || '';
        optgroups = Array.isArray(optgroup) ? optgroup : [optgroup];
        for (j = 0, k = optgroups && optgroups.length; j < k; j++) {
          optgroup = optgroups[j];
          let order = option.$order;
          let self_optgroup = self.optgroups[optgroup];
          if (self_optgroup === undefined) {
            optgroup = '';
          } else {
            order = self_optgroup.$order;
          }
          const [group_order_i, group_fragment] = getGroupFragment(optgroup, order);

          // nodes can only have one parent, so if the option is in mutple groups, we need a clone
          if (j > 0) {
            option_el = option_el.cloneNode(true);
            setAttr(option_el, {
              id: option.$id + '-clone-' + j,
              'aria-selected': null
            });
            option_el.classList.add('ts-cloned');
            removeClasses(option_el, 'active');

            // make sure we keep the activeOption in the same group
            if (self.activeOption && self.activeOption.dataset.value == opt_value) {
              if (active_group && active_group.dataset.group === optgroup.toString()) {
                active_option = option_el;
              }
            }
          }
          group_fragment.appendChild(option_el);
          if (optgroup != '') {
            groups[optgroup] = group_order_i;
          }
        }
      }

      // sort optgroups
      if (self.settings.lockOptgroupOrder) {
        groups_order.sort((a, b) => {
          return a.order - b.order;
        });
      }

      // render optgroup headers & join groups
      html = document.createDocumentFragment();
      iterate$1(groups_order, group_order => {
        let group_fragment = group_order.fragment;
        let optgroup = group_order.optgroup;
        if (!group_fragment || !group_fragment.children.length) return;
        let group_heading = self.optgroups[optgroup];
        if (group_heading !== undefined) {
          let group_options = document.createDocumentFragment();
          let header = self.render('optgroup_header', group_heading);
          append(group_options, header);
          append(group_options, group_fragment);
          let group_html = self.render('optgroup', {
            group: group_heading,
            options: group_options
          });
          append(html, group_html);
        } else {
          append(html, group_fragment);
        }
      });
      dropdown_content.innerHTML = '';
      append(dropdown_content, html);

      // highlight matching terms inline
      if (self.settings.highlight) {
        removeHighlight(dropdown_content);
        if (results.query.length && results.tokens.length) {
          iterate$1(results.tokens, tok => {
            highlight(dropdown_content, tok.regex);
          });
        }
      }

      // helper method for adding templates to dropdown
      var add_template = template => {
        let content = self.render(template, {
          input: query
        });
        if (content) {
          show_dropdown = true;
          dropdown_content.insertBefore(content, dropdown_content.firstChild);
        }
        return content;
      };

      // add loading message
      if (self.loading) {
        add_template('loading');

        // invalid query
      } else if (!self.settings.shouldLoad.call(self, query)) {
        add_template('not_loading');

        // add no_results message
      } else if (results.items.length === 0) {
        add_template('no_results');
      }

      // add create option
      has_create_option = self.canCreate(query);
      if (has_create_option) {
        create = add_template('option_create');
      }

      // activate
      self.hasOptions = results.items.length > 0 || has_create_option;
      if (show_dropdown) {
        if (results.items.length > 0) {
          if (!active_option && self.settings.mode === 'single' && self.items[0] != undefined) {
            active_option = self.getOption(self.items[0]);
          }
          if (!dropdown_content.contains(active_option)) {
            let active_index = 0;
            if (create && !self.settings.addPrecedence) {
              active_index = 1;
            }
            active_option = self.selectable()[active_index];
          }
        } else if (create) {
          active_option = create;
        }
        if (triggerDropdown && !self.isOpen) {
          self.open();
          self.scrollToOption(active_option, 'auto');
        }
        self.setActiveOption(active_option);
      } else {
        self.clearActiveOption();
        if (triggerDropdown && self.isOpen) {
          self.close(false); // if create_option=null, we want the dropdown to close but not reset the textbox value
        }
      }
    }

    /**
     * Return list of selectable options
     *
     */
    selectable() {
      return this.dropdown_content.querySelectorAll('[data-selectable]');
    }

    /**
     * Adds an available option. If it already exists,
     * nothing will happen. Note: this does not refresh
     * the options list dropdown (use `refreshOptions`
     * for that).
     *
     * Usage:
     *
     *   this.addOption(data)
     *
     */
    addOption(data, user_created = false) {
      const self = this;

      // @deprecated 1.7.7
      // use addOptions( array, user_created ) for adding multiple options
      if (Array.isArray(data)) {
        self.addOptions(data, user_created);
        return false;
      }
      const key = hash_key(data[self.settings.valueField]);
      if (key === null || self.options.hasOwnProperty(key)) {
        return false;
      }
      data.$order = data.$order || ++self.order;
      data.$id = self.inputId + '-opt-' + data.$order;
      self.options[key] = data;
      self.lastQuery = null;
      if (user_created) {
        self.userOptions[key] = user_created;
        self.trigger('option_add', key, data);
      }
      return key;
    }

    /**
     * Add multiple options
     *
     */
    addOptions(data, user_created = false) {
      iterate$1(data, dat => {
        this.addOption(dat, user_created);
      });
    }

    /**
     * @deprecated 1.7.7
     */
    registerOption(data) {
      return this.addOption(data);
    }

    /**
     * Registers an option group to the pool of option groups.
     *
     * @return {boolean|string}
     */
    registerOptionGroup(data) {
      var key = hash_key(data[this.settings.optgroupValueField]);
      if (key === null) return false;
      data.$order = data.$order || ++this.order;
      this.optgroups[key] = data;
      return key;
    }

    /**
     * Registers a new optgroup for options
     * to be bucketed into.
     *
     */
    addOptionGroup(id, data) {
      var hashed_id;
      data[this.settings.optgroupValueField] = id;
      if (hashed_id = this.registerOptionGroup(data)) {
        this.trigger('optgroup_add', hashed_id, data);
      }
    }

    /**
     * Removes an existing option group.
     *
     */
    removeOptionGroup(id) {
      if (this.optgroups.hasOwnProperty(id)) {
        delete this.optgroups[id];
        this.clearCache();
        this.trigger('optgroup_remove', id);
      }
    }

    /**
     * Clears all existing option groups.
     */
    clearOptionGroups() {
      this.optgroups = {};
      this.clearCache();
      this.trigger('optgroup_clear');
    }

    /**
     * Updates an option available for selection. If
     * it is visible in the selected items or options
     * dropdown, it will be re-rendered automatically.
     *
     */
    updateOption(value, data) {
      const self = this;
      var item_new;
      var index_item;
      const value_old = hash_key(value);
      const value_new = hash_key(data[self.settings.valueField]);

      // sanity checks
      if (value_old === null) return;
      const data_old = self.options[value_old];
      if (data_old == undefined) return;
      if (typeof value_new !== 'string') throw new Error('Value must be set in option data');
      const option = self.getOption(value_old);
      const item = self.getItem(value_old);
      data.$order = data.$order || data_old.$order;
      delete self.options[value_old];

      // invalidate render cache
      // don't remove existing node yet, we'll remove it after replacing it
      self.uncacheValue(value_new);
      self.options[value_new] = data;

      // update the option if it's in the dropdown
      if (option) {
        if (self.dropdown_content.contains(option)) {
          const option_new = self._render('option', data);
          replaceNode(option, option_new);
          if (self.activeOption === option) {
            self.setActiveOption(option_new);
          }
        }
        option.remove();
      }

      // update the item if we have one
      if (item) {
        index_item = self.items.indexOf(value_old);
        if (index_item !== -1) {
          self.items.splice(index_item, 1, value_new);
        }
        item_new = self._render('item', data);
        if (item.classList.contains('active')) addClasses(item_new, 'active');
        replaceNode(item, item_new);
      }

      // invalidate last query because we might have updated the sortField
      self.lastQuery = null;
    }

    /**
     * Removes a single option.
     *
     */
    removeOption(value, silent) {
      const self = this;
      value = get_hash(value);
      self.uncacheValue(value);
      delete self.userOptions[value];
      delete self.options[value];
      self.lastQuery = null;
      self.trigger('option_remove', value);
      self.removeItem(value, silent);
    }

    /**
     * Clears all options.
     */
    clearOptions(filter) {
      const boundFilter = (filter || this.clearFilter).bind(this);
      this.loadedSearches = {};
      this.userOptions = {};
      this.clearCache();
      const selected = {};
      iterate$1(this.options, (option, key) => {
        if (boundFilter(option, key)) {
          selected[key] = option;
        }
      });
      this.options = this.sifter.items = selected;
      this.lastQuery = null;
      this.trigger('option_clear');
    }

    /**
     * Used by clearOptions() to decide whether or not an option should be removed
     * Return true to keep an option, false to remove
     *
     */
    clearFilter(option, value) {
      if (this.items.indexOf(value) >= 0) {
        return true;
      }
      return false;
    }

    /**
     * Returns the dom element of the option
     * matching the given value.
     *
     */
    getOption(value, create = false) {
      const hashed = hash_key(value);
      if (hashed === null) return null;
      const option = this.options[hashed];
      if (option != undefined) {
        if (option.$div) {
          return option.$div;
        }
        if (create) {
          return this._render('option', option);
        }
      }
      return null;
    }

    /**
     * Returns the dom element of the next or previous dom element of the same type
     * Note: adjacent options may not be adjacent DOM elements (optgroups)
     *
     */
    getAdjacent(option, direction, type = 'option') {
      var self = this,
        all;
      if (!option) {
        return null;
      }
      if (type == 'item') {
        all = self.controlChildren();
      } else {
        all = self.dropdown_content.querySelectorAll('[data-selectable]');
      }
      for (let i = 0; i < all.length; i++) {
        if (all[i] != option) {
          continue;
        }
        if (direction > 0) {
          return all[i + 1];
        }
        return all[i - 1];
      }
      return null;
    }

    /**
     * Returns the dom element of the item
     * matching the given value.
     *
     */
    getItem(item) {
      if (typeof item == 'object') {
        return item;
      }
      var value = hash_key(item);
      return value !== null ? this.control.querySelector(`[data-value="${addSlashes(value)}"]`) : null;
    }

    /**
     * "Selects" multiple items at once. Adds them to the list
     * at the current caret position.
     *
     */
    addItems(values, silent) {
      var self = this;
      var items = Array.isArray(values) ? values : [values];
      items = items.filter(x => self.items.indexOf(x) === -1);
      const last_item = items[items.length - 1];
      items.forEach(item => {
        self.isPending = item !== last_item;
        self.addItem(item, silent);
      });
    }

    /**
     * "Selects" an item. Adds it to the list
     * at the current caret position.
     *
     */
    addItem(value, silent) {
      var events = silent ? [] : ['change', 'dropdown_close'];
      debounce_events(this, events, () => {
        var item, wasFull;
        const self = this;
        const inputMode = self.settings.mode;
        const hashed = hash_key(value);
        if (hashed && self.items.indexOf(hashed) !== -1) {
          if (inputMode === 'single') {
            self.close();
          }
          if (inputMode === 'single' || !self.settings.duplicates) {
            return;
          }
        }
        if (hashed === null || !self.options.hasOwnProperty(hashed)) return;
        if (inputMode === 'single') self.clear(silent);
        if (inputMode === 'multi' && self.isFull()) return;
        item = self._render('item', self.options[hashed]);
        if (self.control.contains(item)) {
          // duplicates
          item = item.cloneNode(true);
        }
        wasFull = self.isFull();
        self.items.splice(self.caretPos, 0, hashed);
        self.insertAtCaret(item);
        if (self.isSetup) {
          // update menu / remove the option (if this is not one item being added as part of series)
          if (!self.isPending && self.settings.hideSelected) {
            let option = self.getOption(hashed);
            let next = self.getAdjacent(option, 1);
            if (next) {
              self.setActiveOption(next);
            }
          }

          // refreshOptions after setActiveOption(),
          // otherwise setActiveOption() will be called by refreshOptions() with the wrong value
          if (!self.isPending && !self.settings.closeAfterSelect) {
            self.refreshOptions(self.isFocused && inputMode !== 'single');
          }

          // hide the menu if the maximum number of items have been selected or no options are left
          if (self.settings.closeAfterSelect != false && self.isFull()) {
            self.close();
          } else if (!self.isPending) {
            self.positionDropdown();
          }
          self.trigger('item_add', hashed, item);
          if (!self.isPending) {
            self.updateOriginalInput({
              silent: silent
            });
          }
        }
        if (!self.isPending || !wasFull && self.isFull()) {
          self.inputState();
          self.refreshState();
        }
      });
    }

    /**
     * Removes the selected item matching
     * the provided value.
     *
     */
    removeItem(item = null, silent) {
      const self = this;
      item = self.getItem(item);
      if (!item) return;
      var i, idx;
      const value = item.dataset.value;
      i = nodeIndex(item);
      item.remove();
      if (item.classList.contains('active')) {
        idx = self.activeItems.indexOf(item);
        self.activeItems.splice(idx, 1);
        removeClasses(item, 'active');
      }
      self.items.splice(i, 1);
      self.lastQuery = null;
      if (!self.settings.persist && self.userOptions.hasOwnProperty(value)) {
        self.removeOption(value, silent);
      }
      if (i < self.caretPos) {
        self.setCaret(self.caretPos - 1);
      }
      self.updateOriginalInput({
        silent: silent
      });
      self.refreshState();
      self.positionDropdown();
      self.trigger('item_remove', value, item);
    }

    /**
     * Invokes the `create` method provided in the
     * TomSelect options that should provide the data
     * for the new item, given the user input.
     *
     * Once this completes, it will be added
     * to the item list.
     *
     */
    createItem(input = null, callback = () => {}) {
      // triggerDropdown parameter @deprecated 2.1.1
      if (arguments.length === 3) {
        callback = arguments[2];
      }
      if (typeof callback != 'function') {
        callback = () => {};
      }
      var self = this;
      var caret = self.caretPos;
      var output;
      input = input || self.inputValue();
      if (!self.canCreate(input)) {
        callback();
        return false;
      }
      self.lock();
      var created = false;
      var create = data => {
        self.unlock();
        if (!data || typeof data !== 'object') return callback();
        var value = hash_key(data[self.settings.valueField]);
        if (typeof value !== 'string') {
          return callback();
        }
        self.setTextboxValue();
        self.addOption(data, true);
        self.setCaret(caret);
        self.addItem(value);
        callback(data);
        created = true;
      };
      if (typeof self.settings.create === 'function') {
        output = self.settings.create.call(this, input, create);
      } else {
        output = {
          [self.settings.labelField]: input,
          [self.settings.valueField]: input
        };
      }
      if (!created) {
        create(output);
      }
      return true;
    }

    /**
     * Re-renders the selected item lists.
     */
    refreshItems() {
      var self = this;
      self.lastQuery = null;
      if (self.isSetup) {
        self.addItems(self.items);
      }
      self.updateOriginalInput();
      self.refreshState();
    }

    /**
     * Updates all state-dependent attributes
     * and CSS classes.
     */
    refreshState() {
      const self = this;
      self.refreshValidityState();
      const isFull = self.isFull();
      const isLocked = self.isLocked;
      self.wrapper.classList.toggle('rtl', self.rtl);
      const wrap_classList = self.wrapper.classList;
      wrap_classList.toggle('focus', self.isFocused);
      wrap_classList.toggle('disabled', self.isDisabled);
      wrap_classList.toggle('readonly', self.isReadOnly);
      wrap_classList.toggle('required', self.isRequired);
      wrap_classList.toggle('invalid', !self.isValid);
      wrap_classList.toggle('locked', isLocked);
      wrap_classList.toggle('full', isFull);
      wrap_classList.toggle('input-active', self.isFocused && !self.isInputHidden);
      wrap_classList.toggle('dropdown-active', self.isOpen);
      wrap_classList.toggle('has-options', isEmptyObject(self.options));
      wrap_classList.toggle('has-items', self.items.length > 0);
    }

    /**
     * Update the `required` attribute of both input and control input.
     *
     * The `required` property needs to be activated on the control input
     * for the error to be displayed at the right place. `required` also
     * needs to be temporarily deactivated on the input since the input is
     * hidden and can't show errors.
     */
    refreshValidityState() {
      var self = this;
      if (!self.input.validity) {
        return;
      }
      self.isValid = self.input.validity.valid;
      self.isInvalid = !self.isValid;
    }

    /**
     * Determines whether or not more items can be added
     * to the control without exceeding the user-defined maximum.
     *
     * @returns {boolean}
     */
    isFull() {
      return this.settings.maxItems !== null && this.items.length >= this.settings.maxItems;
    }

    /**
     * Refreshes the original <select> or <input>
     * element to reflect the current state.
     *
     */
    updateOriginalInput(opts = {}) {
      const self = this;
      var option, label;
      const empty_option = self.input.querySelector('option[value=""]');
      if (self.is_select_tag) {
        const selected = [];
        const has_selected = self.input.querySelectorAll('option:checked').length;
        function AddSelected(option_el, value, label) {
          if (!option_el) {
            option_el = getDom('<option value="' + escape_html(value) + '">' + escape_html(label) + '</option>');
          }

          // don't move empty option from top of list
          // fixes bug in firefox https://bugzilla.mozilla.org/show_bug.cgi?id=1725293
          if (option_el != empty_option) {
            self.input.append(option_el);
          }
          selected.push(option_el);

          // marking empty option as selected can break validation
          // fixes https://github.com/orchidjs/tom-select/issues/303
          if (option_el != empty_option || has_selected > 0) {
            option_el.selected = true;
          }
          return option_el;
        }

        // unselect all selected options
        self.input.querySelectorAll('option:checked').forEach(option_el => {
          option_el.selected = false;
        });

        // nothing selected?
        if (self.items.length == 0 && self.settings.mode == 'single') {
          AddSelected(empty_option, "", "");

          // order selected <option> tags for values in self.items
        } else {
          self.items.forEach(value => {
            option = self.options[value];
            label = option[self.settings.labelField] || '';
            if (selected.includes(option.$option)) {
              const reuse_opt = self.input.querySelector(`option[value="${addSlashes(value)}"]:not(:checked)`);
              AddSelected(reuse_opt, value, label);
            } else {
              option.$option = AddSelected(option.$option, value, label);
            }
          });
        }
      } else {
        self.input.value = self.getValue();
      }
      if (self.isSetup) {
        if (!opts.silent) {
          self.trigger('change', self.getValue());
        }
      }
    }

    /**
     * Shows the autocomplete dropdown containing
     * the available options.
     */
    open() {
      var self = this;
      if (self.isLocked || self.isOpen || self.settings.mode === 'multi' && self.isFull()) return;
      self.isOpen = true;
      setAttr(self.focus_node, {
        'aria-expanded': 'true'
      });
      self.refreshState();
      applyCSS(self.dropdown, {
        visibility: 'hidden',
        display: 'block'
      });
      self.positionDropdown();
      applyCSS(self.dropdown, {
        visibility: 'visible',
        display: 'block'
      });
      self.focus();
      self.trigger('dropdown_open', self.dropdown);
    }

    /**
     * Closes the autocomplete dropdown menu.
     */
    close(setTextboxValue = true) {
      var self = this;
      var trigger = self.isOpen;
      if (setTextboxValue) {
        // before blur() to prevent form onchange event
        self.setTextboxValue();
        if (self.settings.mode === 'single' && self.items.length) {
          self.inputState();
        }
      }
      self.isOpen = false;
      setAttr(self.focus_node, {
        'aria-expanded': 'false'
      });
      applyCSS(self.dropdown, {
        display: 'none'
      });
      if (self.settings.hideSelected) {
        self.clearActiveOption();
      }
      self.refreshState();
      if (trigger) self.trigger('dropdown_close', self.dropdown);
    }

    /**
     * Calculates and applies the appropriate
     * position of the dropdown if dropdownParent = 'body'.
     * Otherwise, position is determined by css
     */
    positionDropdown() {
      if (this.settings.dropdownParent !== 'body') {
        return;
      }
      var context = this.control;
      var rect = context.getBoundingClientRect();
      var top = context.offsetHeight + rect.top + window.scrollY;
      var left = rect.left + window.scrollX;
      applyCSS(this.dropdown, {
        width: rect.width + 'px',
        top: top + 'px',
        left: left + 'px'
      });
    }

    /**
     * Resets / clears all selected items
     * from the control.
     *
     */
    clear(silent) {
      var self = this;
      if (!self.items.length) return;
      var items = self.controlChildren();
      iterate$1(items, item => {
        self.removeItem(item, true);
      });
      self.inputState();
      if (!silent) self.updateOriginalInput();
      self.trigger('clear');
    }

    /**
     * A helper method for inserting an element
     * at the current caret position.
     *
     */
    insertAtCaret(el) {
      const self = this;
      const caret = self.caretPos;
      const target = self.control;
      target.insertBefore(el, target.children[caret] || null);
      self.setCaret(caret + 1);
    }

    /**
     * Removes the current selected item(s).
     *
     */
    deleteSelection(e) {
      var direction, selection, caret, tail;
      var self = this;
      direction = e && e.keyCode === KEY_BACKSPACE ? -1 : 1;
      selection = getSelection(self.control_input);

      // determine items that will be removed
      const rm_items = [];
      if (self.activeItems.length) {
        tail = getTail(self.activeItems, direction);
        caret = nodeIndex(tail);
        if (direction > 0) {
          caret++;
        }
        iterate$1(self.activeItems, item => rm_items.push(item));
      } else if ((self.isFocused || self.settings.mode === 'single') && self.items.length) {
        const items = self.controlChildren();
        let rm_item;
        if (direction < 0 && selection.start === 0 && selection.length === 0) {
          rm_item = items[self.caretPos - 1];
        } else if (direction > 0 && selection.start === self.inputValue().length) {
          rm_item = items[self.caretPos];
        }
        if (rm_item !== undefined) {
          rm_items.push(rm_item);
        }
      }
      if (!self.shouldDelete(rm_items, e)) {
        return false;
      }
      preventDefault(e, true);

      // perform removal
      if (typeof caret !== 'undefined') {
        self.setCaret(caret);
      }
      while (rm_items.length) {
        self.removeItem(rm_items.pop());
      }
      self.inputState();
      self.positionDropdown();
      self.refreshOptions(false);
      return true;
    }

    /**
     * Return true if the items should be deleted
     */
    shouldDelete(items, evt) {
      const values = items.map(item => item.dataset.value);

      // allow the callback to abort
      if (!values.length || typeof this.settings.onDelete === 'function' && this.settings.onDelete(values, evt) === false) {
        return false;
      }
      return true;
    }

    /**
     * Selects the previous / next item (depending on the `direction` argument).
     *
     * > 0 - right
     * < 0 - left
     *
     */
    advanceSelection(direction, e) {
      var last_active,
        adjacent,
        self = this;
      if (self.rtl) direction *= -1;
      if (self.inputValue().length) return;

      // add or remove to active items
      if (isKeyDown(KEY_SHORTCUT, e) || isKeyDown('shiftKey', e)) {
        last_active = self.getLastActive(direction);
        if (last_active) {
          if (!last_active.classList.contains('active')) {
            adjacent = last_active;
          } else {
            adjacent = self.getAdjacent(last_active, direction, 'item');
          }

          // if no active item, get items adjacent to the control input
        } else if (direction > 0) {
          adjacent = self.control_input.nextElementSibling;
        } else {
          adjacent = self.control_input.previousElementSibling;
        }
        if (adjacent) {
          if (adjacent.classList.contains('active')) {
            self.removeActiveItem(last_active);
          }
          self.setActiveItemClass(adjacent); // mark as last_active !! after removeActiveItem() on last_active
        }

        // move caret to the left or right
      } else {
        self.moveCaret(direction);
      }
    }
    moveCaret(direction) {}

    /**
     * Get the last active item
     *
     */
    getLastActive(direction) {
      let last_active = this.control.querySelector('.last-active');
      if (last_active) {
        return last_active;
      }
      var result = this.control.querySelectorAll('.active');
      if (result) {
        return getTail(result, direction);
      }
    }

    /**
     * Moves the caret to the specified index.
     *
     * The input must be moved by leaving it in place and moving the
     * siblings, due to the fact that focus cannot be restored once lost
     * on mobile webkit devices
     *
     */
    setCaret(new_pos) {
      this.caretPos = this.items.length;
    }

    /**
     * Return list of item dom elements
     *
     */
    controlChildren() {
      return Array.from(this.control.querySelectorAll('[data-ts-item]'));
    }

    /**
     * Disables user input on the control. Used while
     * items are being asynchronously created.
     */
    lock() {
      this.setLocked(true);
    }

    /**
     * Re-enables user input on the control.
     */
    unlock() {
      this.setLocked(false);
    }

    /**
     * Disable or enable user input on the control
     */
    setLocked(lock = this.isReadOnly || this.isDisabled) {
      this.isLocked = lock;
      this.refreshState();
    }

    /**
     * Disables user input on the control completely.
     * While disabled, it cannot receive focus.
     */
    disable() {
      this.setDisabled(true);
      this.close();
    }

    /**
     * Enables the control so that it can respond
     * to focus and user input.
     */
    enable() {
      this.setDisabled(false);
    }
    setDisabled(disabled) {
      this.focus_node.tabIndex = disabled ? -1 : this.tabIndex;
      this.isDisabled = disabled;
      this.input.disabled = disabled;
      this.control_input.disabled = disabled;
      this.setLocked();
    }
    setReadOnly(isReadOnly) {
      this.isReadOnly = isReadOnly;
      this.input.readOnly = isReadOnly;
      this.control_input.readOnly = isReadOnly;
      this.setLocked();
    }

    /**
     * Completely destroys the control and
     * unbinds all event listeners so that it can
     * be garbage collected.
     */
    destroy() {
      var self = this;
      var revertSettings = self.revertSettings;
      self.trigger('destroy');
      self.off();
      self.wrapper.remove();
      self.dropdown.remove();
      self.input.innerHTML = revertSettings.innerHTML;
      self.input.tabIndex = revertSettings.tabIndex;
      removeClasses(self.input, 'tomselected', 'ts-hidden-accessible');
      self._destroy();
      delete self.input.tomselect;
    }

    /**
     * A helper method for rendering "item" and
     * "option" templates, given the data.
     *
     */
    render(templateName, data) {
      var id, html;
      const self = this;
      if (typeof this.settings.render[templateName] !== 'function') {
        return null;
      }

      // render markup
      html = self.settings.render[templateName].call(this, data, escape_html);
      if (!html) {
        return null;
      }
      html = getDom(html);

      // add mandatory attributes
      if (templateName === 'option' || templateName === 'option_create') {
        if (data[self.settings.disabledField]) {
          setAttr(html, {
            'aria-disabled': 'true'
          });
        } else {
          setAttr(html, {
            'data-selectable': ''
          });
        }
      } else if (templateName === 'optgroup') {
        id = data.group[self.settings.optgroupValueField];
        setAttr(html, {
          'data-group': id
        });
        if (data.group[self.settings.disabledField]) {
          setAttr(html, {
            'data-disabled': ''
          });
        }
      }
      if (templateName === 'option' || templateName === 'item') {
        const value = get_hash(data[self.settings.valueField]);
        setAttr(html, {
          'data-value': value
        });

        // make sure we have some classes if a template is overwritten
        if (templateName === 'item') {
          addClasses(html, self.settings.itemClass);
          setAttr(html, {
            'data-ts-item': ''
          });
        } else {
          addClasses(html, self.settings.optionClass);
          setAttr(html, {
            role: 'option',
            id: data.$id
          });

          // update cache
          data.$div = html;
          self.options[value] = data;
        }
      }
      return html;
    }

    /**
     * Type guarded rendering
     *
     */
    _render(templateName, data) {
      const html = this.render(templateName, data);
      if (html == null) {
        throw 'HTMLElement expected';
      }
      return html;
    }

    /**
     * Clears the render cache for a template. If
     * no template is given, clears all render
     * caches.
     *
     */
    clearCache() {
      iterate$1(this.options, option => {
        if (option.$div) {
          option.$div.remove();
          delete option.$div;
        }
      });
    }

    /**
     * Removes a value from item and option caches
     *
     */
    uncacheValue(value) {
      const option_el = this.getOption(value);
      if (option_el) option_el.remove();
    }

    /**
     * Determines whether or not to display the
     * create item prompt, given a user input.
     *
     */
    canCreate(input) {
      return this.settings.create && input.length > 0 && this.settings.createFilter.call(this, input);
    }

    /**
     * Wraps this.`method` so that `new_fn` can be invoked 'before', 'after', or 'instead' of the original method
     *
     * this.hook('instead','onKeyDown',function( arg1, arg2 ...){
     *
     * });
     */
    hook(when, method, new_fn) {
      var self = this;
      var orig_method = self[method];
      self[method] = function () {
        var result, result_new;
        if (when === 'after') {
          result = orig_method.apply(self, arguments);
        }
        result_new = new_fn.apply(self, arguments);
        if (when === 'instead') {
          return result_new;
        }
        if (when === 'before') {
          result = orig_method.apply(self, arguments);
        }
        return result;
      };
    }
  }

  /**
   * Plugin: "change_listener" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function change_listener () {
    addEvent(this.input, 'change', () => {
      this.sync();
    });
  }

  /**
   * Plugin: "checkbox_options" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function checkbox_options (userOptions) {
    var self = this;
    var orig_onOptionSelect = self.onOptionSelect;
    self.settings.hideSelected = false;
    const cbOptions = Object.assign({
      // so that the user may add different ones as well
      className: "tomselect-checkbox",
      // the following default to the historic plugin's values
      checkedClassNames: undefined,
      uncheckedClassNames: undefined
    }, userOptions);
    var UpdateChecked = function UpdateChecked(checkbox, toCheck) {
      if (toCheck) {
        checkbox.checked = true;
        if (cbOptions.uncheckedClassNames) {
          checkbox.classList.remove(...cbOptions.uncheckedClassNames);
        }
        if (cbOptions.checkedClassNames) {
          checkbox.classList.add(...cbOptions.checkedClassNames);
        }
      } else {
        checkbox.checked = false;
        if (cbOptions.checkedClassNames) {
          checkbox.classList.remove(...cbOptions.checkedClassNames);
        }
        if (cbOptions.uncheckedClassNames) {
          checkbox.classList.add(...cbOptions.uncheckedClassNames);
        }
      }
    };

    // update the checkbox for an option
    var UpdateCheckbox = function UpdateCheckbox(option) {
      setTimeout(() => {
        var checkbox = option.querySelector('input.' + cbOptions.className);
        if (checkbox instanceof HTMLInputElement) {
          UpdateChecked(checkbox, option.classList.contains('selected'));
        }
      }, 1);
    };

    // add checkbox to option template
    self.hook('after', 'setupTemplates', () => {
      var orig_render_option = self.settings.render.option;
      self.settings.render.option = (data, escape_html) => {
        var rendered = getDom(orig_render_option.call(self, data, escape_html));
        var checkbox = document.createElement('input');
        if (cbOptions.className) {
          checkbox.classList.add(cbOptions.className);
        }
        checkbox.addEventListener('click', function (evt) {
          preventDefault(evt);
        });
        checkbox.type = 'checkbox';
        const hashed = hash_key(data[self.settings.valueField]);
        UpdateChecked(checkbox, !!(hashed && self.items.indexOf(hashed) > -1));
        rendered.prepend(checkbox);
        return rendered;
      };
    });

    // uncheck when item removed
    self.on('item_remove', value => {
      var option = self.getOption(value);
      if (option) {
        // if dropdown hasn't been opened yet, the option won't exist
        option.classList.remove('selected'); // selected class won't be removed yet
        UpdateCheckbox(option);
      }
    });

    // check when item added
    self.on('item_add', value => {
      var option = self.getOption(value);
      if (option) {
        // if dropdown hasn't been opened yet, the option won't exist
        UpdateCheckbox(option);
      }
    });

    // remove items when selected option is clicked
    self.hook('instead', 'onOptionSelect', (evt, option) => {
      if (option.classList.contains('selected')) {
        option.classList.remove('selected');
        self.removeItem(option.dataset.value);
        self.refreshOptions();
        preventDefault(evt, true);
        return;
      }
      orig_onOptionSelect.call(self, evt, option);
      UpdateCheckbox(option);
    });
  }

  /**
   * Plugin: "dropdown_header" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function clear_button (userOptions) {
    const self = this;
    const options = Object.assign({
      className: 'clear-button',
      title: 'Clear All',
      html: data => {
        return `<div class="${data.className}" title="${data.title}">&#10799;</div>`;
      }
    }, userOptions);
    self.on('initialize', () => {
      var button = getDom(options.html(options));
      button.addEventListener('click', evt => {
        if (self.isLocked) return;
        self.clear();
        if (self.settings.mode === 'single' && self.settings.allowEmptyOption) {
          self.addItem('');
        }
        evt.preventDefault();
        evt.stopPropagation();
      });
      self.control.appendChild(button);
    });
  }

  /**
   * Plugin: "drag_drop" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  const insertAfter = (referenceNode, newNode) => {
    var _referenceNode$parent;
    (_referenceNode$parent = referenceNode.parentNode) == null || _referenceNode$parent.insertBefore(newNode, referenceNode.nextSibling);
  };
  const insertBefore = (referenceNode, newNode) => {
    var _referenceNode$parent2;
    (_referenceNode$parent2 = referenceNode.parentNode) == null || _referenceNode$parent2.insertBefore(newNode, referenceNode);
  };
  const isBefore = (referenceNode, newNode) => {
    do {
      var _newNode;
      newNode = (_newNode = newNode) == null ? void 0 : _newNode.previousElementSibling;
      if (referenceNode == newNode) {
        return true;
      }
    } while (newNode && newNode.previousElementSibling);
    return false;
  };
  function drag_drop () {
    var self = this;
    if (self.settings.mode !== 'multi') return;
    var orig_lock = self.lock;
    var orig_unlock = self.unlock;
    let sortable = true;
    let drag_item;

    /**
     * Add draggable attribute to item
     */
    self.hook('after', 'setupTemplates', () => {
      var orig_render_item = self.settings.render.item;
      self.settings.render.item = (data, escape) => {
        const item = getDom(orig_render_item.call(self, data, escape));
        setAttr(item, {
          'draggable': 'true'
        });

        // prevent doc_mousedown (see tom-select.ts)
        const mousedown = evt => {
          if (!sortable) preventDefault(evt);
          evt.stopPropagation();
        };
        const dragStart = evt => {
          drag_item = item;
          setTimeout(() => {
            item.classList.add('ts-dragging');
          }, 0);
        };
        const dragOver = evt => {
          evt.preventDefault();
          item.classList.add('ts-drag-over');
          moveitem(item, drag_item);
        };
        const dragLeave = () => {
          item.classList.remove('ts-drag-over');
        };
        const moveitem = (targetitem, dragitem) => {
          if (dragitem === undefined) return;
          if (isBefore(dragitem, item)) {
            insertAfter(targetitem, dragitem);
          } else {
            insertBefore(targetitem, dragitem);
          }
        };
        const dragend = () => {
          var _drag_item;
          document.querySelectorAll('.ts-drag-over').forEach(el => el.classList.remove('ts-drag-over'));
          (_drag_item = drag_item) == null || _drag_item.classList.remove('ts-dragging');
          drag_item = undefined;
          var values = [];
          self.control.querySelectorAll(`[data-value]`).forEach(el => {
            if (el.dataset.value) {
              let value = el.dataset.value;
              if (value) {
                values.push(value);
              }
            }
          });
          self.setValue(values);
        };
        addEvent(item, 'mousedown', mousedown);
        addEvent(item, 'dragstart', dragStart);
        addEvent(item, 'dragenter', dragOver);
        addEvent(item, 'dragover', dragOver);
        addEvent(item, 'dragleave', dragLeave);
        addEvent(item, 'dragend', dragend);
        return item;
      };
    });
    self.hook('instead', 'lock', () => {
      sortable = false;
      return orig_lock.call(self);
    });
    self.hook('instead', 'unlock', () => {
      sortable = true;
      return orig_unlock.call(self);
    });
  }

  /**
   * Plugin: "dropdown_header" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function dropdown_header (userOptions) {
    const self = this;
    const options = Object.assign({
      title: 'Untitled',
      headerClass: 'dropdown-header',
      titleRowClass: 'dropdown-header-title',
      labelClass: 'dropdown-header-label',
      closeClass: 'dropdown-header-close',
      html: data => {
        return '<div class="' + data.headerClass + '">' + '<div class="' + data.titleRowClass + '">' + '<span class="' + data.labelClass + '">' + data.title + '</span>' + '<a class="' + data.closeClass + '">&times;</a>' + '</div>' + '</div>';
      }
    }, userOptions);
    self.on('initialize', () => {
      var header = getDom(options.html(options));
      var close_link = header.querySelector('.' + options.closeClass);
      if (close_link) {
        close_link.addEventListener('click', evt => {
          preventDefault(evt, true);
          self.close();
        });
      }
      self.dropdown.insertBefore(header, self.dropdown.firstChild);
    });
  }

  /**
   * Plugin: "dropdown_input" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function caret_position () {
    var self = this;

    /**
     * Moves the caret to the specified index.
     *
     * The input must be moved by leaving it in place and moving the
     * siblings, due to the fact that focus cannot be restored once lost
     * on mobile webkit devices
     *
     */
    self.hook('instead', 'setCaret', new_pos => {
      if (self.settings.mode === 'single' || !self.control.contains(self.control_input)) {
        new_pos = self.items.length;
      } else {
        new_pos = Math.max(0, Math.min(self.items.length, new_pos));
        if (new_pos != self.caretPos && !self.isPending) {
          self.controlChildren().forEach((child, j) => {
            if (j < new_pos) {
              self.control_input.insertAdjacentElement('beforebegin', child);
            } else {
              self.control.appendChild(child);
            }
          });
        }
      }
      self.caretPos = new_pos;
    });
    self.hook('instead', 'moveCaret', direction => {
      if (!self.isFocused) return;

      // move caret before or after selected items
      const last_active = self.getLastActive(direction);
      if (last_active) {
        const idx = nodeIndex(last_active);
        self.setCaret(direction > 0 ? idx + 1 : idx);
        self.setActiveItem();
        removeClasses(last_active, 'last-active');

        // move caret left or right of current position
      } else {
        self.setCaret(self.caretPos + direction);
      }
    });
  }

  /**
   * Plugin: "dropdown_input" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function dropdown_input () {
    const self = this;
    self.settings.shouldOpen = true; // make sure the input is shown even if there are no options to display in the dropdown

    self.hook('before', 'setup', () => {
      self.focus_node = self.control;
      addClasses(self.control_input, 'dropdown-input');
      const div = getDom('<div class="dropdown-input-wrap">');
      div.append(self.control_input);
      self.dropdown.insertBefore(div, self.dropdown.firstChild);

      // set a placeholder in the select control
      const placeholder = getDom('<input class="items-placeholder" tabindex="-1" />');
      placeholder.placeholder = self.settings.placeholder || '';
      self.control.append(placeholder);
    });
    self.on('initialize', () => {
      // set tabIndex on control to -1, otherwise [shift+tab] will put focus right back on control_input
      self.control_input.addEventListener('keydown', evt => {
        //addEvent(self.control_input,'keydown' as const,(evt:KeyboardEvent) =>{
        switch (evt.keyCode) {
          case KEY_ESC:
            if (self.isOpen) {
              preventDefault(evt, true);
              self.close();
            }
            self.clearActiveItems();
            return;
          case KEY_TAB:
            self.focus_node.tabIndex = -1;
            break;
        }
        return self.onKeyDown.call(self, evt);
      });
      self.on('blur', () => {
        self.focus_node.tabIndex = self.isDisabled ? -1 : self.tabIndex;
      });

      // give the control_input focus when the dropdown is open
      self.on('dropdown_open', () => {
        self.control_input.focus();
      });

      // prevent onBlur from closing when focus is on the control_input
      const orig_onBlur = self.onBlur;
      self.hook('instead', 'onBlur', evt => {
        if (evt && evt.relatedTarget == self.control_input) return;
        return orig_onBlur.call(self);
      });
      addEvent(self.control_input, 'blur', () => self.onBlur());

      // return focus to control to allow further keyboard input
      self.hook('before', 'close', () => {
        if (!self.isOpen) return;
        self.focus_node.focus({
          preventScroll: true
        });
      });
    });
  }

  /**
   * Plugin: "input_autogrow" (Tom Select)
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function input_autogrow () {
    var self = this;
    self.on('initialize', () => {
      var test_input = document.createElement('span');
      var control = self.control_input;
      test_input.style.cssText = 'position:absolute; top:-99999px; left:-99999px; width:auto; padding:0; white-space:pre; ';
      self.wrapper.appendChild(test_input);
      var transfer_styles = ['letterSpacing', 'fontSize', 'fontFamily', 'fontWeight', 'textTransform'];
      for (const style_name of transfer_styles) {
        // @ts-ignore TS7015 https://stackoverflow.com/a/50506154/697576
        test_input.style[style_name] = control.style[style_name];
      }

      /**
       * Set the control width
       *
       */
      var resize = () => {
        test_input.textContent = control.value;
        control.style.width = test_input.clientWidth + 'px';
      };
      resize();
      self.on('update item_add item_remove', resize);
      addEvent(control, 'input', resize);
      addEvent(control, 'keyup', resize);
      addEvent(control, 'blur', resize);
      addEvent(control, 'update', resize);
    });
  }

  /**
   * Plugin: "input_autogrow" (Tom Select)
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function no_backspace_delete () {
    var self = this;
    var orig_deleteSelection = self.deleteSelection;
    this.hook('instead', 'deleteSelection', evt => {
      if (self.activeItems.length) {
        return orig_deleteSelection.call(self, evt);
      }
      return false;
    });
  }

  /**
   * Plugin: "no_active_items" (Tom Select)
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function no_active_items () {
    this.hook('instead', 'setActiveItem', () => {});
    this.hook('instead', 'selectAll', () => {});
  }

  /**
   * Plugin: "optgroup_columns" (Tom Select.js)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function optgroup_columns () {
    var self = this;
    var orig_keydown = self.onKeyDown;
    self.hook('instead', 'onKeyDown', evt => {
      var index, option, options, optgroup;
      if (!self.isOpen || !(evt.keyCode === KEY_LEFT || evt.keyCode === KEY_RIGHT)) {
        return orig_keydown.call(self, evt);
      }
      self.ignoreHover = true;
      optgroup = parentMatch(self.activeOption, '[data-group]');
      index = nodeIndex(self.activeOption, '[data-selectable]');
      if (!optgroup) {
        return;
      }
      if (evt.keyCode === KEY_LEFT) {
        optgroup = optgroup.previousSibling;
      } else {
        optgroup = optgroup.nextSibling;
      }
      if (!optgroup) {
        return;
      }
      options = optgroup.querySelectorAll('[data-selectable]');
      option = options[Math.min(options.length - 1, index)];
      if (option) {
        self.setActiveOption(option);
      }
    });
  }

  /**
   * Plugin: "remove_button" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function remove_button (userOptions) {
    const options = Object.assign({
      label: '&times;',
      title: 'Remove',
      className: 'remove',
      append: true
    }, userOptions);

    //options.className = 'remove-single';
    var self = this;

    // override the render method to add remove button to each item
    if (!options.append) {
      return;
    }
    var html = '<a href="javascript:void(0)" class="' + options.className + '" tabindex="-1" title="' + escape_html(options.title) + '">' + options.label + '</a>';
    self.hook('after', 'setupTemplates', () => {
      var orig_render_item = self.settings.render.item;
      self.settings.render.item = (data, escape) => {
        var item = getDom(orig_render_item.call(self, data, escape));
        var close_button = getDom(html);
        item.appendChild(close_button);
        addEvent(close_button, 'mousedown', evt => {
          preventDefault(evt, true);
        });
        addEvent(close_button, 'click', evt => {
          if (self.isLocked) return;

          // propagating will trigger the dropdown to show for single mode
          preventDefault(evt, true);
          if (self.isLocked) return;
          if (!self.shouldDelete([item], evt)) return;
          self.removeItem(item);
          self.refreshOptions(false);
          self.inputState();
        });
        return item;
      };
    });
  }

  /**
   * Plugin: "restore_on_backspace" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function restore_on_backspace (userOptions) {
    const self = this;
    const options = Object.assign({
      text: option => {
        return option[self.settings.labelField];
      }
    }, userOptions);
    self.on('item_remove', function (value) {
      if (!self.isFocused) {
        return;
      }
      if (self.control_input.value.trim() === '') {
        var option = self.options[value];
        if (option) {
          self.setTextboxValue(options.text.call(self, option));
        }
      }
    });
  }

  /**
   * Plugin: "restore_on_backspace" (Tom Select)
   * Copyright (c) contributors
   *
   * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   * file except in compliance with the License. You may obtain a copy of the License at:
   * http://www.apache.org/licenses/LICENSE-2.0
   *
   * Unless required by applicable law or agreed to in writing, software distributed under
   * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
   * ANY KIND, either express or implied. See the License for the specific language
   * governing permissions and limitations under the License.
   *
   */

  function virtual_scroll () {
    const self = this;
    const orig_canLoad = self.canLoad;
    const orig_clearActiveOption = self.clearActiveOption;
    const orig_loadCallback = self.loadCallback;
    var pagination = {};
    var dropdown_content;
    var loading_more = false;
    var load_more_opt;
    var default_values = [];
    if (!self.settings.shouldLoadMore) {
      // return true if additional results should be loaded
      self.settings.shouldLoadMore = () => {
        const scroll_percent = dropdown_content.clientHeight / (dropdown_content.scrollHeight - dropdown_content.scrollTop);
        if (scroll_percent > 0.9) {
          return true;
        }
        if (self.activeOption) {
          var selectable = self.selectable();
          var index = Array.from(selectable).indexOf(self.activeOption);
          if (index >= selectable.length - 2) {
            return true;
          }
        }
        return false;
      };
    }
    if (!self.settings.firstUrl) {
      throw 'virtual_scroll plugin requires a firstUrl() method';
    }

    // in order for virtual scrolling to work,
    // options need to be ordered the same way they're returned from the remote data source
    self.settings.sortField = [{
      field: '$order'
    }, {
      field: '$score'
    }];

    // can we load more results for given query?
    const canLoadMore = query => {
      if (typeof self.settings.maxOptions === 'number' && dropdown_content.children.length >= self.settings.maxOptions) {
        return false;
      }
      if (query in pagination && pagination[query]) {
        return true;
      }
      return false;
    };
    const clearFilter = (option, value) => {
      if (self.items.indexOf(value) >= 0 || default_values.indexOf(value) >= 0) {
        return true;
      }
      return false;
    };

    // set the next url that will be
    self.setNextUrl = (value, next_url) => {
      pagination[value] = next_url;
    };

    // getUrl() to be used in settings.load()
    self.getUrl = query => {
      if (query in pagination) {
        const next_url = pagination[query];
        pagination[query] = false;
        return next_url;
      }

      // if the user goes back to a previous query
      // we need to load the first page again
      self.clearPagination();
      return self.settings.firstUrl.call(self, query);
    };

    // clear pagination
    self.clearPagination = () => {
      pagination = {};
    };

    // don't clear the active option (and cause unwanted dropdown scroll)
    // while loading more results
    self.hook('instead', 'clearActiveOption', () => {
      if (loading_more) {
        return;
      }
      return orig_clearActiveOption.call(self);
    });

    // override the canLoad method
    self.hook('instead', 'canLoad', query => {
      // first time the query has been seen
      if (!(query in pagination)) {
        return orig_canLoad.call(self, query);
      }
      return canLoadMore(query);
    });

    // wrap the load
    self.hook('instead', 'loadCallback', (options, optgroups) => {
      if (!loading_more) {
        self.clearOptions(clearFilter);
      } else if (load_more_opt) {
        const first_option = options[0];
        if (first_option !== undefined) {
          load_more_opt.dataset.value = first_option[self.settings.valueField];
        }
      }
      orig_loadCallback.call(self, options, optgroups);
      loading_more = false;
    });

    // add templates to dropdown
    //	loading_more if we have another url in the queue
    //	no_more_results if we don't have another url in the queue
    self.hook('after', 'refreshOptions', () => {
      const query = self.lastValue;
      var option;
      if (canLoadMore(query)) {
        option = self.render('loading_more', {
          query: query
        });
        if (option) {
          option.setAttribute('data-selectable', ''); // so that navigating dropdown with [down] keypresses can navigate to this node
          load_more_opt = option;
        }
      } else if (query in pagination && !dropdown_content.querySelector('.no-results')) {
        option = self.render('no_more_results', {
          query: query
        });
      }
      if (option) {
        addClasses(option, self.settings.optionClass);
        dropdown_content.append(option);
      }
    });

    // add scroll listener and default templates
    self.on('initialize', () => {
      default_values = Object.keys(self.options);
      dropdown_content = self.dropdown_content;

      // default templates
      self.settings.render = Object.assign({}, {
        loading_more: () => {
          return `<div class="loading-more-results">Loading more results ... </div>`;
        },
        no_more_results: () => {
          return `<div class="no-more-results">No more results</div>`;
        }
      }, self.settings.render);

      // watch dropdown content scroll position
      dropdown_content.addEventListener('scroll', () => {
        if (!self.settings.shouldLoadMore.call(self)) {
          return;
        }

        // !important: this will get checked again in load() but we still need to check here otherwise loading_more will be set to true
        if (!canLoadMore(self.lastValue)) {
          return;
        }

        // don't call load() too much
        if (loading_more) return;
        loading_more = true;
        self.load.call(self, self.lastValue);
      });
    });
  }

  TomSelect.define('change_listener', change_listener);
  TomSelect.define('checkbox_options', checkbox_options);
  TomSelect.define('clear_button', clear_button);
  TomSelect.define('drag_drop', drag_drop);
  TomSelect.define('dropdown_header', dropdown_header);
  TomSelect.define('caret_position', caret_position);
  TomSelect.define('dropdown_input', dropdown_input);
  TomSelect.define('input_autogrow', input_autogrow);
  TomSelect.define('no_backspace_delete', no_backspace_delete);
  TomSelect.define('no_active_items', no_active_items);
  TomSelect.define('optgroup_columns', optgroup_columns);
  TomSelect.define('remove_button', remove_button);
  TomSelect.define('restore_on_backspace', restore_on_backspace);
  TomSelect.define('virtual_scroll', virtual_scroll);

  class ExhibitTagAutocomplete {
    connect() {
      const tagOptions = {
        closeAfterSelect: true,
        create: true,
        createOnBlur: true,
        duplicates: false,
        hideSelected: true,
        labelField: 'name',
        loadThrottle: 300,
        maxOptions: 100,
        persist: false,
        plugins: ['remove_button'],
        preload: true,
        searchField: 'name',
        valueField: 'name',
        onItemAdd: function(value, item) {
          this.control_input.value = '';
        },
        load: function(query, callback) {
          fetch(this.input.dataset.autocompleteUrl)
            .then(response => response.json())
            .then(json => {
              callback(json.map(tag => ({name: tag.trim()})));
            }).catch(() => callback());
        }
      };

      document.querySelectorAll('[data-autocomplete-tag="true"]').forEach(tagElement => {
        // Handle leading spaces (e.g., 'Tag 1, Tag 2') or else the user can add what appear to be duplicate tags.
        const items = tagElement.value.split(',').map(item => item.trim()).filter(Boolean);
        const options = items.map(item => ({name: item}));
        new TomSelect(tagElement, { ...tagOptions, items, options });
      });
    }
  }

  class Exhibits {
    connect() {
      // auto-fill the exhibit slug on the new exhibit form
      $('#new_exhibit').each(function() {
        $('#exhibit_title').on('change keyup', function() {
          $('#exhibit_slug').attr('placeholder', URLify($(this).val(), $(this).val().length));
        });

        $('#exhibit_slug').on('focus', function() {
          if ($(this).val() === '') {
            $(this).val($(this).attr('placeholder'));
          }
        });
      });

      $("#another-email").on("click", function(e) {
        e.preventDefault();

        var container = $(this).closest('.form-group');
        var contacts = container.find('.contact');
        var inputContainer = contacts.first().clone();

        // wipe out any values from the inputs
        inputContainer.find('input').each(function() {
          $(this).val('');
          $(this).attr('id', $(this).attr('id').replace('0', contacts.length));
          $(this).attr('name', $(this).attr('name').replace('0', contacts.length));
          if ($(this).attr('aria-label')) {
            $(this).attr('aria-label', $(this).attr('aria-label').replace('1', contacts.length + 1));
          }
        });

        inputContainer.find('.contact-email-delete-wrapper').remove();
        inputContainer.find('.confirmation-status').remove();

        // bootstrap does not render input-groups with only one value in them correctly.
        inputContainer.find('.input-group input:only-child').closest('.input-group').removeClass('input-group');

        $(inputContainer).insertAfter(contacts.last());
      });

      $('.contact-email-delete').on('ajax:success', function() {
        $(this).closest('.contact').fadeOut(250, function() { $(this).remove(); });
      });

      $('.contact-email-delete').on('ajax:error', function(event, _xhr, _status, error) {
        var errSpan = $(this).closest('.contact').find('.contact-email-delete-error');
        errSpan.show();
        errSpan.find('.error-msg').first().text(error || event.detail[1]);
      });

      $('.btn-with-tooltip').tooltip();

      // Put focus in saved search title input when Save this search modal is shown
      $('#save-modal').on('shown.bs.modal', function () {
          $('#search_title').focus();
      });
    }
  }

  (function($, undefined$1) {

    /*
    * SerializedForm is built as a singleton jQuery plugin. It needs to be able to
    * handle instantiation from multiple sources, and use the [data-form-observer]
    * as global state object.
    */
    $.SerializedForm = function () {
      var $serializedForm;
      var plugin = this;

      // Store form serialization in data attribute
      function serializeFormStatus () {
        $serializedForm.data('serialized-form', formSerialization($serializedForm));
      }

      // Do custom serialization of the sir-trevor form data. This needs to be a
      // passed in argument for comparison later on.
      function formSerialization (form) {
        var content_editable = [];
        var i = 0;
        $("[contenteditable='true']", form).each(function(){
          content_editable.push('&contenteditable_' + i + '=' + $(this).text());
        });
        return form.serialize() + content_editable.join();
      }

      // Unbind observing form on submit (which we have to do because of turbolinks)
      function unbindObservedFormSubmit () {
        $serializedForm.on('submit', function () {
          $(this).data('being-submitted', true);
        });
      }

      // Get the stored serialized form status
      function serializedFormStatus () {
        return $serializedForm.data('serialized-form');
      }

      // Check all observed forms on page for status change
      plugin.observedFormsStatusHasChanged = function () {
        var unsaved_changes = false;
        $('[data-form-observer]').each(function (){
          if ( !$(this).data("being-submitted") ) {
            if (serializedFormStatus() != formSerialization($(this))) {
              unsaved_changes = true;
            }
          }
        });
        return unsaved_changes;
      };

      function init () {
        $serializedForm = $('[data-form-observer]');
        serializeFormStatus();
        unbindObservedFormSubmit();
      }

      init();

      return plugin;
    };
  })(jQuery);

  class FormObserver {
    connect() {
      // Instantiate the singleton SerializedForm plugin
      var serializedForm = $.SerializedForm();
      $(window).on('beforeunload page:before-change turbolinks:before-visit', function(event) {
        // Don't handle the same event twice #turbolinks
        if (event.handled !== true) {
          if ( serializedForm.observedFormsStatusHasChanged() ) {
            event.handled = true;
            var message = "You have unsaved changes. Are you sure you want to leave this page?";
            // There are variations in how Webkit browsers may handle this:
            // https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload
            if ( event.type == "beforeunload" ) {
              return message;
            } else {
              return confirm(message)
            }
          }
        }
      });
    }
  }

  class Locks {
    delete_lock(el) {
      $.ajax({ url: $(el).data('lock'), type: 'POST', data: { _method: "delete" }, async: false});
      $(el).removeAttr('data-lock');
    }

    connect() {
      $('[data-lock]').on('click', (e) => {
        this.delete_lock(e.target);
      });
    }
  }

  // Module to add multi-image selector to widget panels

  (function(){
    $.fn.multiImageSelector = function(image_versions, clickCallback, activeImageId) {
      var changeLink          = $("<a href='javascript:;'>Change</a>"),
          thumbsListContainer = $("<div class='thumbs-list' style='display:none'></div>"),
          thumbList           = $("<ul></ul>"),
          panel;

      var imageIds = $.map(image_versions, function(e) { return e['imageId']; });

      return init(this);

      function init(el) {
        panel = el;

        destroyExistingImageSelector();
        if(image_versions && image_versions.length > 1) {
          addChangeLink();
          addThumbsList();
        }
      }
      function addChangeLink() {
        $('[data-panel-image-pagination]', panel)
          .html("Image <span data-current-image='true'>" + indexOf(activeImageId) + "</span> of " + image_versions.length)
          .show()
          .append(" ")
          .append(changeLink);
        addChangeLinkBehavior();
      }

      function destroyExistingImageSelector() {
        var pagination = $('[data-panel-image-pagination]', panel);
        pagination.html('');
        pagination.next('.' + thumbsListContainer.attr('class')).remove();
      }

      function indexOf(thumb){
        const index = imageIds.indexOf(thumb);
        if (index > -1) {
          return index + 1;
        } else {
          return 1;
        }
      }
      function addChangeLinkBehavior() {
        changeLink.on('click', function(){
          thumbsListContainer.slideToggle();
          updateThumbListWidth();
          addScrollBehavior();
          scrollToActiveThumb();
          loadVisibleThumbs();
          swapChangeLinkText($(this));
        });
      }
      function updateThumbListWidth() {
        var width = 0;
        $('li', thumbList).each(function(){
          width += $(this).outerWidth();
        });
        thumbList.width(width + 5);
      }
      function loadVisibleThumbs(){
        var viewportWidth = thumbsListContainer.width();
        var width = 0;
        $('li', thumbList).each(function(){
          var thisThumb  = $(this),
              image      = $('img', thisThumb),
              totalWidth = width += thisThumb.width();
              position   = (thumbList.position().left + totalWidth) - thisThumb.width();

          if(position >= 0 && position < viewportWidth) {
            image.prop('src', image.data('src'));
          }
        });
      }
      function addScrollBehavior(){
        thumbsListContainer.scrollStop(function(){
          loadVisibleThumbs();
        });
      }
      function scrollToActiveThumb(){
        var halfContainerWidth      = (thumbsListContainer.width() / 2),
            activeThumbLeftPosition = ($('.active', thumbList).position() || $('li', thumbList).first().position()).left,
            halfActiveThumbWidth    = ($('.active', thumbList).width() / 2);
        thumbsListContainer.scrollLeft(
          (activeThumbLeftPosition - halfContainerWidth) + halfActiveThumbWidth
        );
      }
      function addThumbsList() {
        addThumbsToList();
        updateActiveThumb();
        $('.card-header', panel).append(
          thumbsListContainer.append(
            thumbList
          )
        );
      }
      function updateActiveThumb(){
        $('li', thumbList).each(function(){
          var item = $(this);
          if($('img', item).data('image-id') == activeImageId){
            item.addClass('active');
          }
        });
      }
      function swapChangeLinkText(link){
        link.text(
          link.text() == 'Change' ? 'Close' : 'Change'
        );
      }

      function addThumbsToList(){
        $.each(image_versions, function(i){
          var listItem = $('<li data-index="' + i + '"><a href="javascript:;"><img src="' + image_versions[i]['thumb'] +'" data-image-id="' + image_versions[i]['imageId'] +'" /></a></li>');
          listItem.on('click', function(){
            // get the current image id
            $('img', $(this)).data('image-id');
            var src = $('img', $(this)).attr('src');

            if (typeof clickCallback === 'function' ) {
              clickCallback(image_versions[i]);
            }

            // mark the current selection as active
            $('li.active', thumbList).removeClass('active');
            $(this).addClass('active');

            // update the multi-image selector image
            $(".pic img.img-thumbnail", panel).attr("src", src);

            $('[data-panel-image-pagination] [data-current-image]', panel).text(
              $('li', thumbList).index($(this)) + 1
            );
            scrollToActiveThumb();
          });
          $("img", listItem).on('load', function() {
            updateThumbListWidth();
          });
          thumbList.append(listItem);
        });
      }
    };

  })(jQuery);

  // source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
  jQuery.fn.scrollStop = function(callback) {
    $(this).scroll(function() {
      var self  = this,
      $this = $(self);

      if ($this.data('scrollTimeout')) {
        clearTimeout($this.data('scrollTimeout'));
      }

      $this.data('scrollTimeout', setTimeout(callback, 250, self));
    });
  };

  // Place all the behaviors and hooks related to the matching controller here.

  class Pages {
    connect(){
      SirTrevor.setDefaults({
        iconUrl: Spotlight.sirTrevorIcon,
        uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint'),
        ajaxOptions: {
          headers: {
            'X-CSRF-Token': Spotlight$1.csrfToken() || ''
          },
          credentials: 'same-origin'
        }
      });

      SirTrevor.Blocks.Heading.prototype.toolbarEnabled = true;
      SirTrevor.Blocks.Quote.prototype.toolbarEnabled = true;
      SirTrevor.Blocks.Text.prototype.toolbarEnabled = true;

      var instance = $('.js-st-instance').first();

      if (instance.length) {
        var editor = new SirTrevor.Editor({
          el: instance[0],
          blockTypes: instance.data('blockTypes'),
          defaultType:["Text"],
          onEditorRender: function() {
            $.SerializedForm();
          },
          blockTypeLimits: {
            "SearchResults": 1
          }
        });

        editor.blockControls = Spotlight$1.BlockControls.create(editor);

        new Spotlight$1.BlockLimits(editor).enforceLimits(editor);
      }
    }
  }

  class ProgressMonitor {
    connect() {
      var monitorElements = $('[data-behavior="progress-panel"]');
      var defaultRefreshRate = 3000;
      var panelContainer;
      var pollers = [];

      $(monitorElements).each(function() {
        panelContainer = $(this);
        panelContainer.hide();
        var monitorUrl = panelContainer.data('monitorUrl');
        var refreshRate = panelContainer.data('refreshRate') || defaultRefreshRate;
        pollers.push(
          setInterval(function() {
            checkMonitorUrl(monitorUrl);
          }, refreshRate)
        );
      });

      // Clear the intervals on turbolink:click event (e.g. when the user navigates away from the page)
      $(document).on('turbolinks:click', function() {
        if (pollers.length > 0) {
          $.each(pollers, function() {
            clearInterval(this);
          });
          pollers = [];
        }
      });

      function checkMonitorUrl(url) {
        $.ajax(url).done(success).fail(fail);
      }

      function success(data) {
        if (data.recently_in_progress) {
          updateMonitorPanel(data);
          monitorPanel().show();
        } else {
          monitorPanel().hide();
        }
      }

      function fail() { monitorPanel().hide(); }

      function updateMonitorPanel(data) {
        panelStartDate().text(data.started_at);
        panelCurrentDate().text(data.updated_at);
        panelCompletedDate().text(data.updated_at);
        panelCurrent().text(data.completed);
        setPanelCompleted(data.finished);
        updatePanelTotals(data);
        updatePanelErrorMessage(data);
        updateProgressBar(data);

        panelContainer.show();
      }

      function updateProgressBar(data) {
        var percentage = calculatePercentage(data);
        progressBar()
          .attr('aria-valuemax', data.total)
          .attr('aria-valuenow', percentage)
          .css('width', percentage + '%')
          .text(percentage + '%');

        if (data.finished) {
          progressBar().removeClass('active').removeClass('progress-bar-striped');
        }
      }

      function updatePanelErrorMessage(data) {
        // We currently do not store this state,
        // but with this code we can in the future.
        if ( data.errored ) {
          panelErrorMessage().show();
        } else {
          panelErrorMessage().hide();
        }
      }

      function updatePanelTotals(data) {
        panelTotals().each(function() {
          $(this).text(data.total);
        });
      }

      function calculatePercentage(data) {
        if (data.total == 0) return 0;
        return Math.floor((data.completed / data.total) * 100);
      }

      function monitorPanel() {
        return panelContainer.find('.index-status');
      }

      function panelStartDate() {
        return monitorPanel()
                 .find('[data-behavior="monitor-start"]')
                 .find('[data-behavior="date"]');
      }

      function panelCurrentDate() {
        return monitorPanel()
                 .find('[data-behavior="monitor-current"]')
                 .find('[data-behavior="date"]');
      }

      function panelCompletedDate() {
        return monitorPanel()
                 .find('[data-behavior="monitor-completed"]')
                 .find('[data-behavior="date"]');
      }

      function panelTotals() {
        return monitorPanel().find('[data-behavior="total"]');
      }

      function panelCurrent() {
        return monitorPanel()
                 .find('[data-behavior="monitor-current"]')
                 .find('[data-behavior="completed"]');
      }

      function progressBar() {
        return monitorPanel().find('.progress-bar');
      }

      function panelErrorMessage() {
        return monitorPanel().find('[data-behavior="monitor-error"]');
      }

      function setPanelCompleted(finished) {
        var panel = monitorPanel().find('[data-behavior="monitor-completed"]');

        if (finished) {
          panel.show();
        } else {
          panel.hide();
        }
      }

      return this;
    }
  }

  class ReadonlyCheckbox {
    connect() {
      // Don't allow unchecking of checkboxes with the data-readonly attribute 
      $("input[type='checkbox'][data-readonly]").on("click", function(event) {
        event.preventDefault();
      });
    }
  }

  (function($){
    $.fn.spotlightSearchTypeAhead = function( options ) {
      $.each(this, function(){
        addAutocompleteBehavior($(this));
      });

      function addAutocompleteBehavior( typeAheadInput, settings ) {
        var settings = $.extend({
          displayKey: 'title',
          minLength: 0,
          highlight: (typeAheadInput.data('autocomplete-highlight') || true),
          hint: (typeAheadInput.data('autocomplete-hint') || false),
          autoselect: (typeAheadInput.data('autocomplete-autoselect') || true)
        }, options);
        typeAheadInput.typeahead(settings, {
          displayKey: settings.displayKey,
          source: settings.bloodhound.ttAdapter(),
          templates: {
            suggestion: settings.template
          }
        });
      }
      return this;
    };
  })( jQuery );

  function itemsBloodhound() {
    var results = new Bloodhound({
      datumTokenizer: function(d) {
        return Bloodhound.tokenizers.whitespace(d.title);
      },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 100,
      remote: {
        url: $('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path').replace("%25QUERY", "%QUERY"),
        filter: function(response) {
          return $.map(response['docs'], function(doc) {
            return doc;
          })
        }
      }
    });
    results.initialize();
    return results;
  }
  function templateFunc(obj) {
    const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : '';
    return $(`<div class="autocomplete-item${obj.private ? ' blacklight-private' : ''}">${thumbnail}
  <span class="autocomplete-title">${obj.title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`)
  }

  function addAutocompletetoFeaturedImage(){
    if($('[data-featured-image-typeahead]').length > 0) {
      $('[data-featured-image-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: templateFunc}).on('click', function() {
        $(this).select();
      }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
        var panel = $($(this).data('target-panel'));
        addImageSelector($(this), panel, data.iiif_manifest, true);
        $($(this).data('id-field')).val(data['global_id']);
        $(this).attr('type', 'text');
      });
    }
  }

  /*
    Simple plugin to select form elements
    when other elements are clicked.
  */
  (function($) {
    $.fn.selectRelatedInput = function() {
      var clickElements = this;

      $(clickElements).each(function() {
        var target = $($(this).data('input-select-target'));

        var event;

        if ($(this).is("select")) {
          event = 'change';
        } else {
          event = 'click';
        }

        $(this).on(event, function() {
          if (target.is(":checkbox") || target.is(":radio")) {
            target.prop('checked', true);
          } else {
            target.focus();
          }
        });
      });

      return this;
    };
  })(jQuery);

  class SelectRelatedInput {
    connect() {
      $('[data-input-select-target]').selectRelatedInput();
    }
  }

  const Module = (function() {
      var nestableSelector = '[data-behavior="nestable"]';
      return {
        init: function(selector){

          $(selector || nestableSelector).each(function(){
            // Because the Rails helper will not maintain the case that Nestable
            // expects, we just need to do this manual conversion. :(
            var data = $(this).data();
            data.expandBtnHTML = data.expandBtnHtml;
            data.collapseBtnHTML = data.collapseBtnHtml;
            $(this).nestable(data);
            updateWeightsAndRelationships($(this));
          });
        }
      };
      function updateWeightsAndRelationships(nestedList){
        nestedList.on('change', function(event){
          var container = $(event.currentTarget);
          var data = $(this).nestable('serialize');
          var weight = 0;
          for(var i in data){
            var parent_id = data[i]['id'];
            const parent_node = findNode(parent_id, container);
            setWeight(parent_node, weight++);
            if(data[i]['children']){
              var children = data[i]['children'];
              for(var child in children){
                var id = children[child]['id'];
                child_node = findNode(id, container);
                setWeight(child_node, weight++);
                setParent(child_node, parent_id);
              }
            } else {
              setParent(parent_node, "");
            }
          }
        });

      }
      function findNode(id, container) {
        return container.find("[data-id="+id+"]");
      }

      function setWeight(node, weight) {
        weight_field(node).val(weight);
      }

      function setParent(node, parent_id) {
        parent_page_field(node).val(parent_id);
      }

      /* find the input element with data-property="weight" that is nested under the given node */
      function weight_field(node) {
        return find_property(node, "weight");
      }

      /* find the input element with data-property="parent_page" that is nested under the given node */
      function parent_page_field(node){
        return find_property(node, "parent_page");
      }

      function find_property(node, property) {
        return node.find("input[data-property=" + property + "]");
      }
  })();

  class Tabs {
    connect() {
      if ($('[role=tabpanel]').length > 0 && window.location.hash) {
        var tabpanel = $(window.location.hash).closest('[role=tabpanel]');
        $('a[role=tab][href="#'+tabpanel.attr('id')+'"]').tab('show');
      }
    }
  }

  // translationProgress is a plugin that updates the "3/14" progress
  // counters in the tabs of the translation adminstration dashboard.
  // This works by counting the number of progress items and translations
  // present (indicated by data attributes) in each tab's content
  class TranslationProgress {
    connect() {
      $('[data-behavior="translation-progress"]').each(function(){
        var currentTab = $(this);
        var tabName = $(this).attr('aria-controls');
        var translationFields = $('#' + tabName).find('[data-translation-progress-item="true"]');
        var completedTranslations = $('#' + tabName).find('[data-translation-present="true"]');

        currentTab.find('span').text(completedTranslations.length + '/' + translationFields.length);
      });
    }
  }

  /*
  NOTE: this is copied & adapted from BL8's checkbox_submit.js in order to have
  it accessible in a BL7-based spotlight. Once we drop support for BL7, this file
  can be deleted and we can change visibility_toggle.es6 to import CheckboxSubmit
  from Blacklight.

  See https://github.com/projectblacklight/blacklight/blob/main/app/javascript/blacklight/checkbox_submit.js
  */
  class CheckboxSubmit {
    constructor(form) {
      this.form = form;
    }

    async clicked(evt) {
      this.spanTarget.innerHTML = this.form.getAttribute('data-inprogress');
      this.labelTarget.setAttribute('disabled', 'disabled');
      this.checkboxTarget.setAttribute('disabled', 'disabled');
      const csrfMeta = document.querySelector('meta[name=csrf-token]');
      const response = await fetch(this.formTarget.getAttribute('action'), {
        body: new FormData(this.formTarget),
        method: this.formTarget.getAttribute('method').toUpperCase(),
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfMeta ? csrfMeta.content : ''
        }
      });
      this.labelTarget.removeAttribute('disabled');
      this.checkboxTarget.removeAttribute('disabled');
      if (response.ok) {
        this.updateStateFor(!this.checked);
        // Not used for our case in Spotlight (visibility toggle)
        // const json = await response.json()
        // document.querySelector('[data-role=bookmark-counter]').innerHTML = json.bookmarks.count
      } else {
        alert('Error');
      }
    }

    get checked() {
      return (this.form.querySelectorAll('input[name=_method][value=delete]').length != 0)
    }

    get formTarget() {
      return this.form
    }

    get labelTarget() {
      return this.form.querySelector('[data-checkboxsubmit-target="label"]')
    }

    get checkboxTarget() {
      return this.form.querySelector('[data-checkboxsubmit-target="checkbox"]')
    }

    get spanTarget() {
      return this.form.querySelector('[data-checkboxsubmit-target="span"]')
    }

    updateStateFor(state) {
      this.checkboxTarget.checked = state;

      if (state) {
        this.labelTarget.classList.add('checked');
        //Set the Rails hidden field that fakes an HTTP verb
        //properly for current state action.
        this.formTarget.querySelector('input[name=_method]').value = 'delete';
        this.spanTarget.innerHTML = this.form.getAttribute('data-present');
      } else {
        this.labelTarget.classList.remove('checked');
        this.formTarget.querySelector('input[name=_method]').value = 'put';
        this.spanTarget.innerHTML = this.form.getAttribute('data-absent');
      }
    }
  }

  // Visibility toggle for items in an exhibit, based on Blacklight's bookmark toggle

  const VisibilityToggle = (e) => {
    if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
      const form = e.target.closest('form');
      if (form) {
        new CheckboxSubmit(form).clicked(e);

        // Add/remove the "private" label to the document row when visibility is toggled
        const docRow = form.closest('tr');
        if (docRow) docRow.classList.toggle('blacklight-private');
      }
    }
  };

  VisibilityToggle.selector = 'form.visibility-toggle';

  document.addEventListener('click', VisibilityToggle);

  class Users {
    connect() {
      var container;
      function edit_user(event) {
        event.preventDefault();
        $(this).closest('tr').hide();
        const id = $(this).attr('data-target');
        const edit_view = $("[data-edit-for='"+id+"']", container).show();
        $.each(edit_view.find('input[type="text"], select'), function() {
          // Cache original values incase editing is canceled
          $(this).data('orig', $(this).val());
        });
      }

      function cancel_edit(event) {
        event.preventDefault();
        const id = $(this).closest('tr').attr('data-edit-for');
        const edit_view = $("[data-edit-for='"+id+"']", container).hide();
        clear_errors(edit_view);
        rollback_changes(edit_view);
        $("[data-show-for='"+id+"']", container).show();
      }

      function clear_errors(element) {
        element.find('.has-error')
               .removeClass('has-error')
               .find('.form-text')
               .remove(); // Remove the error messages
      }

      function rollback_changes(element) {
        $.each(element.find('input[type="text"], select'), function() {
          $(this).val($(this).data('orig')).trigger('change');
        });
      }

      function destroy_user(event) {
        const id = $(this).attr('data-target');
        $("[data-destroy-for='"+id+"']", container).val('1');
      }

      function new_user(event) {
        event.preventDefault();
        const edit_view = $("[data-edit-for='new']", container).show();
        $.each(edit_view.find('input[type="text"], select'), function() {
          // Cache original values incase editing is canceled
          $(this).data('orig', $(this).val());
        });
      }

      function open_errors() {
        const edit_row = container.find('.has-error').closest('[data-edit-for]');
        edit_row.show();
        // The following row has the controls, so show it too.
        edit_row.next().show();
      }

      $('.edit_exhibit, .admin-users').each(function() {

        container = $(this);
        $('[data-edit-for]', container).hide();
        open_errors();
        $("[data-behavior='edit-user']", container).on('click', edit_user);
        $("[data-behavior='cancel-edit']", container).on('click', cancel_edit);
        $("[data-behavior='destroy-user']", container).on('click', destroy_user);
        $("[data-behavior='new-user']", container).on('click', new_user);
      });
    }
  }

  (function ($){
    SirTrevor.BlockMixins.Autocompleteable = {
      mixinName: "Autocompleteable",
      preload: true,

      initializeAutocompleteable: function() {
        this.on("onRender", this.addAutocompletetoSirTrevorForm);

        if (this['autocomplete_url'] === undefined) {
          this.autocomplete_url = function() { return $('form[data-autocomplete-url]').data('autocomplete-url').replace("%25QUERY", "%QUERY"); };
        }

        if (this['transform_autocomplete_results'] === undefined) {
          this.transform_autocomplete_results = (val) => val;
        }

        if (this['autocomplete_control'] === undefined) {
          this.autocomplete_control = function() { return `<input type="text" class="st-input-string form-control item-input-field" data-twitter-typeahead="true" placeholder="${i18n.t("blocks:autocompleteable:placeholder")}"/>` };
        }

        if (this['bloodhoundOptions'] === undefined) {
          this.bloodhoundOptions = function() {
            return {
              remote: {
                url: this.autocomplete_url(),
                filter: this.transform_autocomplete_results
              }
            };
          };
        }
      },

      addAutocompletetoSirTrevorForm: function() {
        $('[data-twitter-typeahead]', this.inner).spotlightSearchTypeAhead({bloodhound: this.bloodhound(), template: this.autocomplete_template}).on('typeahead:selected typeahead:autocompleted', this.autocompletedHandler()).on( 'focus', function() {
          if($(this).val() === '') {
            $(this).data().ttTypeahead.input.trigger('queryChanged', '');
          }
        });
      },

      autocompletedHandler: function(e, data) {
        var context = this;

        return function(e, data) {
          $(this).typeahead("val", "");
          $(this).val("");

          context.createItemPanel($.extend(data, {display: "true"}));
        }
      },

      bloodhound: function() {
        var block = this;
        var results = new Bloodhound(Object.assign({
          datumTokenizer: function(d) {
            return Bloodhound.tokenizers.whitespace(d.title);
          },
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          limit: 100,
        }, block.bloodhoundOptions()));
        results.initialize();
        return results;
      },
    },


    SirTrevor.Block.prototype.availableMixins.push("autocompleteable");
  })(jQuery);

  (function ($){
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

        var data = $(":input,textarea,select", this.inner).not(':input:radio').serializeJSON();

        $(':input:radio:checked', this.inner).each(function(index, input) {
          var key = $(input).data('key') || input.getAttribute('name');

          if (!key.match("\\[")) {
            data[key] = $(input).val();
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
        $(':input', this.inner).not('button,:input[type=hidden]').each(function(index, input) {
          var key = $(input).data('key') || input.getAttribute('name');

          if (key) {

            if (key.match("\\[\\]$")) {
              key = key.replace("[]", "");
            }

            // by wrapping it in an array, this'll "just work" for radio and checkbox fields too
            var input_data = data[key];

            if (!(input_data instanceof Array)) {
              input_data = [input_data];
            }
            $(this).val(input_data);
          }
        });
      },
    },


    SirTrevor.Block.prototype.availableMixins.push("formable");
  })(jQuery);

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
          <div class="form-group">
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

  (function ($){
    Spotlight$1.Block = SirTrevor.Block.extend({
      scribeOptions: {
        allowBlockElements: true,
        tags: { p: true }
      },
      formable: true,
      editorHTML: function() {
        return '';
      },
      beforeBlockRender: function() {
        this.availableMixins.forEach(function(mixin) {
          if (this[mixin] && SirTrevor.BlockMixins[this.capitalize(mixin)].preload) {
            this.withMixin(SirTrevor.BlockMixins[this.capitalize(mixin)]);
          }
        }, this);
      },
      $instance: function() { return $('#' + this.instanceID); },
      capitalize: function(string) {
        return string.charAt(0).toUpperCase() + string.substring(1).toLowerCase();
      }
    });
  })(jQuery);

  Spotlight$1.Block.Resources = (function(){

    return Spotlight$1.Block.extend({
      type: "resources",
      formable: true,
      autocompleteable: true,
      show_heading: true,

      title: function() { return i18n.t("blocks:" + this.type + ":title"); },
      description: function() { return i18n.t("blocks:" + this.type + ":description"); },

      icon_name: "resources",
      blockGroup: function() { return i18n.t("blocks:group:items") },

      primary_field_key: "primary-caption-field",
      show_primary_field_key: "show-primary-caption",
      secondary_field_key: "secondary-caption-field",
      show_secondary_field_key: "show-secondary-caption",

      display_checkbox: "display-checkbox",

      globalIndex: 0,

      _itemPanelIiifFields: function(index, data) {
        return [];
      },

      _itemPanel: function(data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var markup = `
          <li class="field form-inline dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][title]" value="${data.title}" />
            ${this._itemPanelIiifFields(index, data)}
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="checkbox">
                      <input name="item[${index}][display]" type="hidden" value="false" />
                      <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                      <label class="sr-only" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.title}</div>
                      <div>${(data.slug || data.id)}</div>
                    </div>
                    <div class="remove float-right">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                  <div data-panel-image-pagination="true"></div>
                </div>
              </div>
            </li>
      `;

        const panel = $(markup);
        var context = this;

        $('.remove a', panel).on('click', function(e) {
          e.preventDefault();
          $(this).closest('.field').remove();
          context.afterPanelDelete();

        });

        this.afterPanelRender(data, panel);

        return panel;
      },

      afterPanelRender: function(data, panel) {

      },

      afterPanelDelete: function() {

      },

      createItemPanel: function(data) {
        var panel = this._itemPanel(data);
        $(panel).appendTo($('.panels > ol', this.inner));
        $('[data-behavior="nestable"]', this.inner).trigger('change');
      },

      item_options: function() { return ""; },

      content: function() {
        var templates = [this.items_selector()];
        if (this.plustextable) {
          templates.push(this.text_area());
        }
        return templates.join("<hr />\n");
      },

      items_selector: function() { return [
      '<div class="row">',
        '<div class="col-md-8">',
          '<div class="form-group">',
          '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1"><ol class="dd-list"></ol></div>',
            this.autocomplete_control(),
          '</div>',
        '</div>',
        '<div class="col-md-4">',
          this.item_options(),
        '</div>',
      '</div>'].join("\n")
      },

      editorHTML: function() {
        return `<div class="form resources-admin clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        ${this.content()}
      </div>`
      },

      onBlockRender: function() {
        Module.init($('[data-behavior="nestable"]', this.inner));

        $('[data-input-select-target]', this.inner).selectRelatedInput();
      },

      afterLoadData: function(data) {
        var context = this;
        $.each(Object.keys(data.item || {}).map(function(k) { return data.item[k]}).sort(function(a,b) { return a.weight - b.weight; }), function(index, item) {
          context.createItemPanel(item);
        });
      },
    });

  })();

  SirTrevor.Blocks.Browse = (function(){

    return Spotlight$1.Block.Resources.extend({
      type: "browse",

      icon_name: "browse",

      autocomplete_url: function() {
        return $(this.inner).closest('form[data-autocomplete-exhibit-searches-path]').data('autocomplete-exhibit-searches-path').replace("%25QUERY", "%QUERY");
      },

      autocomplete_template: function(obj) {
        const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : '';
        return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${obj.full_title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`
      },

      bloodhoundOptions: function() {
        return {
          prefetch: {
            url: this.autocomplete_url(),
            ttl: 0
          }
        };
      },

      _itemPanel: function(data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var markup = `
           <li class="field form-inline dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][full_title]" value="${(data.full_title || data.title)}" />
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="checkbox">
                      <input name="item[${index}][display]" type="hidden" value="false" />
                      <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                      <label class="sr-only" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${(data.full_title || data.title)}</div>
                      <div>${(data.slug || data.id)}</div>
                    </div>
                    <div class="remove float-right">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                </div>
              </div>
            </li>`;

        var panel = $(markup);
        var context = this;

        $('.remove a', panel).on('click', function(e) {
          e.preventDefault();
          $(this).closest('.field').remove();
          context.afterPanelDelete();

        });

        this.afterPanelRender(data, panel);

        return panel;
      },

      item_options: function() { return `
      <label>
        <input type="hidden" name="display-item-counts" value="false" />
        <input type="checkbox" name="display-item-counts" value="true" checked />
        ${i18n.t("blocks:browse:item_counts")}
      </label>`
      },
    });

  })();

  /*
    Sir Trevor BrowseGroupCategories
  */

  SirTrevor.Blocks.BrowseGroupCategories = (function(){

    return Spotlight$1.Block.Resources.extend({
      type: "browse_group_categories",
      icon_name: "browse",
      bloodhoundOptions: function() {
        var that = this;
        return {
          prefetch: {
            url: this.autocomplete_url(),
            ttl: 0,
            filter: function(response) {
              // Let the dom know that the response has been returned
              $(that.inner).attr('data-browse-groups-fetched', true);
              return response;
            }
          }
        };
      },

      autocomplete_control: function() {
        return `<input type="text" class="st-input-string form-control item-input-field" data-twitter-typeahead="true" placeholder="${i18n.t("blocks:browse_group_categories:autocomplete")}"/>`
      },
      autocomplete_template: function(obj) {
        return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">
      <span class="autocomplete-title">${obj.title}</span><br/></div>`
      },

      autocomplete_url: function() { return $(this.inner).closest('form[data-autocomplete-exhibit-browse-groups-path]').data('autocomplete-exhibit-browse-groups-path').replace("%25QUERY", "%QUERY"); },
      _itemPanel: function(data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var markup = `
        <li class="field form-inline dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
          <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
          <input type="hidden" name="item[${index}][title]" value="${data.title}" />
          <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="d-flex card-header item-grid justify-content-between">
                <div class="d-flex flex-grow-1">
                  <div class="checkbox">
                    <input name="item[${index}][display]" type="hidden" value="false" />
                    <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                    <label class="sr-only" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                  </div>
                  <div class="main">
                    <div class="title card-title">${data.title}</div>
                  </div>
                </div>
                <div class="d-flex">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </div>
          </li>`;

        const panel = $(markup);
        var context = this;

        $('a[data-item-grid-panel-remove]', panel).on('click', function(e) {
          e.preventDefault();
          $(this).closest('.field').remove();
          context.afterPanelDelete();

        });

        this.afterPanelRender(data, panel);

        return panel;
      },

      item_options: function() { return `
      '<label>
        <input type="hidden" name="display-item-counts" value="false" />
        <input type="checkbox" name="display-item-counts" value="true" checked />
        ${i18n.t("blocks:browse_group_categories:item_counts")}
      </label>`
      },
    });
  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Iframe = (function(){

    return SirTrevor.Block.extend({
      type: "Iframe",
      formable: true,
      
      title: function() { return i18n.t('blocks:iframe:title'); },
      description: function() { return i18n.t('blocks:iframe:description'); },

      icon_name: "iframe",
      
      editorHTML: function() {
        return `<div class="clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        <textarea name="code" class="form-control" rows="5" placeholder="${i18n.t("blocks:iframe:placeholder")}"></textarea>
      </div>`;
      }
    });
  })();

  SirTrevor.Blocks.LinkToSearch = (function(){

    return SirTrevor.Blocks.Browse.extend({

      type: "link_to_search",

      icon_name: 'search_results',

      searches_key: "slug",
      view_key: "view",
      plustextable: false,

    });
  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Oembed =  (function(){

    return Spotlight$1.Block.extend({
      plustextable: true,

      id_key:"url",

      type: "oembed",
      
      title: function() { return i18n.t('blocks:oembed:title'); },
      description: function() { return i18n.t('blocks:oembed:description'); },

      icon_name: "oembed",
      show_heading: false,

      editorHTML: function () {
        return `<div class="form oembed-text-admin clearfix">
      <div class="widget-header">
        ${this.description()}
      </div>
      <div class="row">
        <div class="form-group col-md-8">
          <label for="${this.formId(id_key)}">${i18n.t("blocks:oembed:url")}</label>
          <input name="${id_key}" class="form-control col-md-6" type="text" id="${this.formId(id_key)}" />
        </div>
      </div>
      ${this.text_area()}
    </div>`
      }
    });
  })();

  SirTrevor.Blocks.FeaturedPages = (function(){

    return Spotlight$1.Block.Resources.extend({
      type: "featured_pages",

      icon_name: "pages",

      autocomplete_url: function() { return $(this.inner).closest('form[data-autocomplete-exhibit-pages-path]').data('autocomplete-exhibit-pages-path').replace("%25QUERY", "%QUERY"); },
      autocomplete_template: function(obj) {
        const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : '';
        return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${obj.title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`
      },
      bloodhoundOptions: function() {
        return {
          prefetch: {
            url: this.autocomplete_url(),
            ttl: 0
          }
        };
      }
    });

  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Rule = (function(){

    return SirTrevor.Block.extend({
      type: "rule",
      
      title: function() { return i18n.t('blocks:rule:title'); },

      icon_name: "rule",
      
      editorHTML: function() {
        return '<hr />'
      }
    });
  })();

  //= require spotlight/admin/blocks/browse_block

  SirTrevor.Blocks.SearchResults =  (function(){

    return SirTrevor.Blocks.Browse.extend({

      type: "search_results",

      icon_name: 'search_results',

      searches_key: "slug",
      view_key: "view",
      plustextable: false,

      content: function() {
        return this.items_selector()
      },

      item_options: function() {
        var block = this;
        var fields = $('[data-blacklight-configuration-search-views]').data('blacklight-configuration-search-views');

        return $.map(fields, function(field) {
          return `<div>
          <label for='${block.formId(block.view_key + field.key)}'>
            <input id='${block.formId(block.view_key + field.key)}' name='${block.view_key}[]' type='checkbox' value='${field.key}' />
          ${field.label}
          </label>
        </div>`
        }).join("\n");
      },

      afterPanelRender: function(data, panel) {
        $(this.inner).find('.item-input-field').attr("disabled", "disabled");
      },

      afterPanelDelete: function() {
        $(this.inner).find('.item-input-field').removeAttr("disabled");
      },

    });
  })();

  SirTrevor.Blocks.SolrDocumentsBase = (function(){

    return Spotlight$1.Block.Resources.extend({
      plustextable: true,
      autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path').replace("%25QUERY", "%QUERY"); },
      autocomplete_template: function(obj) {
        const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : '';
        return `<div class="autocomplete-item${obj.private ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${obj.title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`
      },
      transform_autocomplete_results: function(response) {
        return $.map(response['docs'], function(doc) {
          return doc;
        })
      },

      caption_option_values: function() {
        var fields = $('[data-blacklight-configuration-index-fields]').data('blacklight-configuration-index-fields');

        return $.map(fields, function(field) {
          return $('<option />').val(field.key).text(field.label)[0].outerHTML;
        }).join("\n");
      },

      item_options: function() { return this.caption_options(); },

      caption_options: function() { return `
      <div class="field-select primary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_primary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.primary_field_key)}" name="${this.show_primary_field_key}" id="${this.formId(this.show_primary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_primary_field_key)}">${i18n.t("blocks:solr_documents:caption:primary")}</label>
        <select data-input-select-target="#${this.formId(this.show_primary_field_key)}" name="${this.primary_field_key}" id="${this.formId(this.primary_field_key)}">
          <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
      <div class="field-select secondary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_secondary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.secondary_field_key)}" name="${this.show_secondary_field_key}" id="${this.formId(this.show_secondary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_secondary_field_key)}">${i18n.t("blocks:solr_documents:caption:secondary")}</label>
        <select data-input-select-target="#${this.formId(this.show_secondary_field_key)}" name="${this.secondary_field_key}" id="${this.formId(this.secondary_field_key)}">
        <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
    `},

      // Sets the first version of the IIIF information from autocomplete data.
      _itemPanelIiifFields: function(index, autocomplete_data) {
        return [
          // '<input type="hidden" name="item[' + index + '][iiif_region]" value="' + (data.iiif_region) + '"/>',
          // for legacy compatiblity:
          '<input type="hidden" name="item[' + index + '][thumbnail_image_url]" value="' + (autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
          '<input type="hidden" name="item[' + index + '][full_image_url]" value="' + (autocomplete_data.full_image_url || autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
          '<input type="hidden" name="item[' + index + '][iiif_tilesource]" value="' + (autocomplete_data.iiif_tilesource) + '"/>',
          '<input type="hidden" name="item[' + index + '][iiif_manifest_url]" value="' + (autocomplete_data.iiif_manifest_url) + '"/>',
          '<input type="hidden" name="item[' + index + '][iiif_canvas_id]" value="' + (autocomplete_data.iiif_canvas_id) + '"/>',
          '<input type="hidden" name="item[' + index + '][iiif_image_id]" value="' + (autocomplete_data.iiif_image_id) + '"/>',
        ].join("\n");
      },
      // Overwrites the hidden inputs from _itemPanelIiifFields with data from the
      // manifest. Called by afterPanelRender - the manifest_data here is built
      // from canvases in the manifest, transformed by spotlight/admin/iiif.js in
      // the #images method.
      setIiifFields: function(panel, manifest_data, initialize) {
        var legacyThumbnailField = $(panel).find('[name$="[thumbnail_image_url]"]');
        var legacyFullField = $(panel).find('[name$="[full_image_url]"]');

        if (initialize && legacyThumbnailField.val().length > 0) {
          return;
        }

        legacyThumbnailField.val("");
        legacyFullField.val("");
        $(panel).find('[name$="[iiif_image_id]"]').val(manifest_data.imageId);
        $(panel).find('[name$="[iiif_tilesource]"]').val(manifest_data.tilesource);
        $(panel).find('[name$="[iiif_manifest_url]"]').val(manifest_data.manifest);
        $(panel).find('[name$="[iiif_canvas_id]"]').val(manifest_data.canvasId);
        $(panel).find('img.img-thumbnail').attr('src', manifest_data.thumbnail_image_url || manifest_data.tilesource.replace("/info.json", "/full/100,100/0/default.jpg"));
      },
      afterPanelRender: function(data, panel) {
        var context = this;
        var manifestUrl = data.iiif_manifest || data.iiif_manifest_url;

        if (!manifestUrl) {
          $(panel).find('[name$="[thumbnail_image_url]"]').val(data.thumbnail_image_url || data.thumbnail);
          $(panel).find('[name$="[full_image_url]"]').val(data.full_image_url);

          return;
        }

        $.ajax(manifestUrl).done(
          function(manifest) {
            var iiifManifest = new Iiif(manifestUrl, manifest);

            var thumbs = iiifManifest.imagesArray();

            if (!data.iiif_image_id) {
              context.setIiifFields(panel, thumbs[0], !!data.iiif_manifest_url);
            }


            if(thumbs.length > 1) {
              panel.multiImageSelector(thumbs, function(selectorImage) {
                context.setIiifFields(panel, selectorImage, false);
              }, data.iiif_image_id);
            }
          }
        );
      }
    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor.Blocks.SolrDocuments = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents",

      icon_name: "items",

      item_options: function() { return this.caption_options() + this.zpr_option(); },

      zpr_option: function() {
        return `
        <div>
        <input name="${this.zpr_key}" type="hidden" value="false" />
        <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
        <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
        </div>
      `
      },

      zpr_key: 'zpr_link'
    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor.Blocks.SolrDocumentsCarousel = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      plustextable: false,
      type: "solr_documents_carousel",

      icon_name: "item_carousel",

      auto_play_images_key: "auto-play-images",
      auto_play_images_interval_key: "auto-play-images-interval",
      max_height_key: "max-height",

      item_options: function() { return "" },

      carouselCycleTimesInSeconds: {
        values: [ 3, 5, 8, 12, 20 ],
        selected: 5
      },

      carouselMaxHeights: {
        values: { 'Small': 'small', 'Medium': 'medium', 'Large': 'large' },
        selected: 'Medium'
      },

      item_options: function() {
        return `${this.caption_options()}
        <div class="field-select auto-cycle-images" data-behavior="auto-cycle-images">
          <input name="${this.auto_play_images_key}" type="hidden" value="false" />
          <input name="${this.auto_play_images_key}" id="${this.formId(this.auto_play_images_key)}" data-key="${this.auto_play_images_key}" type="checkbox" value="true" checked/>
          <label for="${this.formId(this.auto_play_images_key)}">${i18n.t("blocks:solr_documents_carousel:interval:title")}</label>
          <select name="${this.auto_play_images_interval_key}" id="${this.formId(this.auto_play_images_interval_key)}" data=key="${this.auto_play_images_interval_key}">
            <option value="">${i18n.t("blocks:solr_documents_carousel:interval:placeholder")}</option>
            ${this.addCarouselCycleOptions(this.carouselCycleTimesInSeconds)}
          </select>
        </div>
        <div class="field-select max-heights" data-behavior="max-heights">
          <label for="${this.formId(this.max_height_key)}">${i18n.t("blocks:solr_documents_carousel:height:title")}</label><br/>
          ${this.addCarouselMaxHeightOptions(this.carouselMaxHeights)}
        </div>`
      },

      addCarouselCycleOptions: function(options) {
        var html = '';

        $.each(options.values, function(index, interval) {
          var selected = (interval === options.selected) ? 'selected' : '',
              intervalInMilliSeconds = parseInt(interval, 10) * 1000;

          html += '<option value="' + intervalInMilliSeconds + '" ' + selected + '>' + interval + ' seconds</option>';
        });

        return html;
      },

      addCarouselMaxHeightOptions: function(options) {
        var html = '',
            _this = this;

        $.each(options.values, function(size, px) {
          var checked = (size === options.selected) ? 'checked' : '',
              id = _this.formId(_this.max_height_key);

          html += '<input data-key="' + _this.max_height_key + '" type="radio" name="' + id + '" value="' + px + '" id="' + id + '" ' + checked + '>';
          html += '<label class="carousel-size" for="' + id + '">' + size + '</label>';
        });

        return html;
      },

      afterPreviewLoad: function(options) {
        $(this.inner).find('.carousel').carousel();

        // the bootstrap carousel only initializes data-slide widgets on page load, so we need
        // to initialize them ourselves..
        var clickHandler = function (e) {
          var href;
          var $this   = $(this);
          var $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')); // strip for ie7
          if (!$target.hasClass('carousel')) return
          var options = $.extend({}, $target.data(), $this.data());
          var slideIndex = $this.attr('data-slide-to');
          if (slideIndex) options.interval = false;

          $.fn.carousel.call($target, options);

          if (slideIndex) {
            $target.data('bs.carousel').to(slideIndex);
          }

          e.preventDefault();
        };

        $(this.inner).find('.carousel')
          .on('click.bs.carousel.data-api', '[data-slide]', clickHandler)
          .on('click.bs.carousel.data-api', '[data-slide-to]', clickHandler);
      }

    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor.Blocks.SolrDocumentsEmbed = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_embed",

      icon_name: "item_embed",

      item_options: function() { return "" },

      afterPreviewLoad: function(options) {
        $(this.inner).find('picture[data-openseadragon]').openseadragon();
      }
    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor.Blocks.SolrDocumentsFeatures = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      plustextable: false,
      type: "solr_documents_features",

      icon_name: "item_features",

      afterPreviewLoad: function(options) {
        $(this.inner).find('.carousel').carousel();

        // the bootstrap carousel only initializes data-slide widgets on page load, so we need
        // to initialize them ourselves..
        var clickHandler = function (e) {
          var href;
          var $this   = $(this);
          var $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')); // strip for ie7
          if (!$target.hasClass('carousel')) return
          var options = $.extend({}, $target.data(), $this.data());
          var slideIndex = $this.attr('data-slide-to');
          if (slideIndex) options.interval = false;

          $.fn.carousel.call($target, options);

          if (slideIndex) {
            $target.data('bs.carousel').to(slideIndex);
          }

          e.preventDefault();
        };

        $(this.inner).find('.carousel')
          .on('click.bs.carousel.data-api', '[data-slide]', clickHandler)
          .on('click.bs.carousel.data-api', '[data-slide-to]', clickHandler);
      }

    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor.Blocks.SolrDocumentsGrid = (function(){

    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_grid",

      icon_name: "item_grid",


      item_options: function() { return "" }
    });

  })();

  SirTrevor.Blocks.UploadedItems = (function(){
    return Spotlight$1.Block.Resources.extend({
      plustextable: true,
      uploadable: true,
      autocompleteable: false,

      id_key: 'file',

      type: 'uploaded_items',

      icon_name: 'items',

      blockGroup: 'undefined',

      // Clear out the default Uploadable upload options
      // since we will be using our own custom controls
      upload_options: { html: '' },

      fileInput: function() { return $(this.inner).find('input[type="file"]'); },

      onBlockRender: function(){
        Module.init($(this.inner).find('[data-behavior="nestable"]'));

        this.fileInput().on('change', (function(ev) {
          this.onDrop(ev.currentTarget);
        }).bind(this));
      },

      onDrop: function(transferData){
        var file = transferData.files[0];
            (typeof URL !== "undefined") ? URL : (typeof webkitURL !== "undefined") ? webkitURL : null;

        // Handle one upload at a time
        if (/image/.test(file.type)) {
          this.loading();

          this.uploader(
            file,
            function(data) {
              this.createItemPanel(data);
              this.fileInput().val('');
              this.ready();
            },
            function(error) {
              this.addMessage(i18n.t('blocks:image:upload_error'));
              this.ready();
            }
          );
        }
      },

      title: function() { return i18n.t('blocks:uploaded_items:title'); },
      description: function() { return i18n.t('blocks:uploaded_items:description'); },

      globalIndex: 0,

      _itemPanel: function(data) {
        var index = "file_" + this.globalIndex++;
        var checked = 'checked="checked"';

        if (data.display == 'false') {
          checked = '';
        }

        var dataId = data.id || data.uid;
        var dataTitle = data.title || data.name;
        var dataUrl = data.url || data.file.url;

        var markup = `
          <li class="field form-inline dd-item dd3-item" data-id="${index}" id="${this.formId("item_" + dataId)}">
            <input type="hidden" name="item[${index}][id]" value="${dataId}" />
            <input type="hidden" name="item[${index}][title]" value="${dataTitle}" />
            <input type="hidden" name="item[${index}][url]" data-item-grid-thumbnail="true"  value="${dataUrl}"/>
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="card-header d-flex item-grid">
                <div class="checkbox">
                  <input name="item[${index}][display]" type="hidden" value="false" />
                  <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + dataId)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                  <label class="sr-only" for="${this.formId(this.display_checkbox + '_' + dataId)}">${i18n.t("blocks:resources:panel:display")}</label>
                </div>
                <div class="pic">
                  <img class="img-thumbnail" src="${dataUrl}" />
                </div>
                <div class="main form-horizontal">
                  <div class="title card-title">${dataTitle}</div>
                  <div class="field row mr-3">
                    <label for="${this.formId('caption_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:caption")}</label>
                    <input type="text" class="form-control col" id="${this.formId('caption_' + dataId)}" name="item[${index}][caption]" data-field="caption"/>
                  </div>
                  <div class="field row mr-3">
                    <label for="${this.formId('link_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:link")}</label>
                    <input type="text" class="form-control col" id="${this.formId('link_' + dataId)}" name="item[${index}][link]" data-field="link"/>
                  </div>
                </div>
                <div class="remove float-right">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </li>`;

        const panel = $(markup);
        panel.find('[data-field="caption"]').val(data.caption);
        panel.find('[data-field="link"]').val(data.link);
        var context = this;

        $('.remove a', panel).on('click', function(e) {
          e.preventDefault();
          $(this).closest('.field').remove();
          context.afterPanelDelete();
        });

        this.afterPanelRender(data, panel);

        return panel;
      },

      editorHTML: function() {
        return `<div class="form oembed-text-admin clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        <div class="row">
          <div class="form-group col-md-8">
            <div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">
              <ol class="dd-list">
              </ol>
            </div>
            <input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />
          </div>
          <div class="col-md-4">
            <input name="${this.zpr_key}" type="hidden" value="false" />
            <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key=${this.zpr_key}" type="checkbox" value="true" />
            <label for="${this.formId(this.zpr_key)}">${ i18n.t("blocks:solr_documents:zpr:title")}</label>
          </div>
        </div>
        ${this.text_area()}
      </div>`
      },

      zpr_key: 'zpr_link'
    });
  })();

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

    Spotlight$1.BlockControls = function() { };
    Spotlight$1.BlockControls.create = function(editor) {
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

      $(editor.wrapper).delegate(".st-block-replacer", "click", insert);
      $(editor.wrapper).delegate(".st-block-controls__button", "click", insert);

      return {
        el: el,
        hide: hide,
        destroy: destroy
      };
    };
  })();

  Spotlight$1.BlockLimits = function(editor) {
    this.editor = editor;
  };

  Spotlight$1.BlockLimits.prototype.enforceLimits = function(editor) {
    this.addEditorCallbacks(editor);
    this.checkGlobalBlockTypeLimit()();
  };

  Spotlight$1.BlockLimits.prototype.addEditorCallbacks = function(editor) {
    SirTrevor.EventBus.on('block:create:new', this.checkBlockTypeLimitOnAdd());
    SirTrevor.EventBus.on('block:remove', this.checkGlobalBlockTypeLimit());
  };

  Spotlight$1.BlockLimits.prototype.checkBlockTypeLimitOnAdd = function() {
    var editor = this.editor;

    return function(block) {
      var control = $(".st-block-controls__button[data-type='" + block.type + "']", editor.blockControls.el);

      control.prop("disabled", !editor.blockManager.canCreateBlock(block.class()));
    };
  };

  Spotlight$1.BlockLimits.prototype.checkGlobalBlockTypeLimit = function() {
    // we don't know what type of block was created or removed.. So, try them all.
    var editor = this.editor;

    return function() {
      $.each(editor.blockManager.blockTypes, function(i, type) {
        var block_type = SirTrevor.Blocks[type].prototype;

        var control = $(editor.blockControls.el).find(".st-block-controls__button[data-type='" + block_type.type + "']");
        control.prop("disabled", !editor.blockManager.canCreateBlock(type));
      });
    };
  };

  SirTrevor.Locales.en.blocks = $.extend(SirTrevor.Locales.en.blocks, {
    autocompleteable: {
      placeholder: "Enter a title..."
    },

    browse: {
      title: "Browse Categories",
      description: "This widget highlights browse categories. Each highlighted category links to the corresponding browse category results page.",
      item_counts: "Include item counts?"
    },

    browse_group_categories: {
      autocomplete: "Enter a browse group title...",
      title: "Browse Group Categories",
      description: "This widget displays all browse categories associated with a selected browse group as a horizontally-scrolling row. Each selected browse group is displayed as a separate row. Each displayed category in a group links to the corresponding browse category results page.",
      item_counts: "Include category item counts?"
    },

    link_to_search: {
      title: "Saved Searches",
      description: "This widget highlights saved searches. Each highlighted saved search links to the search results page generated by the saved search parameters. Any saved search listed on the Curation > Browse categories page, whether published or not, can be highlighted as a saved search.",
      item_counts: "Include item counts?"
    },

    iframe: {
      title:  "IFrame",
      description: "This widget embeds iframe-based embed code into pages",
      placeholder: "Enter embed code here. It should begin with e.g. '<iframe'"
    },

    oembed: {
      title: "Embed + Text",
      description: "This widget embeds an oEmbed-supported web resource and a text block to the left or right of it. Examples of oEmbed-supported resources include those from YouTube, Twitter, Flickr, and SlideShare.",
      url: "URL",
    },

    uploaded_items: {
      title: "Uploaded Item Row",
      description: "This widget displays uploaded items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items. The item caption and link URL fields are also optional.",
      caption: 'Caption',
      link: 'Link URL'
    },

    featured_pages: {
      title:  "Pages",
      description: "This widget highlights pages from this exhibit. Each highlighted item links to the corresponding page."
    },

    resources: {
      panel: {
        drag: "Drag",
        display: "Display?",
        remove: "Remove"
      }
    },

    rule: {
      title: "Horizontal Rule"
    },

    search_results: {
      title: "Search Results",
      description: "This widget displays a set of search results on a page. Specify a search result set by selecting an existing browse category. You can also select the view types that are available to the user when viewing the result set."
    },

    solr_documents: {
      title: "Item Row",
      description: "This widget displays exhibit items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items.",
      caption: {
        placeholder: "Select...",
        primary: "Primary caption",
        secondary: "Secondary caption"
      },
      zpr: {
        title: 'Offer "View larger" option'
      }
    },

    solr_documents_carousel: {
      title: "Item Carousel",
      description: "This widget displays exhibit items in a carousel. You can configure the item captions, how the images are cycled, and the size of the carousel.",
      interval: {
        title: "Automatically cycle images",
        placeholder: "Select..."
      },
      height: {
        title: "Maximum carousel height"
      }
    },

    solr_documents_embed: {
      title: "Item Embed",
      description: "This widget embeds an exhibit item in a viewer on a page. Optionally, you can add a heading to be displayed above the viewer and/or text to be displayed adjacent to the viewer.",
    },

    solr_documents_features: {
      title: "Item Slideshow",
      description: "This widget displays exhibit items in a static slideshow. The user will move between items in the slideshow using the field you select as the primary caption."
    },

    solr_documents_grid: {
      title: "Item Grid",
      description: "This widget displays exhibit items in a multi-row grid. Optionally, you can add a heading and/or text to be displayed adjacent to the items."
    },

    textable: {
      heading: "Heading",
      text: "Text",
      align: {
        title: "Display text on:",
        left: "Left",
        right: "Right"
      }
    },

    group: {
      undefined: "Standard widgets",
      items: "Exhibit item widgets"
    }
  });

  // These scripts are in the vendor directory


  class AdminIndex {
    connect() {
      new AddAnother().connect();
      new AddNewButton().connect();
      new Appearance().connect();
      new CopyEmailAddress().connect();
      new Croppable().connect();
      new EditInPlace().connect();
      new ExhibitTagAutocomplete().connect();
      new Exhibits().connect();
      new FormObserver().connect();
      new Locks().connect();
      new BlacklightConfiguration().connect();
      new Pages().connect();
      new ProgressMonitor().connect();
      new ReadonlyCheckbox().connect();
      new SelectRelatedInput().connect();
      new Tabs().connect();
      new TranslationProgress().connect();
      new Users().connect();
      addAutocompletetoFeaturedImage();
      Module.init();
    }
  }

  Spotlight$1.onLoad(() => {
    new UserIndex().connect();
    new AdminIndex().connect();
  });

  return Spotlight$1;

}));
//# sourceMappingURL=spotlight.js.map
