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
    var $input = $clearBtn.prev('#browse_q');
    var btnCheck = function(){
      if ($input.val() !== '') {
        $clearBtn.css('display', 'block');
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

class ZprLinks {
  connect() {
    $('.zpr-link').on('click', function() {
      var modalDialog = $('#blacklight-modal .modal-dialog');
      var modalContent = modalDialog.find('.modal-content');
      modalDialog.removeClass('modal-lg');
      modalDialog.addClass('modal-xl');
      modalContent.html('<div id="osd-modal-container"></div>');
      var controls = `<div class="controls d-flex justify-content-center justify-content-md-end">
          <div class="custom-close-controls pr-3 pe-3 pt-3">
            <button type="button" class="btn btn-dark" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true">${Spotlight.ZprLinks.close}</button>
          </div>
          <div class="zoom-controls mb-3 mr-md-3 me-md-3">
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
            var delim = "-";

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

/* From https://github.com/TimSchlechter/bootstrap-tagsinput/blob/2661784c2c281d3a69b93897ff3f39e4ffa5cbd1/dist/bootstrap-tagsinput.js */

/* The MIT License (MIT)

Copyright (c) 2013 Tim Schlechter

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/* Retrieved 12 February 2014 */

(function ($) {

  var defaultOptions = {
    tagClass: function(item) {
      return 'badge badge-info bg-info';
    },
    itemValue: function(item) {
      return item ? item.toString() : item;
    },
    itemText: function(item) {
      return this.itemValue(item);
    },
    freeInput: true,
    maxTags: undefined,
    confirmKeys: [13],
    onTagExists: function(item, $tag) {
      $tag.hide().fadeIn();
    }
  };

  /**
   * Constructor function
   */
  function TagsInput(element, options) {
    this.itemsArray = [];

    this.$element = $(element);
    this.$element.hide();

    this.isSelect = (element.tagName === 'SELECT');
    this.multiple = (this.isSelect && element.hasAttribute('multiple'));
    this.objectItems = options && options.itemValue;
    this.placeholderText = element.hasAttribute('placeholder') ? this.$element.attr('placeholder') : '';
    this.inputSize = Math.max(1, this.placeholderText.length);

    this.$container = $('<div class="bootstrap-tagsinput"></div>');
    this.$input = $('<input size="' + this.inputSize + '" type="text" placeholder="' + this.placeholderText + '"/>').appendTo(this.$container);

    this.$element.after(this.$container);

    this.build(options);
  }

  TagsInput.prototype = {
    constructor: TagsInput,

    /**
     * Adds the given item as a new tag. Pass true to dontPushVal to prevent
     * updating the elements val()
     */
    add: function(item, dontPushVal) {
      var self = this;

      if (self.options.maxTags && self.itemsArray.length >= self.options.maxTags)
        return;

      // Ignore falsey values, except false
      if (item !== false && !item)
        return;

      // Throw an error when trying to add an object while the itemValue option was not set
      if (typeof item === "object" && !self.objectItems)
        throw("Can't add objects when itemValue option is not set");

      // Ignore strings only containg whitespace
      if (item.toString().match(/^\s*$/))
        return;

      // If SELECT but not multiple, remove current tag
      if (self.isSelect && !self.multiple && self.itemsArray.length > 0)
        self.remove(self.itemsArray[0]);

      if (typeof item === "string" && this.$element[0].tagName === 'INPUT') {
        var items = item.split(',');
        if (items.length > 1) {
          for (var i = 0; i < items.length; i++) {
            this.add(items[i], true);
          }

          if (!dontPushVal)
            self.pushVal();
          return;
        }
      }

      var itemValue = self.options.itemValue(item),
          itemText = self.options.itemText(item),
          tagClass = self.options.tagClass(item);

      // Ignore items allready added
      var existing = $.grep(self.itemsArray, function(item) { return self.options.itemValue(item) === itemValue; } )[0];
      if (existing) {
        // Invoke onTagExists
        if (self.options.onTagExists) {
          var $existingTag = $(".tag", self.$container).filter(function() { return $(this).data("item") === existing; });
          self.options.onTagExists(item, $existingTag);
        }
        return;
      }

      // register item in internal array and map
      self.itemsArray.push(item);

      // add a tag element
      var $tag = $('<span class="tag ' + htmlEncode(tagClass) + '">' + htmlEncode(itemText) + '<span data-role="remove"></span></span>');
      $tag.data('item', item);
      self.findInputWrapper().before($tag);
      $tag.after(' ');

      // add <option /> if item represents a value not present in one of the <select />'s options
      if (self.isSelect && !$('option[value="' + escape(itemValue) + '"]',self.$element)[0]) {
        var $option = $('<option selected>' + htmlEncode(itemText) + '</option>');
        $option.data('item', item);
        $option.attr('value', itemValue);
        self.$element.append($option);
      }

      if (!dontPushVal)
        self.pushVal();

      // Add class when reached maxTags
      if (self.options.maxTags === self.itemsArray.length)
        self.$container.addClass('bootstrap-tagsinput-max');

      self.$element.trigger($.Event('itemAdded', { item: item }));
    },

    /**
     * Removes the given item. Pass true to dontPushVal to prevent updating the
     * elements val()
     */
    remove: function(item, dontPushVal) {
      var self = this;

      if (self.objectItems) {
        if (typeof item === "object")
          item = $.grep(self.itemsArray, function(other) { return self.options.itemValue(other) ==  self.options.itemValue(item); } )[0];
        else
          item = $.grep(self.itemsArray, function(other) { return self.options.itemValue(other) ==  item; } )[0];
      }

      if (item) {
        $('.tag', self.$container).filter(function() { return $(this).data('item') === item; }).remove();
        $('option', self.$element).filter(function() { return $(this).data('item') === item; }).remove();
        self.itemsArray.splice($.inArray(item, self.itemsArray), 1);
      }

      if (!dontPushVal)
        self.pushVal();

      // Remove class when reached maxTags
      if (self.options.maxTags > self.itemsArray.length)
        self.$container.removeClass('bootstrap-tagsinput-max');

      self.$element.trigger($.Event('itemRemoved',  { item: item }));
    },

    /**
     * Removes all items
     */
    removeAll: function() {
      var self = this;

      $('.tag', self.$container).remove();
      $('option', self.$element).remove();

      while(self.itemsArray.length > 0)
        self.itemsArray.pop();

      self.pushVal();

      if (self.options.maxTags && !this.isEnabled())
        this.enable();
    },

    /**
     * Refreshes the tags so they match the text/value of their corresponding
     * item.
     */
    refresh: function() {
      var self = this;
      $('.tag', self.$container).each(function() {
        var $tag = $(this),
            item = $tag.data('item'),
            itemValue = self.options.itemValue(item),
            itemText = self.options.itemText(item),
            tagClass = self.options.tagClass(item);

          // Update tag's class and inner text
          $tag.attr('class', null);
          $tag.addClass('tag ' + htmlEncode(tagClass));
          $tag.contents().filter(function() {
            return this.nodeType == 3;
          })[0].nodeValue = htmlEncode(itemText);

          if (self.isSelect) {
            var option = $('option', self.$element).filter(function() { return $(this).data('item') === item; });
            option.attr('value', itemValue);
          }
      });
    },

    /**
     * Returns the items added as tags
     */
    items: function() {
      return this.itemsArray;
    },

    /**
     * Assembly value by retrieving the value of each item, and set it on the
     * element. 
     */
    pushVal: function() {
      var self = this,
          val = $.map(self.items(), function(item) {
            return self.options.itemValue(item).toString();
          });

      self.$element.val(val, true).trigger('change');
    },

    /**
     * Initializes the tags input behaviour on the element
     */
    build: function(options) {
      var self = this;

      self.options = $.extend({}, defaultOptions, options);
      var typeahead = self.options.typeahead || {};

      // When itemValue is set, freeInput should always be false
      if (self.objectItems)
        self.options.freeInput = false;

      makeOptionItemFunction(self.options, 'itemValue');
      makeOptionItemFunction(self.options, 'itemText');
      makeOptionItemFunction(self.options, 'tagClass');

      // for backwards compatibility, self.options.source is deprecated
      if (self.options.source)
        typeahead.source = self.options.source;

      if (typeahead.source && $.fn.typeahead) {
        makeOptionFunction(typeahead, 'source');

        self.$input.typeahead({
          source: function (query, process) {
            function processItems(items) {
              var texts = [];

              for (var i = 0; i < items.length; i++) {
                var text = self.options.itemText(items[i]);
                map[text] = items[i];
                texts.push(text);
              }
              process(texts);
            }

            this.map = {};
            var map = this.map,
                data = typeahead.source(query);

            if ($.isFunction(data.success)) {
              // support for Angular promises
              data.success(processItems);
            } else {
              // support for functions and jquery promises
              $.when(data)
               .then(processItems);
            }
          },
          updater: function (text) {
            self.add(this.map[text]);
          },
          matcher: function (text) {
            return (text.toLowerCase().indexOf(this.query.trim().toLowerCase()) !== -1);
          },
          sorter: function (texts) {
            return texts.sort();
          },
          highlighter: function (text) {
            var regex = new RegExp( '(' + this.query + ')', 'gi' );
            return text.replace( regex, "<strong>$1</strong>" );
          }
        });
      }

      self.$container.on('click', $.proxy(function(event) {
        self.$input.focus();
      }, self));

      self.$container.on('keydown', 'input', $.proxy(function(event) {
        var $input = $(event.target),
            $inputWrapper = self.findInputWrapper();

        switch (event.which) {
          // BACKSPACE
          case 8:
            if (doGetCaretPosition($input[0]) === 0) {
              var prev = $inputWrapper.prev();
              if (prev) {
                self.remove(prev.data('item'));
              }
            }
            break;

          // DELETE
          case 46:
            if (doGetCaretPosition($input[0]) === 0) {
              var next = $inputWrapper.next();
              if (next) {
                self.remove(next.data('item'));
              }
            }
            break;

          // LEFT ARROW
          case 37:
            // Try to move the input before the previous tag
            var $prevTag = $inputWrapper.prev();
            if ($input.val().length === 0 && $prevTag[0]) {
              $prevTag.before($inputWrapper);
              $input.focus();
            }
            break;
          // RIGHT ARROW
          case 39:
            // Try to move the input after the next tag
            var $nextTag = $inputWrapper.next();
            if ($input.val().length === 0 && $nextTag[0]) {
              $nextTag.after($inputWrapper);
              $input.focus();
            }
            break;
         default:
            // When key corresponds one of the confirmKeys, add current input
            // as a new tag
            if (self.options.freeInput && $.inArray(event.which, self.options.confirmKeys) >= 0) {
              self.add($input.val());
              $input.val('');
              event.preventDefault();
            }
        }

        // Reset internal input's size
        $input.attr('size', Math.max(this.inputSize, $input.val().length));
      }, self));

      // Remove icon clicked
      self.$container.on('click', '[data-role=remove]', $.proxy(function(event) {
        self.remove($(event.target).closest('.tag').data('item'));
      }, self));

      // Only add existing value as tags when using strings as tags
      if (self.options.itemValue === defaultOptions.itemValue) {
        if (self.$element[0].tagName === 'INPUT') {
            self.add(self.$element.val());
        } else {
          $('option', self.$element).each(function() {
            self.add($(this).attr('value'), true);
          });
        }
      }
    },

    /**
     * Removes all tagsinput behaviour and unregsiter all event handlers
     */
    destroy: function() {
      var self = this;

      // Unbind events
      self.$container.off('keypress', 'input');
      self.$container.off('click', '[role=remove]');

      self.$container.remove();
      self.$element.removeData('tagsinput');
      self.$element.show();
    },

    /**
     * Sets focus on the tagsinput 
     */
    focus: function() {
      this.$input.focus();
    },

    /**
     * Returns the internal input element
     */
    input: function() {
      return this.$input;
    },

    /**
     * Returns the element which is wrapped around the internal input. This
     * is normally the $container, but typeahead.js moves the $input element.
     */
    findInputWrapper: function() {
      var elt = this.$input[0],
          container = this.$container[0];
      while(elt && elt.parentNode !== container)
        elt = elt.parentNode;

      return $(elt);
    }
  };

  /**
   * Register JQuery plugin
   */
  $.fn.tagsinput = function(arg1, arg2) {
    var results = [];

    this.each(function() {
      var tagsinput = $(this).data('tagsinput');

      // Initialize a new tags input
      if (!tagsinput) {
        tagsinput = new TagsInput(this, arg1);
        $(this).data('tagsinput', tagsinput);
        results.push(tagsinput);

        if (this.tagName === 'SELECT') {
          $('option', $(this)).attr('selected', 'selected');
        }

        // Init tags from $(this).val()
        $(this).val($(this).val());
      } else {
        // Invoke function on existing tags input
        var retVal = tagsinput[arg1](arg2);
        if (retVal !== undefined)
          results.push(retVal);
      }
    });

    if ( typeof arg1 == 'string') {
      // Return the results from the invoked function calls
      return results.length > 1 ? results : results[0];
    } else {
      return results;
    }
  };

  $.fn.tagsinput.Constructor = TagsInput;
  
  /**
   * Most options support both a string or number as well as a function as 
   * option value. This function makes sure that the option with the given
   * key in the given options is wrapped in a function
   */
  function makeOptionItemFunction(options, key) {
    if (typeof options[key] !== 'function') {
      var propertyName = options[key];
      options[key] = function(item) { return item[propertyName]; };
    }
  }
  function makeOptionFunction(options, key) {
    if (typeof options[key] !== 'function') {
      var value = options[key];
      options[key] = function() { return value; };
    }
  }
  /**
   * HtmlEncodes the given value
   */
  var htmlEncodeContainer = $('<div />');
  function htmlEncode(value) {
    if (value) {
      return htmlEncodeContainer.text(value).html();
    } else {
      return '';
    }
  }

  /**
   * Returns the position of the caret in the given input field
   * http://flightschool.acylt.com/devnotes/caret-position-woes/
   */
  function doGetCaretPosition(oField) {
    var iCaretPos = 0;
    if (document.selection) {
      oField.focus ();
      var oSel = document.selection.createRange();
      oSel.moveStart ('character', -oField.value.length);
      iCaretPos = oSel.text.length;
    } else if (oField.selectionStart || oField.selectionStart == '0') {
      iCaretPos = oField.selectionStart;
    }
    return (iCaretPos);
  }

  /**
   * Initialize tagsinput behaviour on inputs and selects which have
   * data-role=tagsinput
   */
  $(function() {
    $("input[data-role=tagsinput], select[multiple][data-role=tagsinput]").tagsinput();
  });
})(window.jQuery);

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

class BlacklightConfiguration {
  connect() {
    // Add Select/Deselect all input behavior
    this.addCheckboxToggleBehavior();
    this.addEnableToggleBehavior();
  }
  
  // Add Select/Deselect all behavior for metadata field names for a given view e.g. Item details. 
  addCheckboxToggleBehavior() {
    $("[data-behavior='metadata-select']").each(function(){
      var selectCheckbox = $(this);
      var parentCell = selectCheckbox.parents("th");
      var table = parentCell.closest("table");
      var columnRows = $("tr td:nth-child(" + (parentCell.index() + 1) + ")", table);
      var checkboxes = $("input[type='checkbox']", columnRows);
      updateSelectAllInput(selectCheckbox, columnRows);
      // Add the check/uncheck behavior to the select/deselect all checkbox
      selectCheckbox.on('click', function(e){
        var allChecked = allCheckboxesChecked(columnRows);
        columnRows.each(function(){
          $("input[type='checkbox']", $(this)).prop('checked', !allChecked);
        });
      });
      // When a single checkbox is selected/unselected, the "All" checkbox should be updated accordingly.
      checkboxes.each(function(){
        $(this).on('change', function(){
          updateSelectAllInput(selectCheckbox, columnRows);
        });
      }); 
    });

    // Check number of checkboxes against the number of checked
    // checkboxes to determine if all of them are checked or not
    function allCheckboxesChecked(elements) {
      return ($("input[type='checkbox']", elements).length == $("input[type='checkbox']:checked", elements).length)
    }

    // Check or uncheck the "All" checkbox for each view column, e.g. Item details, List, etc.
    function updateSelectAllInput(checkbox, elements) {
      if ( allCheckboxesChecked(elements) ) {
        checkbox.prop('checked', true);
      } else {
        checkbox.prop('checked', false);
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

    $("[data-behavior='restore-default']").each(function(){
      var hidden = $("[data-default-value]", $(this));
      var value = $($("[data-in-place-edit-target]", $(this)).data('in-place-edit-target'), $(this));
      var button = $("[data-restore-default]", $(this));

      hidden.on('keypress', function(e) {
        if(e.which == 13) {
          hidden.trigger('blur');
          return false;
        }
      });

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

class ExhibitTagAutocomplete {
  connect() {
    $('[data-autocomplete-tag="true"]').each(function(_i, el) {
      var $el = $(el);
      // By default tags input binds on page ready to [data-role=tagsinput],
      // however, that doesn't work with Turbolinks. So we init manually:
      $el.tagsinput();

      var tags = new Bloodhound({
        datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.name); },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit: 100,
        prefetch: {
          url: $el.data('autocomplete-url'),
          ttl: 1,
          filter: function(list) {
            // Let the dom know that the response has been returned
            $el.attr('data-autocomplete-fetched', true);
            return $.map(list, function(tag) { return { name: tag }; });
          }
        }
      });

      tags.initialize();

      $el.tagsinput('input').typeahead({highlight: true, hint: false}, {
        name: 'tags',
        displayKey: 'name',
        source: tags.ttAdapter()
      }).bind('typeahead:selected', $.proxy(function (obj, datum) {
        $el.tagsinput('add', datum.name);
        $el.tagsinput('input').typeahead('val', '');
      })).bind('blur', function() {
        $el.tagsinput('add', $el.tagsinput('input').typeahead('val'));
        $el.tagsinput('input').typeahead('val', '');
      });
    });
  }
}

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
  
const downcode = function( slug )
{
  Downcoder.Initialize() ;
  var downcoded ="";
  var pieces = slug.match(Downcoder.regex);
  if(pieces)
  {
    for (var i = 0 ; i < pieces.length ; i++)
    {
      if (pieces[i].length == 1)
      {
        var mapped = Downcoder.map[pieces[i]] ;
        if (mapped != null)
        {
          downcoded+=mapped;
          continue ;
        }
      }
      downcoded+=pieces[i];
    }
  }
  else
  {
    downcoded = slug;
  }
  return downcoded;
};


function URLify(s, num_chars) {
  // changes, e.g., "Petty theft" to "petty_theft"
  // remove all these words from the string before urlifying
  s = downcode(s);
  //
  // if downcode doesn't hit, the char will be stripped here
  s = s.replace(/[^-\w\s]/g, ' ');  // remove unneeded chars
  s = s.replace(/^\s+|\s+$/g, ''); // trim leading/trailing spaces
  s = s.replace(/[-\s]+/g, '-');   // convert spaces to hyphens
  s = s.toLowerCase();             // convert to lowercase
  return s.substring(0, num_chars);// trim to first num_chars chars
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

(function($, _) {

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
            totalWidth = width += thisThumb.width(),
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
// All this logic will automatically be available in application.js.

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
        altTextSettings: instance.data('altTextSettings'),
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

    function addAutocompleteBehavior( typeAheadInput, _ ) {
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
              var child_node = findNode(id, container);
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
// See: https://github.com/projectblacklight/blacklight/blob/main/app/javascript/blacklight/bookmark_toggle.js


const VisibilityToggle = (e) => {
  if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
    const form = e.target.closest('form');
    if (form) {
      if (!Blacklight.BookmarkToggle) new CheckboxSubmit(form).clicked(e);

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
      const id = $(this).attr('data-target') || $(this).attr('data-bs-target');
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
      const id = $(this).attr('data-target') || $(this).attr('data-bs-target');
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
    alt_text_guidelines: function() {
      if (this.showAltText()) {
        return i18n.t("blocks:alt_text_guidelines:intro"); 
      }
      return "";
    },
    alt_text_guidelines_link: function() {
      if (this.showAltText()) {
        var link_url = i18n.t("blocks:alt_text_guidelines:link_url");
        var link_label = i18n.t("blocks:alt_text_guidelines:link_label");
        return '<a target="_blank" href="' + link_url + '">' +  link_label + '</a>'; 
      }
      return "";
    },
    icon_name: "resources",
    blockGroup: function() { return i18n.t("blocks:group:items") },

    primary_field_key: "primary-caption-field",
    show_primary_field_key: "show-primary-caption",
    secondary_field_key: "secondary-caption-field",
    show_secondary_field_key: "show-secondary-caption",

    display_checkbox: "display-checkbox",
    decorative_checkbox: "decorative-checkbox",
    alt_text_textarea: "alt-text-textarea",

    globalIndex: 0,

    _itemPanelIiifFields: function(index, data) {
      return [];
    },

    _altTextFieldsHTML: function(index, data) {
      if (this.showAltText()) {
        return this.altTextHTML(index, data);
      }
      return "";
    },

    showAltText: function() {
      return this.editorOptions.altTextSettings[this._typeAsCamelCase()]
    },

    _typeAsCamelCase: function() {
      return this.type
          .split('_')
          .map(word => word.charAt(0).toUpperCase() + word.slice(1))
          .join('');
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
                      <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.title}</div>
                      <div>${(data.slug || data.id)}</div>
                      ${this._altTextFieldsHTML(index, data)}
                    </div>
                    <div class="remove float-right float-end">
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
      this.attachAltTextHandlers(panel);
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
        '<div class="form-group mb-3">',
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
          ${this.alt_text_guidelines()}
          ${this.alt_text_guidelines_link()}
        </div>
        ${this.content()}
      </div>`
    },

    _altTextData: function(data) {
      const isDecorative = data.decorative;
      const altText = isDecorative ? '' : (data.alt_text || '');
      const altTextBackup = data.alt_text_backup || '';
      const placeholderAttr = isDecorative ? '' : `placeholder="${i18n.t("blocks:resources:alt_text:placeholder")}"`;
      const disabledAttr = isDecorative ? 'disabled' : '';

      return { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr };
    },

    altTextHTML: function(index, data) {
      const { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr } = this._altTextData(data);
      return `<div class="mt-2 pt-2 d-flex">
          <div class="me-2 mr-2">
            <label class="col-form-label pb-0 pt-1" for="${this.formId(this.alt_text_textarea + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
            <div class="form-check mb-1 justify-content-end">
              <input class="form-check-input" type="checkbox" 
                id="${this.formId(this.decorative_checkbox + '_' + data.id)}" name="item[${index}][decorative]" ${isDecorative ? 'checked' : ''}>
              <label class="form-check-label" for="${this.formId(this.decorative_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
            </div>
          </div>
          <div class="flex-grow-1 flex-fill d-flex">
            <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
            <textarea class="form-control w-100" rows="2" ${placeholderAttr}
              id="${this.formId(this.alt_text_textarea + '_' + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
          </div>
        </div>`
    },

    attachAltTextHandlers: function(panel) {
      if (this.showAltText()) {
        const decorativeCheckbox = $('input[name$="[decorative]"]', panel);
        const altTextInput = $('textarea[name$="[alt_text]"]', panel);
        const altTextBackupInput = $('input[name$="[alt_text_backup]"]', panel);

        decorativeCheckbox.on('change', function() {
          const isDecorative = this.checked;
          if (isDecorative) {
            altTextBackupInput.val(altTextInput.val());
            altTextInput.val('');
          } else {
            altTextInput.val(altTextBackupInput.val());
          }
          altTextInput
            .prop('disabled', isDecorative)
            .attr('placeholder', isDecorative ? '' : i18n.t("blocks:resources:alt_text:placeholder"));
        });

        altTextInput.on('input', function() {
          $(this).data('lastValue', $(this).val());
        });
      }
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
                      <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${(data.full_title || data.title)}</div>
                      <div>${(data.slug || data.id)}</div>
                    </div>
                    <div class="remove float-right float-end">
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
                    <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
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
      <label>
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
        <div class="form-group mb-3 col-md-8">
          <label for="${this.formId(this.id_key)}">${i18n.t("blocks:oembed:url")}</label>
          <input name="${this.id_key}" class="form-control col-md-6" type="text" id="${this.formId(this.id_key)}" />
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

      // the bootstrap carousel only initializes data-bs-slide widgets on page load, so we need
      // to initialize them ourselves..
      var clickHandler = function (e) {
        var href;
        var $this   = $(this);
        var $target = $($this.attr('data-target') || $this.attr('data-bs-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')); // strip for ie7
        if (!$target.hasClass('carousel')) return
        var options = $.extend({}, $target.data(), $this.data());
        var slideIndex = $this.attr('data-slide-to') || $this.attr('data-bs-slide-to');
        if (slideIndex) options.interval = false;

        $.fn.carousel.call($target, options);

        if (slideIndex) {
          $target.data('bs.carousel').to(slideIndex);
        }

        e.preventDefault();
      };

      $(this.inner).find('.carousel')
        .on('click.bs.carousel.data-api', '[data-slide], [data-bs-slide]', clickHandler)
        .on('click.bs.carousel.data-api', '[data-slide-to], [data-bs-slide-to]', clickHandler);
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

      // the bootstrap carousel only initializes data-bs-slide widgets on page load, so we need
      // to initialize them ourselves..
      var clickHandler = function (e) {
        var href;
        var $this   = $(this);
        var $target = $($this.attr('data-target') || $this.attr('data-bs-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')); // strip for ie7
        if (!$target.hasClass('carousel')) return
        var options = $.extend({}, $target.data(), $this.data());
        var slideIndex = $this.attr('data-slide-to') || $this.attr('data-bs-slide-to');
        if (slideIndex) options.interval = false;

        $.fn.carousel.call($target, options);

        if (slideIndex) {
          $target.data('bs.carousel').to(slideIndex);
        }

        e.preventDefault();
      };

      $(this.inner).find('.carousel')
        .on('click.bs.carousel.data-api', '[data-slide], [data-bs-slide]', clickHandler)
        .on('click.bs.carousel.data-api', '[data-slide-to], [data-bs-slide-to]', clickHandler);
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
                  <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + dataId)}">${i18n.t("blocks:resources:panel:display")}</label>
                </div>
                <div class="pic">
                  <img class="img-thumbnail" src="${dataUrl}" />
                </div>
                <div class="main form-horizontal">
                  <div class="title card-title">${dataTitle}</div>
                  <div class="field row mr-3 me-3">
                    <label for="${this.formId('caption_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:caption")}</label>
                    <input type="text" class="form-control col" id="${this.formId('caption_' + dataId)}" name="item[${index}][caption]" data-field="caption"/>
                  </div>
                  <div class="field row mr-3 me-3">
                    <label for="${this.formId('link_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:link")}</label>
                    <input type="text" class="form-control col" id="${this.formId('link_' + dataId)}" name="item[${index}][link]" data-field="link"/>
                  </div>
                  ${this._altTextFieldsHTML(index, data)}
                </div>
                <div class="remove float-right float-end">
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
          ${this.alt_text_guidelines()}
          ${this.alt_text_guidelines_link()}
        </div>
        <div class="row">
          <div class="form-group mb-3 col-md-8">
            <div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">
              <ol class="dd-list">
              </ol>
            </div>
            <input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />
          </div>
          <div class="col-md-4">
            <input name="${this.zpr_key}" type="hidden" value="false" />
            <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
            <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
          </div>
        </div>
        ${this.text_area()}
      </div>`
    },

    altTextHTML: function(index, data) {
      const { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr } = this._altTextData(data);
      return `
      <div class="field row mr-3 me-3">
        <div class="col-lg-3 ps-md-2 pl-md-2">
          <label class="col-form-label text-nowrap pb-0 pt-1 justify-content-md-start justify-content-lg-end d-flex" for="${this.formId(this.alt_text_textarea + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
          <div class="form-check d-flex justify-content-md-start justify-content-lg-end">
            <input class="form-check-input" type="checkbox" 
              id="${this.formId(this.decorative_checkbox + '_' + data.id)}" name="item[${index}][decorative]" ${isDecorative ? 'checked' : ''}>
            <label class="form-check-label" for="${this.formId(this.decorative_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
          </div>
        </div>
        <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
        <textarea class="col-lg-9" rows="2" ${placeholderAttr}
          id="${this.formId(this.alt_text_textarea + '_' + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
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
    },
    alt_text: {
      decorative: "Decorative",
      alternative_text: "Alternative text",
      placeholder: "Enter alt text for this item..."
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
  },

  alt_text_guidelines: {
    intro: 'For each item, please enter alternative text or appropriately check the decorative box. ',
    link_label: 'Guidelines for writing alt text.',
    link_url: 'https://www.w3.org/WAI/tutorials/images/' 
  }
});

// These scripts are in the vendor directory


class AdminIndex {
  connect() {
    new AddAnother().connect();
    new AddNewButton().connect();
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

export { Spotlight$1 as default };
//# sourceMappingURL=spotlight.esm.js.map
