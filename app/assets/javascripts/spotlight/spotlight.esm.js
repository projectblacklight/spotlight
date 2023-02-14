class Analytics {
  connect() {
    if (window._gaq != null) {
      return _gaq.push(['_trackPageview']);
    } else if (window.pageTracker != null) {
      return pageTracker._trackPageview();
    }
  }
}

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
      target_val = container.attr('data-target');
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
    new Analytics().connect();
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
      return 'badge badge-info';
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

!function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var c="function"==typeof require&&require;if(!u&&c)return c(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var a=n[o]={exports:{}};t[o][0].call(a.exports,function(n){var r=t[o][1][n];return s(r?r:n)},a,a.exports,e,t,n,r);}return n[o].exports}for(var i="function"==typeof require&&require,o=0;o<r.length;o++)s(r[o]);return s}({1:[function(t,n,r){(function(n){function define(t,n,e){t[n]||Object[r](t,n,{writable:!0,configurable:!0,value:e});}if(t(295),t(296),t(2),n._babelPolyfill)throw new Error("only one instance of babel-polyfill is allowed");n._babelPolyfill=!0;var r="defineProperty";define(String.prototype,"padLeft","".padStart),define(String.prototype,"padRight","".padEnd),"pop,reverse,shift,keys,values,entries,indexOf,every,some,forEach,map,filter,find,findIndex,includes,join,slice,concat,push,splice,unshift,sort,lastIndexOf,reduce,reduceRight,copyWithin,fill".split(",").forEach(function(t){[][t]&&define(Array,t,Function.call.bind([][t]));});}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{});},{2:2,295:295,296:296}],2:[function(t,n,r){t(119),n.exports=t(23).RegExp.escape;},{119:119,23:23}],3:[function(t,n,r){n.exports=function(t){if("function"!=typeof t)throw TypeError(t+" is not a function!");return t};},{}],4:[function(t,n,r){var e=t(18);n.exports=function(t,n){if("number"!=typeof t&&"Number"!=e(t))throw TypeError(n);return +t};},{18:18}],5:[function(t,n,r){var e=t(117)("unscopables"),i=Array.prototype;void 0==i[e]&&t(40)(i,e,{}),n.exports=function(t){i[e][t]=!0;};},{117:117,40:40}],6:[function(t,n,r){n.exports=function(t,n,r,e){if(!(t instanceof n)||void 0!==e&&e in t)throw TypeError(r+": incorrect invocation!");return t};},{}],7:[function(t,n,r){var e=t(49);n.exports=function(t){if(!e(t))throw TypeError(t+" is not an object!");return t};},{49:49}],8:[function(t,n,r){var e=t(109),i=t(105),o=t(108);n.exports=[].copyWithin||function copyWithin(t,n){var r=e(this),u=o(r.length),c=i(t,u),f=i(n,u),a=arguments.length>2?arguments[2]:void 0,s=Math.min((void 0===a?u:i(a,u))-f,u-c),l=1;for(f<c&&c<f+s&&(l=-1,f+=s-1,c+=s-1);s-- >0;)f in r?r[c]=r[f]:delete r[c],c+=l,f+=l;return r};},{105:105,108:108,109:109}],9:[function(t,n,r){var e=t(109),i=t(105),o=t(108);n.exports=function fill(t){for(var n=e(this),r=o(n.length),u=arguments.length,c=i(u>1?arguments[1]:void 0,r),f=u>2?arguments[2]:void 0,a=void 0===f?r:i(f,r);a>c;)n[c++]=t;return n};},{105:105,108:108,109:109}],10:[function(t,n,r){var e=t(37);n.exports=function(t,n){var r=[];return e(t,!1,r.push,r,n),r};},{37:37}],11:[function(t,n,r){var e=t(107),i=t(108),o=t(105);n.exports=function(t){return function(n,r,u){var c,f=e(n),a=i(f.length),s=o(u,a);if(t&&r!=r){for(;a>s;)if(c=f[s++],c!=c)return !0}else for(;a>s;s++)if((t||s in f)&&f[s]===r)return t||s||0;return !t&&-1}};},{105:105,107:107,108:108}],12:[function(t,n,r){var e=t(25),i=t(45),o=t(109),u=t(108),c=t(15);n.exports=function(t,n){var r=1==t,f=2==t,a=3==t,s=4==t,l=6==t,h=5==t||l,v=n||c;return function(n,c,p){for(var d,y,g=o(n),b=i(g),x=e(c,p,3),m=u(b.length),w=0,S=r?v(n,m):f?v(n,0):void 0;m>w;w++)if((h||w in b)&&(d=b[w],y=x(d,w,g),t))if(r)S[w]=y;else if(y)switch(t){case 3:return !0;case 5:return d;case 6:return w;case 2:S.push(d);}else if(s)return !1;return l?-1:a||s?s:S}};},{108:108,109:109,15:15,25:25,45:45}],13:[function(t,n,r){var e=t(3),i=t(109),o=t(45),u=t(108);n.exports=function(t,n,r,c,f){e(n);var a=i(t),s=o(a),l=u(a.length),h=f?l-1:0,v=f?-1:1;if(r<2)for(;;){if(h in s){c=s[h],h+=v;break}if(h+=v,f?h<0:l<=h)throw TypeError("Reduce of empty array with no initial value")}for(;f?h>=0:l>h;h+=v)h in s&&(c=n(c,s[h],h,a));return c};},{108:108,109:109,3:3,45:45}],14:[function(t,n,r){var e=t(49),i=t(47),o=t(117)("species");n.exports=function(t){var n;return i(t)&&(n=t.constructor,"function"!=typeof n||n!==Array&&!i(n.prototype)||(n=void 0),e(n)&&(n=n[o],null===n&&(n=void 0))),void 0===n?Array:n};},{117:117,47:47,49:49}],15:[function(t,n,r){var e=t(14);n.exports=function(t,n){return new(e(t))(n)};},{14:14}],16:[function(t,n,r){var e=t(3),i=t(49),o=t(44),u=[].slice,c={},f=function(t,n,r){if(!(n in c)){for(var e=[],i=0;i<n;i++)e[i]="a["+i+"]";c[n]=Function("F,a","return new F("+e.join(",")+")");}return c[n](t,r)};n.exports=Function.bind||function bind(t){var n=e(this),r=u.call(arguments,1),c=function(){var e=r.concat(u.call(arguments));return this instanceof c?f(n,e.length,e):o(n,e,t)};return i(n.prototype)&&(c.prototype=n.prototype),c};},{3:3,44:44,49:49}],17:[function(t,n,r){var e=t(18),i=t(117)("toStringTag"),o="Arguments"==e(function(){return arguments}()),u=function(t,n){try{return t[n]}catch(t){}};n.exports=function(t){var n,r,c;return void 0===t?"Undefined":null===t?"Null":"string"==typeof(r=u(n=Object(t),i))?r:o?e(n):"Object"==(c=e(n))&&"function"==typeof n.callee?"Arguments":c};},{117:117,18:18}],18:[function(t,n,r){var e={}.toString;n.exports=function(t){return e.call(t).slice(8,-1)};},{}],19:[function(t,n,r){var e=t(67).f,i=t(66),o=t(86),u=t(25),c=t(6),f=t(27),a=t(37),s=t(53),l=t(55),h=t(91),v=t(28),p=t(62).fastKey,d=v?"_s":"size",y=function(t,n){var r,e=p(n);if("F"!==e)return t._i[e];for(r=t._f;r;r=r.n)if(r.k==n)return r};n.exports={getConstructor:function(t,n,r,s){var l=t(function(t,e){c(t,l,n,"_i"),t._i=i(null),t._f=void 0,t._l=void 0,t[d]=0,void 0!=e&&a(e,r,t[s],t);});return o(l.prototype,{clear:function clear(){for(var t=this,n=t._i,r=t._f;r;r=r.n)r.r=!0,r.p&&(r.p=r.p.n=void 0),delete n[r.i];t._f=t._l=void 0,t[d]=0;},delete:function(t){var n=this,r=y(n,t);if(r){var e=r.n,i=r.p;delete n._i[r.i],r.r=!0,i&&(i.n=e),e&&(e.p=i),n._f==r&&(n._f=e),n._l==r&&(n._l=i),n[d]--;}return !!r},forEach:function forEach(t){c(this,l,"forEach");for(var n,r=u(t,arguments.length>1?arguments[1]:void 0,3);n=n?n.n:this._f;)for(r(n.v,n.k,this);n&&n.r;)n=n.p;},has:function has(t){return !!y(this,t)}}),v&&e(l.prototype,"size",{get:function(){return f(this[d])}}),l},def:function(t,n,r){var e,i,o=y(t,n);return o?o.v=r:(t._l=o={i:i=p(n,!0),k:n,v:r,p:e=t._l,n:void 0,r:!1},t._f||(t._f=o),e&&(e.n=o),t[d]++,"F"!==i&&(t._i[i]=o)),t},getEntry:y,setStrong:function(t,n,r){s(t,n,function(t,n){this._t=t,this._k=n,this._l=void 0;},function(){for(var t=this,n=t._k,r=t._l;r&&r.r;)r=r.p;return t._t&&(t._l=r=r?r.n:t._t._f)?"keys"==n?l(0,r.k):"values"==n?l(0,r.v):l(0,[r.k,r.v]):(t._t=void 0,l(1))},r?"entries":"values",!r,!0),h(n);}};},{25:25,27:27,28:28,37:37,53:53,55:55,6:6,62:62,66:66,67:67,86:86,91:91}],20:[function(t,n,r){var e=t(17),i=t(10);n.exports=function(t){return function toJSON(){if(e(this)!=t)throw TypeError(t+"#toJSON isn't generic");return i(this)}};},{10:10,17:17}],21:[function(t,n,r){var e=t(86),i=t(62).getWeak,o=t(7),u=t(49),c=t(6),f=t(37),a=t(12),s=t(39),l=a(5),h=a(6),v=0,p=function(t){return t._l||(t._l=new d)},d=function(){this.a=[];},y=function(t,n){return l(t.a,function(t){return t[0]===n})};d.prototype={get:function(t){var n=y(this,t);if(n)return n[1]},has:function(t){return !!y(this,t)},set:function(t,n){var r=y(this,t);r?r[1]=n:this.a.push([t,n]);},delete:function(t){var n=h(this.a,function(n){return n[0]===t});return ~n&&this.a.splice(n,1),!!~n}},n.exports={getConstructor:function(t,n,r,o){var a=t(function(t,e){c(t,a,n,"_i"),t._i=v++,t._l=void 0,void 0!=e&&f(e,r,t[o],t);});return e(a.prototype,{delete:function(t){if(!u(t))return !1;var n=i(t);return n===!0?p(this).delete(t):n&&s(n,this._i)&&delete n[this._i]},has:function has(t){if(!u(t))return !1;var n=i(t);return n===!0?p(this).has(t):n&&s(n,this._i)}}),a},def:function(t,n,r){var e=i(o(n),!0);return e===!0?p(t).set(n,r):e[t._i]=r,t},ufstore:p};},{12:12,37:37,39:39,49:49,6:6,62:62,7:7,86:86}],22:[function(t,n,r){var e=t(38),i=t(32),o=t(87),u=t(86),c=t(62),f=t(37),a=t(6),s=t(49),l=t(34),h=t(54),v=t(92),p=t(43);n.exports=function(t,n,r,d,y,g){var b=e[t],x=b,m=y?"set":"add",w=x&&x.prototype,S={},_=function(t){var n=w[t];o(w,t,"delete"==t?function(t){return !(g&&!s(t))&&n.call(this,0===t?0:t)}:"has"==t?function has(t){return !(g&&!s(t))&&n.call(this,0===t?0:t)}:"get"==t?function get(t){return g&&!s(t)?void 0:n.call(this,0===t?0:t)}:"add"==t?function add(t){return n.call(this,0===t?0:t),this}:function set(t,r){return n.call(this,0===t?0:t,r),this});};if("function"==typeof x&&(g||w.forEach&&!l(function(){(new x).entries().next();}))){var E=new x,O=E[m](g?{}:-0,1)!=E,F=l(function(){E.has(1);}),P=h(function(t){new x(t);}),M=!g&&l(function(){for(var t=new x,n=5;n--;)t[m](n,n);return !t.has(-0)});P||(x=n(function(n,r){a(n,x,t);var e=p(new b,n,x);return void 0!=r&&f(r,y,e[m],e),e}),x.prototype=w,w.constructor=x),(F||M)&&(_("delete"),_("has"),y&&_("get")),(M||O)&&_(m),g&&w.clear&&delete w.clear;}else x=d.getConstructor(n,t,y,m),u(x.prototype,r),c.NEED=!0;return v(x,t),S[t]=x,i(i.G+i.W+i.F*(x!=b),S),g||d.setStrong(x,t,y),x};},{32:32,34:34,37:37,38:38,43:43,49:49,54:54,6:6,62:62,86:86,87:87,92:92}],23:[function(t,n,r){var e=n.exports={version:"2.4.0"};"number"==typeof __e&&(__e=e);},{}],24:[function(t,n,r){var e=t(67),i=t(85);n.exports=function(t,n,r){n in t?e.f(t,n,i(0,r)):t[n]=r;};},{67:67,85:85}],25:[function(t,n,r){var e=t(3);n.exports=function(t,n,r){if(e(t),void 0===n)return t;switch(r){case 1:return function(r){return t.call(n,r)};case 2:return function(r,e){return t.call(n,r,e)};case 3:return function(r,e,i){return t.call(n,r,e,i)}}return function(){return t.apply(n,arguments)}};},{3:3}],26:[function(t,n,r){var e=t(7),i=t(110),o="number";n.exports=function(t){if("string"!==t&&t!==o&&"default"!==t)throw TypeError("Incorrect hint");return i(e(this),t!=o)};},{110:110,7:7}],27:[function(t,n,r){n.exports=function(t){if(void 0==t)throw TypeError("Can't call method on  "+t);return t};},{}],28:[function(t,n,r){n.exports=!t(34)(function(){return 7!=Object.defineProperty({},"a",{get:function(){return 7}}).a});},{34:34}],29:[function(t,n,r){var e=t(49),i=t(38).document,o=e(i)&&e(i.createElement);n.exports=function(t){return o?i.createElement(t):{}};},{38:38,49:49}],30:[function(t,n,r){n.exports="constructor,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,toLocaleString,toString,valueOf".split(",");},{}],31:[function(t,n,r){var e=t(76),i=t(73),o=t(77);n.exports=function(t){var n=e(t),r=i.f;if(r)for(var u,c=r(t),f=o.f,a=0;c.length>a;)f.call(t,u=c[a++])&&n.push(u);return n};},{73:73,76:76,77:77}],32:[function(t,n,r){var e=t(38),i=t(23),o=t(40),u=t(87),c=t(25),f="prototype",a=function(t,n,r){var s,l,h,v,p=t&a.F,d=t&a.G,y=t&a.S,g=t&a.P,b=t&a.B,x=d?e:y?e[n]||(e[n]={}):(e[n]||{})[f],m=d?i:i[n]||(i[n]={}),w=m[f]||(m[f]={});d&&(r=n);for(s in r)l=!p&&x&&void 0!==x[s],h=(l?x:r)[s],v=b&&l?c(h,e):g&&"function"==typeof h?c(Function.call,h):h,x&&u(x,s,h,t&a.U),m[s]!=h&&o(m,s,v),g&&w[s]!=h&&(w[s]=h);};e.core=i,a.F=1,a.G=2,a.S=4,a.P=8,a.B=16,a.W=32,a.U=64,a.R=128,n.exports=a;},{23:23,25:25,38:38,40:40,87:87}],33:[function(t,n,r){var e=t(117)("match");n.exports=function(t){var n=/./;try{"/./"[t](n);}catch(r){try{return n[e]=!1,!"/./"[t](n)}catch(t){}}return !0};},{117:117}],34:[function(t,n,r){n.exports=function(t){try{return !!t()}catch(t){return !0}};},{}],35:[function(t,n,r){var e=t(40),i=t(87),o=t(34),u=t(27),c=t(117);n.exports=function(t,n,r){var f=c(t),a=r(u,f,""[t]),s=a[0],l=a[1];o(function(){var n={};return n[f]=function(){return 7},7!=""[t](n)})&&(i(String.prototype,t,s),e(RegExp.prototype,f,2==n?function(t,n){return l.call(t,this,n)}:function(t){return l.call(t,this)}));};},{117:117,27:27,34:34,40:40,87:87}],36:[function(t,n,r){var e=t(7);n.exports=function(){var t=e(this),n="";return t.global&&(n+="g"),t.ignoreCase&&(n+="i"),t.multiline&&(n+="m"),t.unicode&&(n+="u"),t.sticky&&(n+="y"),n};},{7:7}],37:[function(t,n,r){var e=t(25),i=t(51),o=t(46),u=t(7),c=t(108),f=t(118),a={},s={},r=n.exports=function(t,n,r,l,h){var v,p,d,y,g=h?function(){return t}:f(t),b=e(r,l,n?2:1),x=0;if("function"!=typeof g)throw TypeError(t+" is not iterable!");if(o(g)){for(v=c(t.length);v>x;x++)if(y=n?b(u(p=t[x])[0],p[1]):b(t[x]),y===a||y===s)return y}else for(d=g.call(t);!(p=d.next()).done;)if(y=i(d,b,p.value,n),y===a||y===s)return y};r.BREAK=a,r.RETURN=s;},{108:108,118:118,25:25,46:46,51:51,7:7}],38:[function(t,n,r){var e=n.exports="undefined"!=typeof window&&window.Math==Math?window:"undefined"!=typeof self&&self.Math==Math?self:Function("return this")();"number"==typeof __g&&(__g=e);},{}],39:[function(t,n,r){var e={}.hasOwnProperty;n.exports=function(t,n){return e.call(t,n)};},{}],40:[function(t,n,r){var e=t(67),i=t(85);n.exports=t(28)?function(t,n,r){return e.f(t,n,i(1,r))}:function(t,n,r){return t[n]=r,t};},{28:28,67:67,85:85}],41:[function(t,n,r){n.exports=t(38).document&&document.documentElement;},{38:38}],42:[function(t,n,r){n.exports=!t(28)&&!t(34)(function(){return 7!=Object.defineProperty(t(29)("div"),"a",{get:function(){return 7}}).a});},{28:28,29:29,34:34}],43:[function(t,n,r){var e=t(49),i=t(90).set;n.exports=function(t,n,r){var o,u=n.constructor;return u!==r&&"function"==typeof u&&(o=u.prototype)!==r.prototype&&e(o)&&i&&i(t,o),t};},{49:49,90:90}],44:[function(t,n,r){n.exports=function(t,n,r){var e=void 0===r;switch(n.length){case 0:return e?t():t.call(r);case 1:return e?t(n[0]):t.call(r,n[0]);case 2:return e?t(n[0],n[1]):t.call(r,n[0],n[1]);case 3:return e?t(n[0],n[1],n[2]):t.call(r,n[0],n[1],n[2]);case 4:return e?t(n[0],n[1],n[2],n[3]):t.call(r,n[0],n[1],n[2],n[3])}return t.apply(r,n)};},{}],45:[function(t,n,r){var e=t(18);n.exports=Object("z").propertyIsEnumerable(0)?Object:function(t){return "String"==e(t)?t.split(""):Object(t)};},{18:18}],46:[function(t,n,r){var e=t(56),i=t(117)("iterator"),o=Array.prototype;n.exports=function(t){return void 0!==t&&(e.Array===t||o[i]===t)};},{117:117,56:56}],47:[function(t,n,r){var e=t(18);n.exports=Array.isArray||function isArray(t){return "Array"==e(t)};},{18:18}],48:[function(t,n,r){var e=t(49),i=Math.floor;n.exports=function isInteger(t){return !e(t)&&isFinite(t)&&i(t)===t};},{49:49}],49:[function(t,n,r){n.exports=function(t){return "object"==typeof t?null!==t:"function"==typeof t};},{}],50:[function(t,n,r){var e=t(49),i=t(18),o=t(117)("match");n.exports=function(t){var n;return e(t)&&(void 0!==(n=t[o])?!!n:"RegExp"==i(t))};},{117:117,18:18,49:49}],51:[function(t,n,r){var e=t(7);n.exports=function(t,n,r,i){try{return i?n(e(r)[0],r[1]):n(r)}catch(n){var o=t.return;throw void 0!==o&&e(o.call(t)),n}};},{7:7}],52:[function(t,n,r){var e=t(66),i=t(85),o=t(92),u={};t(40)(u,t(117)("iterator"),function(){return this}),n.exports=function(t,n,r){t.prototype=e(u,{next:i(1,r)}),o(t,n+" Iterator");};},{117:117,40:40,66:66,85:85,92:92}],53:[function(t,n,r){var e=t(58),i=t(32),o=t(87),u=t(40),c=t(39),f=t(56),a=t(52),s=t(92),l=t(74),h=t(117)("iterator"),v=!([].keys&&"next"in[].keys()),p="@@iterator",d="keys",y="values",g=function(){return this};n.exports=function(t,n,r,b,x,m,w){a(r,n,b);var S,_,E,O=function(t){if(!v&&t in A)return A[t];switch(t){case d:return function keys(){return new r(this,t)};case y:return function values(){return new r(this,t)}}return function entries(){return new r(this,t)}},F=n+" Iterator",P=x==y,M=!1,A=t.prototype,I=A[h]||A[p]||x&&A[x],j=I||O(x),N=x?P?O("entries"):j:void 0,k="Array"==n?A.entries||I:I;if(k&&(E=l(k.call(new t)),E!==Object.prototype&&(s(E,F,!0),e||c(E,h)||u(E,h,g))),P&&I&&I.name!==y&&(M=!0,j=function values(){return I.call(this)}),e&&!w||!v&&!M&&A[h]||u(A,h,j),f[n]=j,f[F]=g,x)if(S={values:P?j:O(y),keys:m?j:O(d),entries:N},w)for(_ in S)_ in A||o(A,_,S[_]);else i(i.P+i.F*(v||M),n,S);return S};},{117:117,32:32,39:39,40:40,52:52,56:56,58:58,74:74,87:87,92:92}],54:[function(t,n,r){var e=t(117)("iterator"),i=!1;try{var o=[7][e]();o.return=function(){i=!0;},Array.from(o,function(){throw 2});}catch(t){}n.exports=function(t,n){if(!n&&!i)return !1;var r=!1;try{var o=[7],u=o[e]();u.next=function(){return {done:r=!0}},o[e]=function(){return u},t(o);}catch(t){}return r};},{117:117}],55:[function(t,n,r){n.exports=function(t,n){return {value:n,done:!!t}};},{}],56:[function(t,n,r){n.exports={};},{}],57:[function(t,n,r){var e=t(76),i=t(107);n.exports=function(t,n){for(var r,o=i(t),u=e(o),c=u.length,f=0;c>f;)if(o[r=u[f++]]===n)return r};},{107:107,76:76}],58:[function(t,n,r){n.exports=!1;},{}],59:[function(t,n,r){var e=Math.expm1;n.exports=!e||e(10)>22025.465794806718||e(10)<22025.465794806718||e(-2e-17)!=-2e-17?function expm1(t){return 0==(t=+t)?t:t>-1e-6&&t<1e-6?t+t*t/2:Math.exp(t)-1}:e;},{}],60:[function(t,n,r){n.exports=Math.log1p||function log1p(t){return (t=+t)>-1e-8&&t<1e-8?t-t*t/2:Math.log(1+t)};},{}],61:[function(t,n,r){n.exports=Math.sign||function sign(t){return 0==(t=+t)||t!=t?t:t<0?-1:1};},{}],62:[function(t,n,r){var e=t(114)("meta"),i=t(49),o=t(39),u=t(67).f,c=0,f=Object.isExtensible||function(){return !0},a=!t(34)(function(){return f(Object.preventExtensions({}))}),s=function(t){u(t,e,{value:{i:"O"+ ++c,w:{}}});},l=function(t,n){if(!i(t))return "symbol"==typeof t?t:("string"==typeof t?"S":"P")+t;if(!o(t,e)){if(!f(t))return "F";if(!n)return "E";s(t);}return t[e].i},h=function(t,n){if(!o(t,e)){if(!f(t))return !0;if(!n)return !1;s(t);}return t[e].w},v=function(t){return a&&p.NEED&&f(t)&&!o(t,e)&&s(t),t},p=n.exports={KEY:e,NEED:!1,fastKey:l,getWeak:h,onFreeze:v};},{114:114,34:34,39:39,49:49,67:67}],63:[function(t,n,r){var e=t(149),i=t(32),o=t(94)("metadata"),u=o.store||(o.store=new(t(255))),c=function(t,n,r){var i=u.get(t);if(!i){if(!r)return;u.set(t,i=new e);}var o=i.get(n);if(!o){if(!r)return;i.set(n,o=new e);}return o},f=function(t,n,r){var e=c(n,r,!1);return void 0!==e&&e.has(t)},a=function(t,n,r){var e=c(n,r,!1);return void 0===e?void 0:e.get(t)},s=function(t,n,r,e){c(r,e,!0).set(t,n);},l=function(t,n){var r=c(t,n,!1),e=[];return r&&r.forEach(function(t,n){e.push(n);}),e},h=function(t){return void 0===t||"symbol"==typeof t?t:String(t)},v=function(t){i(i.S,"Reflect",t);};n.exports={store:u,map:c,has:f,get:a,set:s,keys:l,key:h,exp:v};},{149:149,255:255,32:32,94:94}],64:[function(t,n,r){var e=t(38),i=t(104).set,o=e.MutationObserver||e.WebKitMutationObserver,u=e.process,c=e.Promise,f="process"==t(18)(u);n.exports=function(){var t,n,r,a=function(){var e,i;for(f&&(e=u.domain)&&e.exit();t;){i=t.fn,t=t.next;try{i();}catch(e){throw t?r():n=void 0,e}}n=void 0,e&&e.enter();};if(f)r=function(){u.nextTick(a);};else if(o){var s=!0,l=document.createTextNode("");new o(a).observe(l,{characterData:!0}),r=function(){l.data=s=!s;};}else if(c&&c.resolve){var h=c.resolve();r=function(){h.then(a);};}else r=function(){i.call(e,a);};return function(e){var i={fn:e,next:void 0};n&&(n.next=i),t||(t=i,r()),n=i;}};},{104:104,18:18,38:38}],65:[function(t,n,r){var e=t(76),i=t(73),o=t(77),u=t(109),c=t(45),f=Object.assign;n.exports=!f||t(34)(function(){var t={},n={},r=Symbol(),e="abcdefghijklmnopqrst";return t[r]=7,e.split("").forEach(function(t){n[t]=t;}),7!=f({},t)[r]||Object.keys(f({},n)).join("")!=e})?function assign(t,n){for(var r=u(t),f=arguments.length,a=1,s=i.f,l=o.f;f>a;)for(var h,v=c(arguments[a++]),p=s?e(v).concat(s(v)):e(v),d=p.length,y=0;d>y;)l.call(v,h=p[y++])&&(r[h]=v[h]);return r}:f;},{109:109,34:34,45:45,73:73,76:76,77:77}],66:[function(t,n,r){var e=t(7),i=t(68),o=t(30),u=t(93)("IE_PROTO"),c=function(){},f="prototype",a=function(){var n,r=t(29)("iframe"),e=o.length,i="<",u=">";for(r.style.display="none",t(41).appendChild(r),r.src="javascript:",n=r.contentWindow.document,n.open(),n.write(i+"script"+u+"document.F=Object"+i+"/script"+u),n.close(),a=n.F;e--;)delete a[f][o[e]];return a()};n.exports=Object.create||function create(t,n){var r;return null!==t?(c[f]=e(t),r=new c,c[f]=null,r[u]=t):r=a(),void 0===n?r:i(r,n)};},{29:29,30:30,41:41,68:68,7:7,93:93}],67:[function(t,n,r){var e=t(7),i=t(42),o=t(110),u=Object.defineProperty;r.f=t(28)?Object.defineProperty:function defineProperty(t,n,r){if(e(t),n=o(n,!0),e(r),i)try{return u(t,n,r)}catch(t){}if("get"in r||"set"in r)throw TypeError("Accessors not supported!");return "value"in r&&(t[n]=r.value),t};},{110:110,28:28,42:42,7:7}],68:[function(t,n,r){var e=t(67),i=t(7),o=t(76);n.exports=t(28)?Object.defineProperties:function defineProperties(t,n){i(t);for(var r,u=o(n),c=u.length,f=0;c>f;)e.f(t,r=u[f++],n[r]);return t};},{28:28,67:67,7:7,76:76}],69:[function(t,n,r){n.exports=t(58)||!t(34)(function(){var n=Math.random();__defineSetter__.call(null,n,function(){}),delete t(38)[n];});},{34:34,38:38,58:58}],70:[function(t,n,r){var e=t(77),i=t(85),o=t(107),u=t(110),c=t(39),f=t(42),a=Object.getOwnPropertyDescriptor;r.f=t(28)?a:function getOwnPropertyDescriptor(t,n){if(t=o(t),n=u(n,!0),f)try{return a(t,n)}catch(t){}if(c(t,n))return i(!e.f.call(t,n),t[n])};},{107:107,110:110,28:28,39:39,42:42,77:77,85:85}],71:[function(t,n,r){var e=t(107),i=t(72).f,o={}.toString,u="object"==typeof window&&window&&Object.getOwnPropertyNames?Object.getOwnPropertyNames(window):[],c=function(t){try{return i(t)}catch(t){return u.slice()}};n.exports.f=function getOwnPropertyNames(t){return u&&"[object Window]"==o.call(t)?c(t):i(e(t))};},{107:107,72:72}],72:[function(t,n,r){var e=t(75),i=t(30).concat("length","prototype");r.f=Object.getOwnPropertyNames||function getOwnPropertyNames(t){return e(t,i)};},{30:30,75:75}],73:[function(t,n,r){r.f=Object.getOwnPropertySymbols;},{}],74:[function(t,n,r){var e=t(39),i=t(109),o=t(93)("IE_PROTO"),u=Object.prototype;n.exports=Object.getPrototypeOf||function(t){return t=i(t),e(t,o)?t[o]:"function"==typeof t.constructor&&t instanceof t.constructor?t.constructor.prototype:t instanceof Object?u:null};},{109:109,39:39,93:93}],75:[function(t,n,r){var e=t(39),i=t(107),o=t(11)(!1),u=t(93)("IE_PROTO");n.exports=function(t,n){var r,c=i(t),f=0,a=[];for(r in c)r!=u&&e(c,r)&&a.push(r);for(;n.length>f;)e(c,r=n[f++])&&(~o(a,r)||a.push(r));return a};},{107:107,11:11,39:39,93:93}],76:[function(t,n,r){var e=t(75),i=t(30);n.exports=Object.keys||function keys(t){return e(t,i)};},{30:30,75:75}],77:[function(t,n,r){r.f={}.propertyIsEnumerable;},{}],78:[function(t,n,r){var e=t(32),i=t(23),o=t(34);n.exports=function(t,n){var r=(i.Object||{})[t]||Object[t],u={};u[t]=n(r),e(e.S+e.F*o(function(){r(1);}),"Object",u);};},{23:23,32:32,34:34}],79:[function(t,n,r){var e=t(76),i=t(107),o=t(77).f;n.exports=function(t){return function(n){for(var r,u=i(n),c=e(u),f=c.length,a=0,s=[];f>a;)o.call(u,r=c[a++])&&s.push(t?[r,u[r]]:u[r]);return s}};},{107:107,76:76,77:77}],80:[function(t,n,r){var e=t(72),i=t(73),o=t(7),u=t(38).Reflect;n.exports=u&&u.ownKeys||function ownKeys(t){var n=e.f(o(t)),r=i.f;return r?n.concat(r(t)):n};},{38:38,7:7,72:72,73:73}],81:[function(t,n,r){var e=t(38).parseFloat,i=t(102).trim;n.exports=1/e(t(103)+"-0")!==-(1/0)?function parseFloat(t){var n=i(String(t),3),r=e(n);return 0===r&&"-"==n.charAt(0)?-0:r}:e;},{102:102,103:103,38:38}],82:[function(t,n,r){var e=t(38).parseInt,i=t(102).trim,o=t(103),u=/^[\-+]?0[xX]/;n.exports=8!==e(o+"08")||22!==e(o+"0x16")?function parseInt(t,n){var r=i(String(t),3);return e(r,n>>>0||(u.test(r)?16:10))}:e;},{102:102,103:103,38:38}],83:[function(t,n,r){var e=t(84),i=t(44),o=t(3);n.exports=function(){for(var t=o(this),n=arguments.length,r=Array(n),u=0,c=e._,f=!1;n>u;)(r[u]=arguments[u++])===c&&(f=!0);return function(){var e,o=this,u=arguments.length,a=0,s=0;if(!f&&!u)return i(t,r,o);if(e=r.slice(),f)for(;n>a;a++)e[a]===c&&(e[a]=arguments[s++]);for(;u>s;)e.push(arguments[s++]);return i(t,e,o)}};},{3:3,44:44,84:84}],84:[function(t,n,r){n.exports=t(38);},{38:38}],85:[function(t,n,r){n.exports=function(t,n){return {enumerable:!(1&t),configurable:!(2&t),writable:!(4&t),value:n}};},{}],86:[function(t,n,r){var e=t(87);n.exports=function(t,n,r){for(var i in n)e(t,i,n[i],r);return t};},{87:87}],87:[function(t,n,r){var e=t(38),i=t(40),o=t(39),u=t(114)("src"),c="toString",f=Function[c],a=(""+f).split(c);t(23).inspectSource=function(t){return f.call(t)},(n.exports=function(t,n,r,c){var f="function"==typeof r;f&&(o(r,"name")||i(r,"name",n)),t[n]!==r&&(f&&(o(r,u)||i(r,u,t[n]?""+t[n]:a.join(String(n)))),t===e?t[n]=r:c?t[n]?t[n]=r:i(t,n,r):(delete t[n],i(t,n,r)));})(Function.prototype,c,function toString(){return "function"==typeof this&&this[u]||f.call(this)});},{114:114,23:23,38:38,39:39,40:40}],88:[function(t,n,r){n.exports=function(t,n){var r=n===Object(n)?function(t){return n[t]}:n;return function(n){return String(n).replace(t,r)}};},{}],89:[function(t,n,r){n.exports=Object.is||function is(t,n){return t===n?0!==t||1/t===1/n:t!=t&&n!=n};},{}],90:[function(t,n,r){var e=t(49),i=t(7),o=function(t,n){if(i(t),!e(n)&&null!==n)throw TypeError(n+": can't set as prototype!")};n.exports={set:Object.setPrototypeOf||("__proto__"in{}?function(n,r,e){try{e=t(25)(Function.call,t(70).f(Object.prototype,"__proto__").set,2),e(n,[]),r=!(n instanceof Array);}catch(t){r=!0;}return function setPrototypeOf(t,n){return o(t,n),r?t.__proto__=n:e(t,n),t}}({},!1):void 0),check:o};},{25:25,49:49,7:7,70:70}],91:[function(t,n,r){var e=t(38),i=t(67),o=t(28),u=t(117)("species");n.exports=function(t){var n=e[t];o&&n&&!n[u]&&i.f(n,u,{configurable:!0,get:function(){return this}});};},{117:117,28:28,38:38,67:67}],92:[function(t,n,r){var e=t(67).f,i=t(39),o=t(117)("toStringTag");n.exports=function(t,n,r){t&&!i(t=r?t:t.prototype,o)&&e(t,o,{configurable:!0,value:n});};},{117:117,39:39,67:67}],93:[function(t,n,r){var e=t(94)("keys"),i=t(114);n.exports=function(t){return e[t]||(e[t]=i(t))};},{114:114,94:94}],94:[function(t,n,r){var e=t(38),i="__core-js_shared__",o=e[i]||(e[i]={});n.exports=function(t){return o[t]||(o[t]={})};},{38:38}],95:[function(t,n,r){var e=t(7),i=t(3),o=t(117)("species");n.exports=function(t,n){var r,u=e(t).constructor;return void 0===u||void 0==(r=e(u)[o])?n:i(r)};},{117:117,3:3,7:7}],96:[function(t,n,r){var e=t(34);n.exports=function(t,n){return !!t&&e(function(){n?t.call(null,function(){},1):t.call(null);})};},{34:34}],97:[function(t,n,r){var e=t(106),i=t(27);n.exports=function(t){return function(n,r){var o,u,c=String(i(n)),f=e(r),a=c.length;return f<0||f>=a?t?"":void 0:(o=c.charCodeAt(f),o<55296||o>56319||f+1===a||(u=c.charCodeAt(f+1))<56320||u>57343?t?c.charAt(f):o:t?c.slice(f,f+2):(o-55296<<10)+(u-56320)+65536)}};},{106:106,27:27}],98:[function(t,n,r){var e=t(50),i=t(27);n.exports=function(t,n,r){if(e(n))throw TypeError("String#"+r+" doesn't accept regex!");return String(i(t))};},{27:27,50:50}],99:[function(t,n,r){var e=t(32),i=t(34),o=t(27),u=/"/g,c=function(t,n,r,e){var i=String(o(t)),c="<"+n;return ""!==r&&(c+=" "+r+'="'+String(e).replace(u,"&quot;")+'"'),c+">"+i+"</"+n+">"};n.exports=function(t,n){var r={};r[t]=n(c),e(e.P+e.F*i(function(){var n=""[t]('"');return n!==n.toLowerCase()||n.split('"').length>3}),"String",r);};},{27:27,32:32,34:34}],100:[function(t,n,r){var e=t(108),i=t(101),o=t(27);n.exports=function(t,n,r,u){var c=String(o(t)),f=c.length,a=void 0===r?" ":String(r),s=e(n);if(s<=f||""==a)return c;var l=s-f,h=i.call(a,Math.ceil(l/a.length));return h.length>l&&(h=h.slice(0,l)),u?h+c:c+h};},{101:101,108:108,27:27}],101:[function(t,n,r){var e=t(106),i=t(27);n.exports=function repeat(t){var n=String(i(this)),r="",o=e(t);if(o<0||o==1/0)throw RangeError("Count can't be negative");for(;o>0;(o>>>=1)&&(n+=n))1&o&&(r+=n);return r};},{106:106,27:27}],102:[function(t,n,r){var e=t(32),i=t(27),o=t(34),u=t(103),c="["+u+"]",f="​",a=RegExp("^"+c+c+"*"),s=RegExp(c+c+"*$"),l=function(t,n,r){var i={},c=o(function(){return !!u[t]()||f[t]()!=f}),a=i[t]=c?n(h):u[t];r&&(i[r]=a),e(e.P+e.F*c,"String",i);},h=l.trim=function(t,n){return t=String(i(t)),1&n&&(t=t.replace(a,"")),2&n&&(t=t.replace(s,"")),t};n.exports=l;},{103:103,27:27,32:32,34:34}],103:[function(t,n,r){n.exports="\t\n\v\f\r   ᠎             　\u2028\u2029\ufeff";},{}],104:[function(t,n,r){var e,i,o,u=t(25),c=t(44),f=t(41),a=t(29),s=t(38),l=s.process,h=s.setImmediate,v=s.clearImmediate,p=s.MessageChannel,d=0,y={},g="onreadystatechange",b=function(){var t=+this;if(y.hasOwnProperty(t)){var n=y[t];delete y[t],n();}},x=function(t){b.call(t.data);};h&&v||(h=function setImmediate(t){for(var n=[],r=1;arguments.length>r;)n.push(arguments[r++]);return y[++d]=function(){c("function"==typeof t?t:Function(t),n);},e(d),d},v=function clearImmediate(t){delete y[t];},"process"==t(18)(l)?e=function(t){l.nextTick(u(b,t,1));}:p?(i=new p,o=i.port2,i.port1.onmessage=x,e=u(o.postMessage,o,1)):s.addEventListener&&"function"==typeof postMessage&&!s.importScripts?(e=function(t){s.postMessage(t+"","*");},s.addEventListener("message",x,!1)):e=g in a("script")?function(t){f.appendChild(a("script"))[g]=function(){f.removeChild(this),b.call(t);};}:function(t){setTimeout(u(b,t,1),0);}),n.exports={set:h,clear:v};},{18:18,25:25,29:29,38:38,41:41,44:44}],105:[function(t,n,r){var e=t(106),i=Math.max,o=Math.min;n.exports=function(t,n){return t=e(t),t<0?i(t+n,0):o(t,n)};},{106:106}],106:[function(t,n,r){var e=Math.ceil,i=Math.floor;n.exports=function(t){return isNaN(t=+t)?0:(t>0?i:e)(t)};},{}],107:[function(t,n,r){var e=t(45),i=t(27);n.exports=function(t){return e(i(t))};},{27:27,45:45}],108:[function(t,n,r){var e=t(106),i=Math.min;n.exports=function(t){return t>0?i(e(t),9007199254740991):0};},{106:106}],109:[function(t,n,r){var e=t(27);n.exports=function(t){return Object(e(t))};},{27:27}],110:[function(t,n,r){var e=t(49);n.exports=function(t,n){if(!e(t))return t;var r,i;if(n&&"function"==typeof(r=t.toString)&&!e(i=r.call(t)))return i;if("function"==typeof(r=t.valueOf)&&!e(i=r.call(t)))return i;if(!n&&"function"==typeof(r=t.toString)&&!e(i=r.call(t)))return i;throw TypeError("Can't convert object to primitive value")};},{49:49}],111:[function(t,n,r){if(t(28)){var e=t(58),i=t(38),o=t(34),u=t(32),c=t(113),f=t(112),a=t(25),s=t(6),l=t(85),h=t(40),v=t(86),p=t(106),d=t(108),y=t(105),g=t(110),b=t(39),x=t(89),m=t(17),w=t(49),S=t(109),_=t(46),E=t(66),O=t(74),F=t(72).f,P=t(118),M=t(114),A=t(117),I=t(12),j=t(11),N=t(95),k=t(130),R=t(56),T=t(54),L=t(91),C=t(9),U=t(8),G=t(67),D=t(70),W=G.f,B=D.f,V=i.RangeError,z=i.TypeError,K=i.Uint8Array,J="ArrayBuffer",Y="Shared"+J,q="BYTES_PER_ELEMENT",X="prototype",$=Array[X],H=f.ArrayBuffer,Z=f.DataView,Q=I(0),tt=I(2),nt=I(3),rt=I(4),et=I(5),it=I(6),ot=j(!0),ut=j(!1),ct=k.values,ft=k.keys,at=k.entries,st=$.lastIndexOf,lt=$.reduce,ht=$.reduceRight,vt=$.join,pt=$.sort,dt=$.slice,yt=$.toString,gt=$.toLocaleString,bt=A("iterator"),xt=A("toStringTag"),mt=M("typed_constructor"),wt=M("def_constructor"),St=c.CONSTR,_t=c.TYPED,Et=c.VIEW,Ot="Wrong length!",Ft=I(1,function(t,n){return Nt(N(t,t[wt]),n)}),Pt=o(function(){return 1===new K(new Uint16Array([1]).buffer)[0]}),Mt=!!K&&!!K[X].set&&o(function(){new K(1).set({});}),At=function(t,n){if(void 0===t)throw z(Ot);var r=+t,e=d(t);if(n&&!x(r,e))throw V(Ot);return e},It=function(t,n){var r=p(t);if(r<0||r%n)throw V("Wrong offset!");return r},jt=function(t){if(w(t)&&_t in t)return t;throw z(t+" is not a typed array!")},Nt=function(t,n){if(!(w(t)&&mt in t))throw z("It is not a typed array constructor!");return new t(n)},kt=function(t,n){return Rt(N(t,t[wt]),n)},Rt=function(t,n){for(var r=0,e=n.length,i=Nt(t,e);e>r;)i[r]=n[r++];return i},Tt=function(t,n,r){W(t,n,{get:function(){return this._d[r]}});},Lt=function from(t){var n,r,e,i,o,u,c=S(t),f=arguments.length,s=f>1?arguments[1]:void 0,l=void 0!==s,h=P(c);if(void 0!=h&&!_(h)){for(u=h.call(c),e=[],n=0;!(o=u.next()).done;n++)e.push(o.value);c=e;}for(l&&f>2&&(s=a(s,arguments[2],2)),n=0,r=d(c.length),i=Nt(this,r);r>n;n++)i[n]=l?s(c[n],n):c[n];return i},Ct=function of(){for(var t=0,n=arguments.length,r=Nt(this,n);n>t;)r[t]=arguments[t++];return r},Ut=!!K&&o(function(){gt.call(new K(1));}),Gt=function toLocaleString(){return gt.apply(Ut?dt.call(jt(this)):jt(this),arguments)},Dt={copyWithin:function copyWithin(t,n){return U.call(jt(this),t,n,arguments.length>2?arguments[2]:void 0)},every:function every(t){return rt(jt(this),t,arguments.length>1?arguments[1]:void 0)},fill:function fill(t){return C.apply(jt(this),arguments)},filter:function filter(t){return kt(this,tt(jt(this),t,arguments.length>1?arguments[1]:void 0))},find:function find(t){return et(jt(this),t,arguments.length>1?arguments[1]:void 0)},findIndex:function findIndex(t){
return it(jt(this),t,arguments.length>1?arguments[1]:void 0)},forEach:function forEach(t){Q(jt(this),t,arguments.length>1?arguments[1]:void 0);},indexOf:function indexOf(t){return ut(jt(this),t,arguments.length>1?arguments[1]:void 0)},includes:function includes(t){return ot(jt(this),t,arguments.length>1?arguments[1]:void 0)},join:function join(t){return vt.apply(jt(this),arguments)},lastIndexOf:function lastIndexOf(t){return st.apply(jt(this),arguments)},map:function map(t){return Ft(jt(this),t,arguments.length>1?arguments[1]:void 0)},reduce:function reduce(t){return lt.apply(jt(this),arguments)},reduceRight:function reduceRight(t){return ht.apply(jt(this),arguments)},reverse:function reverse(){for(var t,n=this,r=jt(n).length,e=Math.floor(r/2),i=0;i<e;)t=n[i],n[i++]=n[--r],n[r]=t;return n},some:function some(t){return nt(jt(this),t,arguments.length>1?arguments[1]:void 0)},sort:function sort(t){return pt.call(jt(this),t)},subarray:function subarray(t,n){var r=jt(this),e=r.length,i=y(t,e);return new(N(r,r[wt]))(r.buffer,r.byteOffset+i*r.BYTES_PER_ELEMENT,d((void 0===n?e:y(n,e))-i))}},Wt=function slice(t,n){return kt(this,dt.call(jt(this),t,n))},Bt=function set(t){jt(this);var n=It(arguments[1],1),r=this.length,e=S(t),i=d(e.length),o=0;if(i+n>r)throw V(Ot);for(;o<i;)this[n+o]=e[o++];},Vt={entries:function entries(){return at.call(jt(this))},keys:function keys(){return ft.call(jt(this))},values:function values(){return ct.call(jt(this))}},zt=function(t,n){return w(t)&&t[_t]&&"symbol"!=typeof n&&n in t&&String(+n)==String(n)},Kt=function getOwnPropertyDescriptor(t,n){return zt(t,n=g(n,!0))?l(2,t[n]):B(t,n)},Jt=function defineProperty(t,n,r){return !(zt(t,n=g(n,!0))&&w(r)&&b(r,"value"))||b(r,"get")||b(r,"set")||r.configurable||b(r,"writable")&&!r.writable||b(r,"enumerable")&&!r.enumerable?W(t,n,r):(t[n]=r.value,t)};St||(D.f=Kt,G.f=Jt),u(u.S+u.F*!St,"Object",{getOwnPropertyDescriptor:Kt,defineProperty:Jt}),o(function(){yt.call({});})&&(yt=gt=function toString(){return vt.call(this)});var Yt=v({},Dt);v(Yt,Vt),h(Yt,bt,Vt.values),v(Yt,{slice:Wt,set:Bt,constructor:function(){},toString:yt,toLocaleString:Gt}),Tt(Yt,"buffer","b"),Tt(Yt,"byteOffset","o"),Tt(Yt,"byteLength","l"),Tt(Yt,"length","e"),W(Yt,xt,{get:function(){return this[_t]}}),n.exports=function(t,n,r,f){f=!!f;var a=t+(f?"Clamped":"")+"Array",l="Uint8Array"!=a,v="get"+t,p="set"+t,y=i[a],g=y||{},b=y&&O(y),x=!y||!c.ABV,S={},_=y&&y[X],P=function(t,r){var e=t._d;return e.v[v](r*n+e.o,Pt)},M=function(t,r,e){var i=t._d;f&&(e=(e=Math.round(e))<0?0:e>255?255:255&e),i.v[p](r*n+i.o,e,Pt);},A=function(t,n){W(t,n,{get:function(){return P(this,n)},set:function(t){return M(this,n,t)},enumerable:!0});};x?(y=r(function(t,r,e,i){s(t,y,a,"_d");var o,u,c,f,l=0,v=0;if(w(r)){if(!(r instanceof H||(f=m(r))==J||f==Y))return _t in r?Rt(y,r):Lt.call(y,r);o=r,v=It(e,n);var p=r.byteLength;if(void 0===i){if(p%n)throw V(Ot);if(u=p-v,u<0)throw V(Ot)}else if(u=d(i)*n,u+v>p)throw V(Ot);c=u/n;}else c=At(r,!0),u=c*n,o=new H(u);for(h(t,"_d",{b:o,o:v,l:u,e:c,v:new Z(o)});l<c;)A(t,l++);}),_=y[X]=E(Yt),h(_,"constructor",y)):T(function(t){new y(null),new y(t);},!0)||(y=r(function(t,r,e,i){s(t,y,a);var o;return w(r)?r instanceof H||(o=m(r))==J||o==Y?void 0!==i?new g(r,It(e,n),i):void 0!==e?new g(r,It(e,n)):new g(r):_t in r?Rt(y,r):Lt.call(y,r):new g(At(r,l))}),Q(b!==Function.prototype?F(g).concat(F(b)):F(g),function(t){t in y||h(y,t,g[t]);}),y[X]=_,e||(_.constructor=y));var I=_[bt],j=!!I&&("values"==I.name||void 0==I.name),N=Vt.values;h(y,mt,!0),h(_,_t,a),h(_,Et,!0),h(_,wt,y),(f?new y(1)[xt]==a:xt in _)||W(_,xt,{get:function(){return a}}),S[a]=y,u(u.G+u.W+u.F*(y!=g),S),u(u.S,a,{BYTES_PER_ELEMENT:n,from:Lt,of:Ct}),q in _||h(_,q,n),u(u.P,a,Dt),L(a),u(u.P+u.F*Mt,a,{set:Bt}),u(u.P+u.F*!j,a,Vt),u(u.P+u.F*(_.toString!=yt),a,{toString:yt}),u(u.P+u.F*o(function(){new y(1).slice();}),a,{slice:Wt}),u(u.P+u.F*(o(function(){return [1,2].toLocaleString()!=new y([1,2]).toLocaleString()})||!o(function(){_.toLocaleString.call([1,2]);})),a,{toLocaleString:Gt}),R[a]=j?I:N,e||j||h(_,bt,N);};}else n.exports=function(){};},{105:105,106:106,108:108,109:109,11:11,110:110,112:112,113:113,114:114,117:117,118:118,12:12,130:130,17:17,25:25,28:28,32:32,34:34,38:38,39:39,40:40,46:46,49:49,54:54,56:56,58:58,6:6,66:66,67:67,70:70,72:72,74:74,8:8,85:85,86:86,89:89,9:9,91:91,95:95}],112:[function(t,n,r){var e=t(38),i=t(28),o=t(58),u=t(113),c=t(40),f=t(86),a=t(34),s=t(6),l=t(106),h=t(108),v=t(72).f,p=t(67).f,d=t(9),y=t(92),g="ArrayBuffer",b="DataView",x="prototype",m="Wrong length!",w="Wrong index!",S=e[g],_=e[b],E=e.Math,O=e.RangeError,F=e.Infinity,P=S,M=E.abs,A=E.pow,I=E.floor,j=E.log,N=E.LN2,k="buffer",R="byteLength",T="byteOffset",L=i?"_b":k,C=i?"_l":R,U=i?"_o":T,G=function(t,n,r){var e,i,o,u=Array(r),c=8*r-n-1,f=(1<<c)-1,a=f>>1,s=23===n?A(2,-24)-A(2,-77):0,l=0,h=t<0||0===t&&1/t<0?1:0;for(t=M(t),t!=t||t===F?(i=t!=t?1:0,e=f):(e=I(j(t)/N),t*(o=A(2,-e))<1&&(e--,o*=2),t+=e+a>=1?s/o:s*A(2,1-a),t*o>=2&&(e++,o/=2),e+a>=f?(i=0,e=f):e+a>=1?(i=(t*o-1)*A(2,n),e+=a):(i=t*A(2,a-1)*A(2,n),e=0));n>=8;u[l++]=255&i,i/=256,n-=8);for(e=e<<n|i,c+=n;c>0;u[l++]=255&e,e/=256,c-=8);return u[--l]|=128*h,u},D=function(t,n,r){var e,i=8*r-n-1,o=(1<<i)-1,u=o>>1,c=i-7,f=r-1,a=t[f--],s=127&a;for(a>>=7;c>0;s=256*s+t[f],f--,c-=8);for(e=s&(1<<-c)-1,s>>=-c,c+=n;c>0;e=256*e+t[f],f--,c-=8);if(0===s)s=1-u;else {if(s===o)return e?NaN:a?-F:F;e+=A(2,n),s-=u;}return (a?-1:1)*e*A(2,s-n)},W=function(t){return t[3]<<24|t[2]<<16|t[1]<<8|t[0]},B=function(t){return [255&t]},V=function(t){return [255&t,t>>8&255]},z=function(t){return [255&t,t>>8&255,t>>16&255,t>>24&255]},K=function(t){return G(t,52,8)},J=function(t){return G(t,23,4)},Y=function(t,n,r){p(t[x],n,{get:function(){return this[r]}});},q=function(t,n,r,e){var i=+r,o=l(i);if(i!=o||o<0||o+n>t[C])throw O(w);var u=t[L]._b,c=o+t[U],f=u.slice(c,c+n);return e?f:f.reverse()},X=function(t,n,r,e,i,o){var u=+r,c=l(u);if(u!=c||c<0||c+n>t[C])throw O(w);for(var f=t[L]._b,a=c+t[U],s=e(+i),h=0;h<n;h++)f[a+h]=s[o?h:n-h-1];},$=function(t,n){s(t,S,g);var r=+n,e=h(r);if(r!=e)throw O(m);return e};if(u.ABV){if(!a(function(){new S;})||!a(function(){new S(.5);})){S=function ArrayBuffer(t){return new P($(this,t))};for(var H,Z=S[x]=P[x],Q=v(P),tt=0;Q.length>tt;)(H=Q[tt++])in S||c(S,H,P[H]);o||(Z.constructor=S);}var nt=new _(new S(2)),rt=_[x].setInt8;nt.setInt8(0,2147483648),nt.setInt8(1,2147483649),!nt.getInt8(0)&&nt.getInt8(1)||f(_[x],{setInt8:function setInt8(t,n){rt.call(this,t,n<<24>>24);},setUint8:function setUint8(t,n){rt.call(this,t,n<<24>>24);}},!0);}else S=function ArrayBuffer(t){var n=$(this,t);this._b=d.call(Array(n),0),this[C]=n;},_=function DataView(t,n,r){s(this,_,b),s(t,S,b);var e=t[C],i=l(n);if(i<0||i>e)throw O("Wrong offset!");if(r=void 0===r?e-i:h(r),i+r>e)throw O(m);this[L]=t,this[U]=i,this[C]=r;},i&&(Y(S,R,"_l"),Y(_,k,"_b"),Y(_,R,"_l"),Y(_,T,"_o")),f(_[x],{getInt8:function getInt8(t){return q(this,1,t)[0]<<24>>24},getUint8:function getUint8(t){return q(this,1,t)[0]},getInt16:function getInt16(t){var n=q(this,2,t,arguments[1]);return (n[1]<<8|n[0])<<16>>16},getUint16:function getUint16(t){var n=q(this,2,t,arguments[1]);return n[1]<<8|n[0]},getInt32:function getInt32(t){return W(q(this,4,t,arguments[1]))},getUint32:function getUint32(t){return W(q(this,4,t,arguments[1]))>>>0},getFloat32:function getFloat32(t){return D(q(this,4,t,arguments[1]),23,4)},getFloat64:function getFloat64(t){return D(q(this,8,t,arguments[1]),52,8)},setInt8:function setInt8(t,n){X(this,1,t,B,n);},setUint8:function setUint8(t,n){X(this,1,t,B,n);},setInt16:function setInt16(t,n){X(this,2,t,V,n,arguments[2]);},setUint16:function setUint16(t,n){X(this,2,t,V,n,arguments[2]);},setInt32:function setInt32(t,n){X(this,4,t,z,n,arguments[2]);},setUint32:function setUint32(t,n){X(this,4,t,z,n,arguments[2]);},setFloat32:function setFloat32(t,n){X(this,4,t,J,n,arguments[2]);},setFloat64:function setFloat64(t,n){X(this,8,t,K,n,arguments[2]);}});y(S,g),y(_,b),c(_[x],u.VIEW,!0),r[g]=S,r[b]=_;},{106:106,108:108,113:113,28:28,34:34,38:38,40:40,58:58,6:6,67:67,72:72,86:86,9:9,92:92}],113:[function(t,n,r){for(var e,i=t(38),o=t(40),u=t(114),c=u("typed_array"),f=u("view"),a=!(!i.ArrayBuffer||!i.DataView),s=a,l=0,h=9,v="Int8Array,Uint8Array,Uint8ClampedArray,Int16Array,Uint16Array,Int32Array,Uint32Array,Float32Array,Float64Array".split(",");l<h;)(e=i[v[l++]])?(o(e.prototype,c,!0),o(e.prototype,f,!0)):s=!1;n.exports={ABV:a,CONSTR:s,TYPED:c,VIEW:f};},{114:114,38:38,40:40}],114:[function(t,n,r){var e=0,i=Math.random();n.exports=function(t){return "Symbol(".concat(void 0===t?"":t,")_",(++e+i).toString(36))};},{}],115:[function(t,n,r){var e=t(38),i=t(23),o=t(58),u=t(116),c=t(67).f;n.exports=function(t){var n=i.Symbol||(i.Symbol=o?{}:e.Symbol||{});"_"==t.charAt(0)||t in n||c(n,t,{value:u.f(t)});};},{116:116,23:23,38:38,58:58,67:67}],116:[function(t,n,r){r.f=t(117);},{117:117}],117:[function(t,n,r){var e=t(94)("wks"),i=t(114),o=t(38).Symbol,u="function"==typeof o,c=n.exports=function(t){return e[t]||(e[t]=u&&o[t]||(u?o:i)("Symbol."+t))};c.store=e;},{114:114,38:38,94:94}],118:[function(t,n,r){var e=t(17),i=t(117)("iterator"),o=t(56);n.exports=t(23).getIteratorMethod=function(t){if(void 0!=t)return t[i]||t["@@iterator"]||o[e(t)]};},{117:117,17:17,23:23,56:56}],119:[function(t,n,r){var e=t(32),i=t(88)(/[\\^$*+?.()|[\]{}]/g,"\\$&");e(e.S,"RegExp",{escape:function escape(t){return i(t)}});},{32:32,88:88}],120:[function(t,n,r){var e=t(32);e(e.P,"Array",{copyWithin:t(8)}),t(5)("copyWithin");},{32:32,5:5,8:8}],121:[function(t,n,r){var e=t(32),i=t(12)(4);e(e.P+e.F*!t(96)([].every,!0),"Array",{every:function every(t){return i(this,t,arguments[1])}});},{12:12,32:32,96:96}],122:[function(t,n,r){var e=t(32);e(e.P,"Array",{fill:t(9)}),t(5)("fill");},{32:32,5:5,9:9}],123:[function(t,n,r){var e=t(32),i=t(12)(2);e(e.P+e.F*!t(96)([].filter,!0),"Array",{filter:function filter(t){return i(this,t,arguments[1])}});},{12:12,32:32,96:96}],124:[function(t,n,r){var e=t(32),i=t(12)(6),o="findIndex",u=!0;o in[]&&Array(1)[o](function(){u=!1;}),e(e.P+e.F*u,"Array",{findIndex:function findIndex(t){return i(this,t,arguments.length>1?arguments[1]:void 0)}}),t(5)(o);},{12:12,32:32,5:5}],125:[function(t,n,r){var e=t(32),i=t(12)(5),o="find",u=!0;o in[]&&Array(1)[o](function(){u=!1;}),e(e.P+e.F*u,"Array",{find:function find(t){return i(this,t,arguments.length>1?arguments[1]:void 0)}}),t(5)(o);},{12:12,32:32,5:5}],126:[function(t,n,r){var e=t(32),i=t(12)(0),o=t(96)([].forEach,!0);e(e.P+e.F*!o,"Array",{forEach:function forEach(t){return i(this,t,arguments[1])}});},{12:12,32:32,96:96}],127:[function(t,n,r){var e=t(25),i=t(32),o=t(109),u=t(51),c=t(46),f=t(108),a=t(24),s=t(118);i(i.S+i.F*!t(54)(function(t){Array.from(t);}),"Array",{from:function from(t){var n,r,i,l,h=o(t),v="function"==typeof this?this:Array,p=arguments.length,d=p>1?arguments[1]:void 0,y=void 0!==d,g=0,b=s(h);if(y&&(d=e(d,p>2?arguments[2]:void 0,2)),void 0==b||v==Array&&c(b))for(n=f(h.length),r=new v(n);n>g;g++)a(r,g,y?d(h[g],g):h[g]);else for(l=b.call(h),r=new v;!(i=l.next()).done;g++)a(r,g,y?u(l,d,[i.value,g],!0):i.value);return r.length=g,r}});},{108:108,109:109,118:118,24:24,25:25,32:32,46:46,51:51,54:54}],128:[function(t,n,r){var e=t(32),i=t(11)(!1),o=[].indexOf,u=!!o&&1/[1].indexOf(1,-0)<0;e(e.P+e.F*(u||!t(96)(o)),"Array",{indexOf:function indexOf(t){return u?o.apply(this,arguments)||0:i(this,t,arguments[1])}});},{11:11,32:32,96:96}],129:[function(t,n,r){var e=t(32);e(e.S,"Array",{isArray:t(47)});},{32:32,47:47}],130:[function(t,n,r){var e=t(5),i=t(55),o=t(56),u=t(107);n.exports=t(53)(Array,"Array",function(t,n){this._t=u(t),this._i=0,this._k=n;},function(){var t=this._t,n=this._k,r=this._i++;return !t||r>=t.length?(this._t=void 0,i(1)):"keys"==n?i(0,r):"values"==n?i(0,t[r]):i(0,[r,t[r]])},"values"),o.Arguments=o.Array,e("keys"),e("values"),e("entries");},{107:107,5:5,53:53,55:55,56:56}],131:[function(t,n,r){var e=t(32),i=t(107),o=[].join;e(e.P+e.F*(t(45)!=Object||!t(96)(o)),"Array",{join:function join(t){return o.call(i(this),void 0===t?",":t)}});},{107:107,32:32,45:45,96:96}],132:[function(t,n,r){var e=t(32),i=t(107),o=t(106),u=t(108),c=[].lastIndexOf,f=!!c&&1/[1].lastIndexOf(1,-0)<0;e(e.P+e.F*(f||!t(96)(c)),"Array",{lastIndexOf:function lastIndexOf(t){if(f)return c.apply(this,arguments)||0;var n=i(this),r=u(n.length),e=r-1;for(arguments.length>1&&(e=Math.min(e,o(arguments[1]))),e<0&&(e=r+e);e>=0;e--)if(e in n&&n[e]===t)return e||0;return -1}});},{106:106,107:107,108:108,32:32,96:96}],133:[function(t,n,r){var e=t(32),i=t(12)(1);e(e.P+e.F*!t(96)([].map,!0),"Array",{map:function map(t){return i(this,t,arguments[1])}});},{12:12,32:32,96:96}],134:[function(t,n,r){var e=t(32),i=t(24);e(e.S+e.F*t(34)(function(){function F(){}return !(Array.of.call(F)instanceof F)}),"Array",{of:function of(){for(var t=0,n=arguments.length,r=new("function"==typeof this?this:Array)(n);n>t;)i(r,t,arguments[t++]);return r.length=n,r}});},{24:24,32:32,34:34}],135:[function(t,n,r){var e=t(32),i=t(13);e(e.P+e.F*!t(96)([].reduceRight,!0),"Array",{reduceRight:function reduceRight(t){return i(this,t,arguments.length,arguments[1],!0)}});},{13:13,32:32,96:96}],136:[function(t,n,r){var e=t(32),i=t(13);e(e.P+e.F*!t(96)([].reduce,!0),"Array",{reduce:function reduce(t){return i(this,t,arguments.length,arguments[1],!1)}});},{13:13,32:32,96:96}],137:[function(t,n,r){var e=t(32),i=t(41),o=t(18),u=t(105),c=t(108),f=[].slice;e(e.P+e.F*t(34)(function(){i&&f.call(i);}),"Array",{slice:function slice(t,n){var r=c(this.length),e=o(this);if(n=void 0===n?r:n,"Array"==e)return f.call(this,t,n);for(var i=u(t,r),a=u(n,r),s=c(a-i),l=Array(s),h=0;h<s;h++)l[h]="String"==e?this.charAt(i+h):this[i+h];return l}});},{105:105,108:108,18:18,32:32,34:34,41:41}],138:[function(t,n,r){var e=t(32),i=t(12)(3);e(e.P+e.F*!t(96)([].some,!0),"Array",{some:function some(t){return i(this,t,arguments[1])}});},{12:12,32:32,96:96}],139:[function(t,n,r){var e=t(32),i=t(3),o=t(109),u=t(34),c=[].sort,f=[1,2,3];e(e.P+e.F*(u(function(){f.sort(void 0);})||!u(function(){f.sort(null);})||!t(96)(c)),"Array",{sort:function sort(t){return void 0===t?c.call(o(this)):c.call(o(this),i(t))}});},{109:109,3:3,32:32,34:34,96:96}],140:[function(t,n,r){t(91)("Array");},{91:91}],141:[function(t,n,r){var e=t(32);e(e.S,"Date",{now:function(){return (new Date).getTime()}});},{32:32}],142:[function(t,n,r){var e=t(32),i=t(34),o=Date.prototype.getTime,u=function(t){return t>9?t:"0"+t};e(e.P+e.F*(i(function(){return "0385-07-25T07:06:39.999Z"!=new Date(-5e13-1).toISOString()})||!i(function(){new Date(NaN).toISOString();})),"Date",{toISOString:function toISOString(){if(!isFinite(o.call(this)))throw RangeError("Invalid time value");var t=this,n=t.getUTCFullYear(),r=t.getUTCMilliseconds(),e=n<0?"-":n>9999?"+":"";return e+("00000"+Math.abs(n)).slice(e?-6:-4)+"-"+u(t.getUTCMonth()+1)+"-"+u(t.getUTCDate())+"T"+u(t.getUTCHours())+":"+u(t.getUTCMinutes())+":"+u(t.getUTCSeconds())+"."+(r>99?r:"0"+u(r))+"Z"}});},{32:32,34:34}],143:[function(t,n,r){var e=t(32),i=t(109),o=t(110);e(e.P+e.F*t(34)(function(){return null!==new Date(NaN).toJSON()||1!==Date.prototype.toJSON.call({toISOString:function(){return 1}})}),"Date",{toJSON:function toJSON(t){var n=i(this),r=o(n);return "number"!=typeof r||isFinite(r)?n.toISOString():null}});},{109:109,110:110,32:32,34:34}],144:[function(t,n,r){var e=t(117)("toPrimitive"),i=Date.prototype;e in i||t(40)(i,e,t(26));},{117:117,26:26,40:40}],145:[function(t,n,r){var e=Date.prototype,i="Invalid Date",o="toString",u=e[o],c=e.getTime;new Date(NaN)+""!=i&&t(87)(e,o,function toString(){var t=c.call(this);return t===t?u.call(this):i});},{87:87}],146:[function(t,n,r){var e=t(32);e(e.P,"Function",{bind:t(16)});},{16:16,32:32}],147:[function(t,n,r){var e=t(49),i=t(74),o=t(117)("hasInstance"),u=Function.prototype;o in u||t(67).f(u,o,{value:function(t){if("function"!=typeof this||!e(t))return !1;if(!e(this.prototype))return t instanceof this;for(;t=i(t);)if(this.prototype===t)return !0;return !1}});},{117:117,49:49,67:67,74:74}],148:[function(t,n,r){var e=t(67).f,i=t(85),o=t(39),u=Function.prototype,c=/^\s*function ([^ (]*)/,f="name",a=Object.isExtensible||function(){return !0};f in u||t(28)&&e(u,f,{configurable:!0,get:function(){try{var t=this,n=(""+t).match(c)[1];return o(t,f)||!a(t)||e(t,f,i(5,n)),n}catch(t){return ""}}});},{28:28,39:39,67:67,85:85}],149:[function(t,n,r){var e=t(19);n.exports=t(22)("Map",function(t){return function Map(){return t(this,arguments.length>0?arguments[0]:void 0)}},{get:function get(t){var n=e.getEntry(this,t);return n&&n.v},set:function set(t,n){return e.def(this,0===t?0:t,n)}},e,!0);},{19:19,22:22}],150:[function(t,n,r){var e=t(32),i=t(60),o=Math.sqrt,u=Math.acosh;e(e.S+e.F*!(u&&710==Math.floor(u(Number.MAX_VALUE))&&u(1/0)==1/0),"Math",{acosh:function acosh(t){return (t=+t)<1?NaN:t>94906265.62425156?Math.log(t)+Math.LN2:i(t-1+o(t-1)*o(t+1))}});},{32:32,60:60}],151:[function(t,n,r){function asinh(t){return isFinite(t=+t)&&0!=t?t<0?-asinh(-t):Math.log(t+Math.sqrt(t*t+1)):t}var e=t(32),i=Math.asinh;e(e.S+e.F*!(i&&1/i(0)>0),"Math",{asinh:asinh});},{32:32}],152:[function(t,n,r){var e=t(32),i=Math.atanh;e(e.S+e.F*!(i&&1/i(-0)<0),"Math",{atanh:function atanh(t){return 0==(t=+t)?t:Math.log((1+t)/(1-t))/2}});},{32:32}],153:[function(t,n,r){var e=t(32),i=t(61);e(e.S,"Math",{cbrt:function cbrt(t){return i(t=+t)*Math.pow(Math.abs(t),1/3)}});},{32:32,61:61}],154:[function(t,n,r){var e=t(32);e(e.S,"Math",{clz32:function clz32(t){return (t>>>=0)?31-Math.floor(Math.log(t+.5)*Math.LOG2E):32}});},{32:32}],155:[function(t,n,r){var e=t(32),i=Math.exp;e(e.S,"Math",{cosh:function cosh(t){return (i(t=+t)+i(-t))/2}});},{32:32}],156:[function(t,n,r){var e=t(32),i=t(59);e(e.S+e.F*(i!=Math.expm1),"Math",{expm1:i});},{32:32,59:59}],157:[function(t,n,r){var e=t(32),i=t(61),o=Math.pow,u=o(2,-52),c=o(2,-23),f=o(2,127)*(2-c),a=o(2,-126),s=function(t){return t+1/u-1/u};e(e.S,"Math",{fround:function fround(t){var n,r,e=Math.abs(t),o=i(t);return e<a?o*s(e/a/c)*a*c:(n=(1+c/u)*e,r=n-(n-e),r>f||r!=r?o*(1/0):o*r)}});},{32:32,61:61}],158:[function(t,n,r){var e=t(32),i=Math.abs;e(e.S,"Math",{hypot:function hypot(t,n){for(var r,e,o=0,u=0,c=arguments.length,f=0;u<c;)r=i(arguments[u++]),f<r?(e=f/r,o=o*e*e+1,f=r):r>0?(e=r/f,o+=e*e):o+=r;return f===1/0?1/0:f*Math.sqrt(o)}});},{32:32}],159:[function(t,n,r){var e=t(32),i=Math.imul;e(e.S+e.F*t(34)(function(){return i(4294967295,5)!=-5||2!=i.length}),"Math",{imul:function imul(t,n){var r=65535,e=+t,i=+n,o=r&e,u=r&i;return 0|o*u+((r&e>>>16)*u+o*(r&i>>>16)<<16>>>0)}});},{32:32,34:34}],160:[function(t,n,r){var e=t(32);e(e.S,"Math",{log10:function log10(t){return Math.log(t)/Math.LN10}});},{32:32}],161:[function(t,n,r){var e=t(32);e(e.S,"Math",{log1p:t(60)});},{32:32,60:60}],162:[function(t,n,r){var e=t(32);e(e.S,"Math",{log2:function log2(t){return Math.log(t)/Math.LN2}});},{32:32}],163:[function(t,n,r){var e=t(32);e(e.S,"Math",{sign:t(61)});},{32:32,61:61}],164:[function(t,n,r){var e=t(32),i=t(59),o=Math.exp;e(e.S+e.F*t(34)(function(){return !Math.sinh(-2e-17)!=-2e-17}),"Math",{sinh:function sinh(t){return Math.abs(t=+t)<1?(i(t)-i(-t))/2:(o(t-1)-o(-t-1))*(Math.E/2)}});},{32:32,34:34,59:59}],165:[function(t,n,r){var e=t(32),i=t(59),o=Math.exp;e(e.S,"Math",{tanh:function tanh(t){var n=i(t=+t),r=i(-t);return n==1/0?1:r==1/0?-1:(n-r)/(o(t)+o(-t))}});},{32:32,59:59}],166:[function(t,n,r){var e=t(32);e(e.S,"Math",{trunc:function trunc(t){return (t>0?Math.floor:Math.ceil)(t)}});},{32:32}],167:[function(t,n,r){var e=t(38),i=t(39),o=t(18),u=t(43),c=t(110),f=t(34),a=t(72).f,s=t(70).f,l=t(67).f,h=t(102).trim,v="Number",p=e[v],d=p,y=p.prototype,g=o(t(66)(y))==v,b="trim"in String.prototype,x=function(t){var n=c(t,!1);if("string"==typeof n&&n.length>2){n=b?n.trim():h(n,3);var r,e,i,o=n.charCodeAt(0);if(43===o||45===o){if(r=n.charCodeAt(2),88===r||120===r)return NaN}else if(48===o){switch(n.charCodeAt(1)){case 66:case 98:e=2,i=49;break;case 79:case 111:e=8,i=55;break;default:return +n}for(var u,f=n.slice(2),a=0,s=f.length;a<s;a++)if(u=f.charCodeAt(a),u<48||u>i)return NaN;return parseInt(f,e)}}return +n};if(!p(" 0o1")||!p("0b1")||p("+0x1")){p=function Number(t){var n=arguments.length<1?0:t,r=this;return r instanceof p&&(g?f(function(){y.valueOf.call(r);}):o(r)!=v)?u(new d(x(n)),r,p):x(n)};for(var m,w=t(28)?a(d):"MAX_VALUE,MIN_VALUE,NaN,NEGATIVE_INFINITY,POSITIVE_INFINITY,EPSILON,isFinite,isInteger,isNaN,isSafeInteger,MAX_SAFE_INTEGER,MIN_SAFE_INTEGER,parseFloat,parseInt,isInteger".split(","),S=0;w.length>S;S++)i(d,m=w[S])&&!i(p,m)&&l(p,m,s(d,m));p.prototype=y,y.constructor=p,t(87)(e,v,p);}},{102:102,110:110,18:18,28:28,34:34,38:38,39:39,43:43,66:66,67:67,70:70,72:72,87:87}],168:[function(t,n,r){var e=t(32);e(e.S,"Number",{EPSILON:Math.pow(2,-52)});},{32:32}],169:[function(t,n,r){var e=t(32),i=t(38).isFinite;e(e.S,"Number",{isFinite:function isFinite(t){return "number"==typeof t&&i(t)}});},{32:32,38:38}],170:[function(t,n,r){var e=t(32);e(e.S,"Number",{isInteger:t(48)});},{32:32,48:48}],171:[function(t,n,r){var e=t(32);e(e.S,"Number",{isNaN:function isNaN(t){return t!=t}});},{32:32}],172:[function(t,n,r){var e=t(32),i=t(48),o=Math.abs;e(e.S,"Number",{isSafeInteger:function isSafeInteger(t){return i(t)&&o(t)<=9007199254740991}});},{32:32,48:48}],173:[function(t,n,r){var e=t(32);e(e.S,"Number",{MAX_SAFE_INTEGER:9007199254740991});},{32:32}],174:[function(t,n,r){var e=t(32);e(e.S,"Number",{MIN_SAFE_INTEGER:-9007199254740991});},{32:32}],175:[function(t,n,r){var e=t(32),i=t(81);e(e.S+e.F*(Number.parseFloat!=i),"Number",{parseFloat:i});},{32:32,81:81}],176:[function(t,n,r){var e=t(32),i=t(82);e(e.S+e.F*(Number.parseInt!=i),"Number",{parseInt:i});},{32:32,82:82}],177:[function(t,n,r){var e=t(32),i=t(106),o=t(4),u=t(101),c=1..toFixed,f=Math.floor,a=[0,0,0,0,0,0],s="Number.toFixed: incorrect invocation!",l="0",h=function(t,n){for(var r=-1,e=n;++r<6;)e+=t*a[r],a[r]=e%1e7,e=f(e/1e7);},v=function(t){for(var n=6,r=0;--n>=0;)r+=a[n],a[n]=f(r/t),r=r%t*1e7;},p=function(){for(var t=6,n="";--t>=0;)if(""!==n||0===t||0!==a[t]){var r=String(a[t]);n=""===n?r:n+u.call(l,7-r.length)+r;}return n},d=function(t,n,r){return 0===n?r:n%2===1?d(t,n-1,r*t):d(t*t,n/2,r)},y=function(t){for(var n=0,r=t;r>=4096;)n+=12,r/=4096;for(;r>=2;)n+=1,r/=2;return n};e(e.P+e.F*(!!c&&("0.000"!==8e-5.toFixed(3)||"1"!==.9.toFixed(0)||"1.25"!==1.255.toFixed(2)||"1000000000000000128"!==(0xde0b6b3a7640080).toFixed(0))||!t(34)(function(){c.call({});})),"Number",{toFixed:function toFixed(t){var n,r,e,c,f=o(this,s),a=i(t),g="",b=l;if(a<0||a>20)throw RangeError(s);if(f!=f)return "NaN";if(f<=-1e21||f>=1e21)return String(f);if(f<0&&(g="-",f=-f),f>1e-21)if(n=y(f*d(2,69,1))-69,r=n<0?f*d(2,-n,1):f/d(2,n,1),r*=4503599627370496,n=52-n,n>0){for(h(0,r),e=a;e>=7;)h(1e7,0),e-=7;for(h(d(10,e,1),0),e=n-1;e>=23;)v(1<<23),e-=23;v(1<<e),h(1,1),v(2),b=p();}else h(0,r),h(1<<-n,0),b=p()+u.call(l,a);return a>0?(c=b.length,b=g+(c<=a?"0."+u.call(l,a-c)+b:b.slice(0,c-a)+"."+b.slice(c-a))):b=g+b,b}});},{101:101,106:106,32:32,34:34,4:4}],178:[function(t,n,r){var e=t(32),i=t(34),o=t(4),u=1..toPrecision;e(e.P+e.F*(i(function(){return "1"!==u.call(1,void 0)})||!i(function(){u.call({});})),"Number",{toPrecision:function toPrecision(t){var n=o(this,"Number#toPrecision: incorrect invocation!");return void 0===t?u.call(n):u.call(n,t)}});},{32:32,34:34,4:4}],179:[function(t,n,r){var e=t(32);e(e.S+e.F,"Object",{assign:t(65)});},{32:32,65:65}],180:[function(t,n,r){var e=t(32);e(e.S,"Object",{create:t(66)});},{32:32,66:66}],181:[function(t,n,r){var e=t(32);e(e.S+e.F*!t(28),"Object",{defineProperties:t(68)});},{28:28,32:32,68:68}],182:[function(t,n,r){var e=t(32);e(e.S+e.F*!t(28),"Object",{defineProperty:t(67).f});},{28:28,32:32,67:67}],183:[function(t,n,r){var e=t(49),i=t(62).onFreeze;t(78)("freeze",function(t){return function freeze(n){return t&&e(n)?t(i(n)):n}});},{49:49,62:62,78:78}],184:[function(t,n,r){var e=t(107),i=t(70).f;t(78)("getOwnPropertyDescriptor",function(){return function getOwnPropertyDescriptor(t,n){return i(e(t),n)}});},{107:107,70:70,78:78}],185:[function(t,n,r){t(78)("getOwnPropertyNames",function(){return t(71).f});},{71:71,78:78}],186:[function(t,n,r){var e=t(109),i=t(74);t(78)("getPrototypeOf",function(){return function getPrototypeOf(t){return i(e(t))}});},{109:109,74:74,78:78}],187:[function(t,n,r){var e=t(49);t(78)("isExtensible",function(t){return function isExtensible(n){return !!e(n)&&(!t||t(n))}});},{49:49,78:78}],188:[function(t,n,r){var e=t(49);t(78)("isFrozen",function(t){return function isFrozen(n){return !e(n)||!!t&&t(n)}});},{49:49,78:78}],189:[function(t,n,r){var e=t(49);t(78)("isSealed",function(t){return function isSealed(n){return !e(n)||!!t&&t(n)}});},{49:49,78:78}],190:[function(t,n,r){var e=t(32);e(e.S,"Object",{is:t(89)});},{32:32,89:89}],191:[function(t,n,r){var e=t(109),i=t(76);t(78)("keys",function(){return function keys(t){return i(e(t))}});},{109:109,76:76,78:78}],192:[function(t,n,r){var e=t(49),i=t(62).onFreeze;t(78)("preventExtensions",function(t){return function preventExtensions(n){return t&&e(n)?t(i(n)):n}});},{49:49,62:62,78:78}],193:[function(t,n,r){var e=t(49),i=t(62).onFreeze;t(78)("seal",function(t){return function seal(n){return t&&e(n)?t(i(n)):n}});},{49:49,62:62,78:78}],194:[function(t,n,r){var e=t(32);e(e.S,"Object",{setPrototypeOf:t(90).set});},{32:32,90:90}],195:[function(t,n,r){var e=t(17),i={};i[t(117)("toStringTag")]="z",i+""!="[object z]"&&t(87)(Object.prototype,"toString",function toString(){return "[object "+e(this)+"]"},!0);},{117:117,17:17,87:87}],196:[function(t,n,r){var e=t(32),i=t(81);e(e.G+e.F*(parseFloat!=i),{parseFloat:i});},{32:32,81:81}],197:[function(t,n,r){var e=t(32),i=t(82);e(e.G+e.F*(parseInt!=i),{parseInt:i});},{32:32,82:82}],198:[function(t,n,r){var e,i,o,u=t(58),c=t(38),f=t(25),a=t(17),s=t(32),l=t(49),h=t(3),v=t(6),p=t(37),d=t(95),y=t(104).set,g=t(64)(),b="Promise",x=c.TypeError,m=c.process,w=c[b],m=c.process,S="process"==a(m),_=function(){},E=!!function(){try{var n=w.resolve(1),r=(n.constructor={})[t(117)("species")]=function(t){t(_,_);};return (S||"function"==typeof PromiseRejectionEvent)&&n.then(_)instanceof r}catch(t){}}(),O=function(t,n){return t===n||t===w&&n===o},F=function(t){var n;return !(!l(t)||"function"!=typeof(n=t.then))&&n},P=function(t){return O(w,t)?new M(t):new i(t)},M=i=function(t){var n,r;this.promise=new t(function(t,e){if(void 0!==n||void 0!==r)throw x("Bad Promise constructor");n=t,r=e;}),this.resolve=h(n),this.reject=h(r);},A=function(t){try{t();}catch(t){return {error:t}}},I=function(t,n){if(!t._n){t._n=!0;var r=t._c;g(function(){for(var e=t._v,i=1==t._s,o=0,u=function(n){var r,o,u=i?n.ok:n.fail,c=n.resolve,f=n.reject,a=n.domain;try{u?(i||(2==t._h&&k(t),t._h=1),u===!0?r=e:(a&&a.enter(),r=u(e),a&&a.exit()),r===n.promise?f(x("Promise-chain cycle")):(o=F(r))?o.call(r,c,f):c(r)):f(e);}catch(t){f(t);}};r.length>o;)u(r[o++]);t._c=[],t._n=!1,n&&!t._h&&j(t);});}},j=function(t){y.call(c,function(){var n,r,e,i=t._v;if(N(t)&&(n=A(function(){S?m.emit("unhandledRejection",i,t):(r=c.onunhandledrejection)?r({promise:t,reason:i}):(e=c.console)&&e.error&&e.error("Unhandled promise rejection",i);}),t._h=S||N(t)?2:1),t._a=void 0,n)throw n.error});},N=function(t){if(1==t._h)return !1;for(var n,r=t._a||t._c,e=0;r.length>e;)if(n=r[e++],n.fail||!N(n.promise))return !1;return !0},k=function(t){y.call(c,function(){var n;S?m.emit("rejectionHandled",t):(n=c.onrejectionhandled)&&n({promise:t,reason:t._v});});},R=function(t){var n=this;n._d||(n._d=!0,n=n._w||n,n._v=t,n._s=2,n._a||(n._a=n._c.slice()),I(n,!0));},T=function(t){var n,r=this;if(!r._d){r._d=!0,r=r._w||r;try{if(r===t)throw x("Promise can't be resolved itself");(n=F(t))?g(function(){var e={_w:r,_d:!1};try{n.call(t,f(T,e,1),f(R,e,1));}catch(t){R.call(e,t);}}):(r._v=t,r._s=1,I(r,!1));}catch(t){R.call({_w:r,_d:!1},t);}}};E||(w=function Promise(t){v(this,w,b,"_h"),h(t),e.call(this);try{t(f(T,this,1),f(R,this,1));}catch(t){R.call(this,t);}},e=function Promise(t){this._c=[],this._a=void 0,this._s=0,this._d=!1,this._v=void 0,this._h=0,this._n=!1;},e.prototype=t(86)(w.prototype,{then:function then(t,n){var r=P(d(this,w));return r.ok="function"!=typeof t||t,r.fail="function"==typeof n&&n,r.domain=S?m.domain:void 0,this._c.push(r),this._a&&this._a.push(r),this._s&&I(this,!1),r.promise},catch:function(t){return this.then(void 0,t)}}),M=function(){var t=new e;this.promise=t,this.resolve=f(T,t,1),this.reject=f(R,t,1);}),s(s.G+s.W+s.F*!E,{Promise:w}),t(92)(w,b),t(91)(b),o=t(23)[b],s(s.S+s.F*!E,b,{reject:function reject(t){var n=P(this),r=n.reject;return r(t),n.promise}}),s(s.S+s.F*(u||!E),b,{resolve:function resolve(t){if(t instanceof w&&O(t.constructor,this))return t;var n=P(this),r=n.resolve;return r(t),n.promise}}),s(s.S+s.F*!(E&&t(54)(function(t){w.all(t).catch(_);})),b,{all:function all(t){var n=this,r=P(n),e=r.resolve,i=r.reject,o=A(function(){var r=[],o=0,u=1;p(t,!1,function(t){var c=o++,f=!1;r.push(void 0),u++,n.resolve(t).then(function(t){f||(f=!0,r[c]=t,--u||e(r));},i);}),--u||e(r);});return o&&i(o.error),r.promise},race:function race(t){var n=this,r=P(n),e=r.reject,i=A(function(){p(t,!1,function(t){n.resolve(t).then(r.resolve,e);});});return i&&e(i.error),r.promise}});},{104:104,117:117,17:17,23:23,25:25,3:3,32:32,37:37,38:38,49:49,54:54,58:58,6:6,64:64,86:86,91:91,92:92,95:95}],199:[function(t,n,r){var e=t(32),i=t(3),o=t(7),u=(t(38).Reflect||{}).apply,c=Function.apply;e(e.S+e.F*!t(34)(function(){u(function(){});}),"Reflect",{apply:function apply(t,n,r){var e=i(t),f=o(r);return u?u(e,n,f):c.call(e,n,f)}});},{3:3,32:32,34:34,38:38,7:7}],200:[function(t,n,r){var e=t(32),i=t(66),o=t(3),u=t(7),c=t(49),f=t(34),a=t(16),s=(t(38).Reflect||{}).construct,l=f(function(){function F(){}return !(s(function(){},[],F)instanceof F)}),h=!f(function(){s(function(){});});e(e.S+e.F*(l||h),"Reflect",{construct:function construct(t,n){o(t),u(n);var r=arguments.length<3?t:o(arguments[2]);if(h&&!l)return s(t,n,r);if(t==r){switch(n.length){case 0:return new t;case 1:return new t(n[0]);case 2:return new t(n[0],n[1]);case 3:return new t(n[0],n[1],n[2]);case 4:return new t(n[0],n[1],n[2],n[3])}var e=[null];return e.push.apply(e,n),new(a.apply(t,e))}var f=r.prototype,v=i(c(f)?f:Object.prototype),p=Function.apply.call(t,v,n);return c(p)?p:v}});},{16:16,3:3,32:32,34:34,38:38,49:49,66:66,7:7}],201:[function(t,n,r){var e=t(67),i=t(32),o=t(7),u=t(110);i(i.S+i.F*t(34)(function(){Reflect.defineProperty(e.f({},1,{value:1}),1,{value:2});}),"Reflect",{defineProperty:function defineProperty(t,n,r){o(t),n=u(n,!0),o(r);try{return e.f(t,n,r),!0}catch(t){return !1}}});},{110:110,32:32,34:34,67:67,7:7}],202:[function(t,n,r){var e=t(32),i=t(70).f,o=t(7);e(e.S,"Reflect",{deleteProperty:function deleteProperty(t,n){var r=i(o(t),n);return !(r&&!r.configurable)&&delete t[n]}});},{32:32,7:7,70:70}],203:[function(t,n,r){var e=t(32),i=t(7),o=function(t){this._t=i(t),this._i=0;var n,r=this._k=[];for(n in t)r.push(n);};t(52)(o,"Object",function(){var t,n=this,r=n._k;do if(n._i>=r.length)return {value:void 0,done:!0};while(!((t=r[n._i++])in n._t));return {value:t,done:!1}}),e(e.S,"Reflect",{enumerate:function enumerate(t){return new o(t)}});},{32:32,52:52,7:7}],204:[function(t,n,r){var e=t(70),i=t(32),o=t(7);i(i.S,"Reflect",{getOwnPropertyDescriptor:function getOwnPropertyDescriptor(t,n){return e.f(o(t),n)}});},{32:32,7:7,70:70}],205:[function(t,n,r){var e=t(32),i=t(74),o=t(7);e(e.S,"Reflect",{getPrototypeOf:function getPrototypeOf(t){return i(o(t))}});},{32:32,7:7,74:74}],206:[function(t,n,r){function get(t,n){var r,u,a=arguments.length<3?t:arguments[2];return f(t)===a?t[n]:(r=e.f(t,n))?o(r,"value")?r.value:void 0!==r.get?r.get.call(a):void 0:c(u=i(t))?get(u,n,a):void 0}var e=t(70),i=t(74),o=t(39),u=t(32),c=t(49),f=t(7);u(u.S,"Reflect",{get:get});},{32:32,39:39,49:49,7:7,70:70,74:74}],207:[function(t,n,r){var e=t(32);e(e.S,"Reflect",{has:function has(t,n){return n in t;
}});},{32:32}],208:[function(t,n,r){var e=t(32),i=t(7),o=Object.isExtensible;e(e.S,"Reflect",{isExtensible:function isExtensible(t){return i(t),!o||o(t)}});},{32:32,7:7}],209:[function(t,n,r){var e=t(32);e(e.S,"Reflect",{ownKeys:t(80)});},{32:32,80:80}],210:[function(t,n,r){var e=t(32),i=t(7),o=Object.preventExtensions;e(e.S,"Reflect",{preventExtensions:function preventExtensions(t){i(t);try{return o&&o(t),!0}catch(t){return !1}}});},{32:32,7:7}],211:[function(t,n,r){var e=t(32),i=t(90);i&&e(e.S,"Reflect",{setPrototypeOf:function setPrototypeOf(t,n){i.check(t,n);try{return i.set(t,n),!0}catch(t){return !1}}});},{32:32,90:90}],212:[function(t,n,r){function set(t,n,r){var c,l,h=arguments.length<4?t:arguments[3],v=i.f(a(t),n);if(!v){if(s(l=o(t)))return set(l,n,r,h);v=f(0);}return u(v,"value")?!(v.writable===!1||!s(h))&&(c=i.f(h,n)||f(0),c.value=r,e.f(h,n,c),!0):void 0!==v.set&&(v.set.call(h,r),!0)}var e=t(67),i=t(70),o=t(74),u=t(39),c=t(32),f=t(85),a=t(7),s=t(49);c(c.S,"Reflect",{set:set});},{32:32,39:39,49:49,67:67,7:7,70:70,74:74,85:85}],213:[function(t,n,r){var e=t(38),i=t(43),o=t(67).f,u=t(72).f,c=t(50),f=t(36),a=e.RegExp,s=a,l=a.prototype,h=/a/g,v=/a/g,p=new a(h)!==h;if(t(28)&&(!p||t(34)(function(){return v[t(117)("match")]=!1,a(h)!=h||a(v)==v||"/a/i"!=a(h,"i")}))){a=function RegExp(t,n){var r=this instanceof a,e=c(t),o=void 0===n;return !r&&e&&t.constructor===a&&o?t:i(p?new s(e&&!o?t.source:t,n):s((e=t instanceof a)?t.source:t,e&&o?f.call(t):n),r?this:l,a)};for(var d=(function(t){t in a||o(a,t,{configurable:!0,get:function(){return s[t]},set:function(n){s[t]=n;}});}),y=u(s),g=0;y.length>g;)d(y[g++]);l.constructor=a,a.prototype=l,t(87)(e,"RegExp",a);}t(91)("RegExp");},{117:117,28:28,34:34,36:36,38:38,43:43,50:50,67:67,72:72,87:87,91:91}],214:[function(t,n,r){t(28)&&"g"!=/./g.flags&&t(67).f(RegExp.prototype,"flags",{configurable:!0,get:t(36)});},{28:28,36:36,67:67}],215:[function(t,n,r){t(35)("match",1,function(t,n,r){return [function match(r){var e=t(this),i=void 0==r?void 0:r[n];return void 0!==i?i.call(r,e):new RegExp(r)[n](String(e))},r]});},{35:35}],216:[function(t,n,r){t(35)("replace",2,function(t,n,r){return [function replace(e,i){var o=t(this),u=void 0==e?void 0:e[n];return void 0!==u?u.call(e,o,i):r.call(String(o),e,i)},r]});},{35:35}],217:[function(t,n,r){t(35)("search",1,function(t,n,r){return [function search(r){var e=t(this),i=void 0==r?void 0:r[n];return void 0!==i?i.call(r,e):new RegExp(r)[n](String(e))},r]});},{35:35}],218:[function(t,n,r){t(35)("split",2,function(n,r,e){var i=t(50),o=e,u=[].push,c="split",f="length",a="lastIndex";if("c"=="abbc"[c](/(b)*/)[1]||4!="test"[c](/(?:)/,-1)[f]||2!="ab"[c](/(?:ab)*/)[f]||4!="."[c](/(.?)(.?)/)[f]||"."[c](/()()/)[f]>1||""[c](/.?/)[f]){var s=void 0===/()??/.exec("")[1];e=function(t,n){var r=String(this);if(void 0===t&&0===n)return [];if(!i(t))return o.call(r,t,n);var e,c,l,h,v,p=[],d=(t.ignoreCase?"i":"")+(t.multiline?"m":"")+(t.unicode?"u":"")+(t.sticky?"y":""),y=0,g=void 0===n?4294967295:n>>>0,b=new RegExp(t.source,d+"g");for(s||(e=new RegExp("^"+b.source+"$(?!\\s)",d));(c=b.exec(r))&&(l=c.index+c[0][f],!(l>y&&(p.push(r.slice(y,c.index)),!s&&c[f]>1&&c[0].replace(e,function(){for(v=1;v<arguments[f]-2;v++)void 0===arguments[v]&&(c[v]=void 0);}),c[f]>1&&c.index<r[f]&&u.apply(p,c.slice(1)),h=c[0][f],y=l,p[f]>=g)));)b[a]===c.index&&b[a]++;return y===r[f]?!h&&b.test("")||p.push(""):p.push(r.slice(y)),p[f]>g?p.slice(0,g):p};}else "0"[c](void 0,0)[f]&&(e=function(t,n){return void 0===t&&0===n?[]:o.call(this,t,n)});return [function split(t,i){var o=n(this),u=void 0==t?void 0:t[r];return void 0!==u?u.call(t,o,i):e.call(String(o),t,i)},e]});},{35:35,50:50}],219:[function(t,n,r){t(214);var e=t(7),i=t(36),o=t(28),u="toString",c=/./[u],f=function(n){t(87)(RegExp.prototype,u,n,!0);};t(34)(function(){return "/a/b"!=c.call({source:"a",flags:"b"})})?f(function toString(){var t=e(this);return "/".concat(t.source,"/","flags"in t?t.flags:!o&&t instanceof RegExp?i.call(t):void 0)}):c.name!=u&&f(function toString(){return c.call(this)});},{214:214,28:28,34:34,36:36,7:7,87:87}],220:[function(t,n,r){var e=t(19);n.exports=t(22)("Set",function(t){return function Set(){return t(this,arguments.length>0?arguments[0]:void 0)}},{add:function add(t){return e.def(this,t=0===t?0:t,t)}},e);},{19:19,22:22}],221:[function(t,n,r){t(99)("anchor",function(t){return function anchor(n){return t(this,"a","name",n)}});},{99:99}],222:[function(t,n,r){t(99)("big",function(t){return function big(){return t(this,"big","","")}});},{99:99}],223:[function(t,n,r){t(99)("blink",function(t){return function blink(){return t(this,"blink","","")}});},{99:99}],224:[function(t,n,r){t(99)("bold",function(t){return function bold(){return t(this,"b","","")}});},{99:99}],225:[function(t,n,r){var e=t(32),i=t(97)(!1);e(e.P,"String",{codePointAt:function codePointAt(t){return i(this,t)}});},{32:32,97:97}],226:[function(t,n,r){var e=t(32),i=t(108),o=t(98),u="endsWith",c=""[u];e(e.P+e.F*t(33)(u),"String",{endsWith:function endsWith(t){var n=o(this,t,u),r=arguments.length>1?arguments[1]:void 0,e=i(n.length),f=void 0===r?e:Math.min(i(r),e),a=String(t);return c?c.call(n,a,f):n.slice(f-a.length,f)===a}});},{108:108,32:32,33:33,98:98}],227:[function(t,n,r){t(99)("fixed",function(t){return function fixed(){return t(this,"tt","","")}});},{99:99}],228:[function(t,n,r){t(99)("fontcolor",function(t){return function fontcolor(n){return t(this,"font","color",n)}});},{99:99}],229:[function(t,n,r){t(99)("fontsize",function(t){return function fontsize(n){return t(this,"font","size",n)}});},{99:99}],230:[function(t,n,r){var e=t(32),i=t(105),o=String.fromCharCode,u=String.fromCodePoint;e(e.S+e.F*(!!u&&1!=u.length),"String",{fromCodePoint:function fromCodePoint(t){for(var n,r=[],e=arguments.length,u=0;e>u;){if(n=+arguments[u++],i(n,1114111)!==n)throw RangeError(n+" is not a valid code point");r.push(n<65536?o(n):o(((n-=65536)>>10)+55296,n%1024+56320));}return r.join("")}});},{105:105,32:32}],231:[function(t,n,r){var e=t(32),i=t(98),o="includes";e(e.P+e.F*t(33)(o),"String",{includes:function includes(t){return !!~i(this,t,o).indexOf(t,arguments.length>1?arguments[1]:void 0)}});},{32:32,33:33,98:98}],232:[function(t,n,r){t(99)("italics",function(t){return function italics(){return t(this,"i","","")}});},{99:99}],233:[function(t,n,r){var e=t(97)(!0);t(53)(String,"String",function(t){this._t=String(t),this._i=0;},function(){var t,n=this._t,r=this._i;return r>=n.length?{value:void 0,done:!0}:(t=e(n,r),this._i+=t.length,{value:t,done:!1})});},{53:53,97:97}],234:[function(t,n,r){t(99)("link",function(t){return function link(n){return t(this,"a","href",n)}});},{99:99}],235:[function(t,n,r){var e=t(32),i=t(107),o=t(108);e(e.S,"String",{raw:function raw(t){for(var n=i(t.raw),r=o(n.length),e=arguments.length,u=[],c=0;r>c;)u.push(String(n[c++])),c<e&&u.push(String(arguments[c]));return u.join("")}});},{107:107,108:108,32:32}],236:[function(t,n,r){var e=t(32);e(e.P,"String",{repeat:t(101)});},{101:101,32:32}],237:[function(t,n,r){t(99)("small",function(t){return function small(){return t(this,"small","","")}});},{99:99}],238:[function(t,n,r){var e=t(32),i=t(108),o=t(98),u="startsWith",c=""[u];e(e.P+e.F*t(33)(u),"String",{startsWith:function startsWith(t){var n=o(this,t,u),r=i(Math.min(arguments.length>1?arguments[1]:void 0,n.length)),e=String(t);return c?c.call(n,e,r):n.slice(r,r+e.length)===e}});},{108:108,32:32,33:33,98:98}],239:[function(t,n,r){t(99)("strike",function(t){return function strike(){return t(this,"strike","","")}});},{99:99}],240:[function(t,n,r){t(99)("sub",function(t){return function sub(){return t(this,"sub","","")}});},{99:99}],241:[function(t,n,r){t(99)("sup",function(t){return function sup(){return t(this,"sup","","")}});},{99:99}],242:[function(t,n,r){t(102)("trim",function(t){return function trim(){return t(this,3)}});},{102:102}],243:[function(t,n,r){var e=t(38),i=t(39),o=t(28),u=t(32),c=t(87),f=t(62).KEY,a=t(34),s=t(94),l=t(92),h=t(114),v=t(117),p=t(116),d=t(115),y=t(57),g=t(31),b=t(47),x=t(7),m=t(107),w=t(110),S=t(85),_=t(66),E=t(71),O=t(70),F=t(67),P=t(76),M=O.f,A=F.f,I=E.f,j=e.Symbol,N=e.JSON,k=N&&N.stringify,R="prototype",T=v("_hidden"),L=v("toPrimitive"),C={}.propertyIsEnumerable,U=s("symbol-registry"),G=s("symbols"),D=s("op-symbols"),W=Object[R],B="function"==typeof j,V=e.QObject,z=!V||!V[R]||!V[R].findChild,K=o&&a(function(){return 7!=_(A({},"a",{get:function(){return A(this,"a",{value:7}).a}})).a})?function(t,n,r){var e=M(W,n);e&&delete W[n],A(t,n,r),e&&t!==W&&A(W,n,e);}:A,J=function(t){var n=G[t]=_(j[R]);return n._k=t,n},Y=B&&"symbol"==typeof j.iterator?function(t){return "symbol"==typeof t}:function(t){return t instanceof j},q=function defineProperty(t,n,r){return t===W&&q(D,n,r),x(t),n=w(n,!0),x(r),i(G,n)?(r.enumerable?(i(t,T)&&t[T][n]&&(t[T][n]=!1),r=_(r,{enumerable:S(0,!1)})):(i(t,T)||A(t,T,S(1,{})),t[T][n]=!0),K(t,n,r)):A(t,n,r)},X=function defineProperties(t,n){x(t);for(var r,e=g(n=m(n)),i=0,o=e.length;o>i;)q(t,r=e[i++],n[r]);return t},$=function create(t,n){return void 0===n?_(t):X(_(t),n)},H=function propertyIsEnumerable(t){var n=C.call(this,t=w(t,!0));return !(this===W&&i(G,t)&&!i(D,t))&&(!(n||!i(this,t)||!i(G,t)||i(this,T)&&this[T][t])||n)},Z=function getOwnPropertyDescriptor(t,n){if(t=m(t),n=w(n,!0),t!==W||!i(G,n)||i(D,n)){var r=M(t,n);return !r||!i(G,n)||i(t,T)&&t[T][n]||(r.enumerable=!0),r}},Q=function getOwnPropertyNames(t){for(var n,r=I(m(t)),e=[],o=0;r.length>o;)i(G,n=r[o++])||n==T||n==f||e.push(n);return e},tt=function getOwnPropertySymbols(t){for(var n,r=t===W,e=I(r?D:m(t)),o=[],u=0;e.length>u;)!i(G,n=e[u++])||r&&!i(W,n)||o.push(G[n]);return o};B||(j=function Symbol(){if(this instanceof j)throw TypeError("Symbol is not a constructor!");var t=h(arguments.length>0?arguments[0]:void 0),n=function(r){this===W&&n.call(D,r),i(this,T)&&i(this[T],t)&&(this[T][t]=!1),K(this,t,S(1,r));};return o&&z&&K(W,t,{configurable:!0,set:n}),J(t)},c(j[R],"toString",function toString(){return this._k}),O.f=Z,F.f=q,t(72).f=E.f=Q,t(77).f=H,t(73).f=tt,o&&!t(58)&&c(W,"propertyIsEnumerable",H,!0),p.f=function(t){return J(v(t))}),u(u.G+u.W+u.F*!B,{Symbol:j});for(var nt="hasInstance,isConcatSpreadable,iterator,match,replace,search,species,split,toPrimitive,toStringTag,unscopables".split(","),rt=0;nt.length>rt;)v(nt[rt++]);for(var nt=P(v.store),rt=0;nt.length>rt;)d(nt[rt++]);u(u.S+u.F*!B,"Symbol",{for:function(t){return i(U,t+="")?U[t]:U[t]=j(t)},keyFor:function keyFor(t){if(Y(t))return y(U,t);throw TypeError(t+" is not a symbol!")},useSetter:function(){z=!0;},useSimple:function(){z=!1;}}),u(u.S+u.F*!B,"Object",{create:$,defineProperty:q,defineProperties:X,getOwnPropertyDescriptor:Z,getOwnPropertyNames:Q,getOwnPropertySymbols:tt}),N&&u(u.S+u.F*(!B||a(function(){var t=j();return "[null]"!=k([t])||"{}"!=k({a:t})||"{}"!=k(Object(t))})),"JSON",{stringify:function stringify(t){if(void 0!==t&&!Y(t)){for(var n,r,e=[t],i=1;arguments.length>i;)e.push(arguments[i++]);return n=e[1],"function"==typeof n&&(r=n),!r&&b(n)||(n=function(t,n){if(r&&(n=r.call(this,t,n)),!Y(n))return n}),e[1]=n,k.apply(N,e)}}}),j[R][L]||t(40)(j[R],L,j[R].valueOf),l(j,"Symbol"),l(Math,"Math",!0),l(e.JSON,"JSON",!0);},{107:107,110:110,114:114,115:115,116:116,117:117,28:28,31:31,32:32,34:34,38:38,39:39,40:40,47:47,57:57,58:58,62:62,66:66,67:67,7:7,70:70,71:71,72:72,73:73,76:76,77:77,85:85,87:87,92:92,94:94}],244:[function(t,n,r){var e=t(32),i=t(113),o=t(112),u=t(7),c=t(105),f=t(108),a=t(49),s=t(38).ArrayBuffer,l=t(95),h=o.ArrayBuffer,v=o.DataView,p=i.ABV&&s.isView,d=h.prototype.slice,y=i.VIEW,g="ArrayBuffer";e(e.G+e.W+e.F*(s!==h),{ArrayBuffer:h}),e(e.S+e.F*!i.CONSTR,g,{isView:function isView(t){return p&&p(t)||a(t)&&y in t}}),e(e.P+e.U+e.F*t(34)(function(){return !new h(2).slice(1,void 0).byteLength}),g,{slice:function slice(t,n){if(void 0!==d&&void 0===n)return d.call(u(this),t);for(var r=u(this).byteLength,e=c(t,r),i=c(void 0===n?r:n,r),o=new(l(this,h))(f(i-e)),a=new v(this),s=new v(o),p=0;e<i;)s.setUint8(p++,a.getUint8(e++));return o}}),t(91)(g);},{105:105,108:108,112:112,113:113,32:32,34:34,38:38,49:49,7:7,91:91,95:95}],245:[function(t,n,r){var e=t(32);e(e.G+e.W+e.F*!t(113).ABV,{DataView:t(112).DataView});},{112:112,113:113,32:32}],246:[function(t,n,r){t(111)("Float32",4,function(t){return function Float32Array(n,r,e){return t(this,n,r,e)}});},{111:111}],247:[function(t,n,r){t(111)("Float64",8,function(t){return function Float64Array(n,r,e){return t(this,n,r,e)}});},{111:111}],248:[function(t,n,r){t(111)("Int16",2,function(t){return function Int16Array(n,r,e){return t(this,n,r,e)}});},{111:111}],249:[function(t,n,r){t(111)("Int32",4,function(t){return function Int32Array(n,r,e){return t(this,n,r,e)}});},{111:111}],250:[function(t,n,r){t(111)("Int8",1,function(t){return function Int8Array(n,r,e){return t(this,n,r,e)}});},{111:111}],251:[function(t,n,r){t(111)("Uint16",2,function(t){return function Uint16Array(n,r,e){return t(this,n,r,e)}});},{111:111}],252:[function(t,n,r){t(111)("Uint32",4,function(t){return function Uint32Array(n,r,e){return t(this,n,r,e)}});},{111:111}],253:[function(t,n,r){t(111)("Uint8",1,function(t){return function Uint8Array(n,r,e){return t(this,n,r,e)}});},{111:111}],254:[function(t,n,r){t(111)("Uint8",1,function(t){return function Uint8ClampedArray(n,r,e){return t(this,n,r,e)}},!0);},{111:111}],255:[function(t,n,r){var e,i=t(12)(0),o=t(87),u=t(62),c=t(65),f=t(21),a=t(49),s=u.getWeak,l=Object.isExtensible,h=f.ufstore,v={},p=function(t){return function WeakMap(){return t(this,arguments.length>0?arguments[0]:void 0)}},d={get:function get(t){if(a(t)){var n=s(t);return n===!0?h(this).get(t):n?n[this._i]:void 0}},set:function set(t,n){return f.def(this,t,n)}},y=n.exports=t(22)("WeakMap",p,d,f,!0,!0);7!=(new y).set((Object.freeze||Object)(v),7).get(v)&&(e=f.getConstructor(p),c(e.prototype,d),u.NEED=!0,i(["delete","has","get","set"],function(t){var n=y.prototype,r=n[t];o(n,t,function(n,i){if(a(n)&&!l(n)){this._f||(this._f=new e);var o=this._f[t](n,i);return "set"==t?this:o}return r.call(this,n,i)});}));},{12:12,21:21,22:22,49:49,62:62,65:65,87:87}],256:[function(t,n,r){var e=t(21);t(22)("WeakSet",function(t){return function WeakSet(){return t(this,arguments.length>0?arguments[0]:void 0)}},{add:function add(t){return e.def(this,t,!0)}},e,!1,!0);},{21:21,22:22}],257:[function(t,n,r){var e=t(32),i=t(11)(!0);e(e.P,"Array",{includes:function includes(t){return i(this,t,arguments.length>1?arguments[1]:void 0)}}),t(5)("includes");},{11:11,32:32,5:5}],258:[function(t,n,r){var e=t(32),i=t(64)(),o=t(38).process,u="process"==t(18)(o);e(e.G,{asap:function asap(t){var n=u&&o.domain;i(n?n.bind(t):t);}});},{18:18,32:32,38:38,64:64}],259:[function(t,n,r){var e=t(32),i=t(18);e(e.S,"Error",{isError:function isError(t){return "Error"===i(t)}});},{18:18,32:32}],260:[function(t,n,r){var e=t(32);e(e.P+e.R,"Map",{toJSON:t(20)("Map")});},{20:20,32:32}],261:[function(t,n,r){var e=t(32);e(e.S,"Math",{iaddh:function iaddh(t,n,r,e){var i=t>>>0,o=n>>>0,u=r>>>0;return o+(e>>>0)+((i&u|(i|u)&~(i+u>>>0))>>>31)|0}});},{32:32}],262:[function(t,n,r){var e=t(32);e(e.S,"Math",{imulh:function imulh(t,n){var r=65535,e=+t,i=+n,o=e&r,u=i&r,c=e>>16,f=i>>16,a=(c*u>>>0)+(o*u>>>16);return c*f+(a>>16)+((o*f>>>0)+(a&r)>>16)}});},{32:32}],263:[function(t,n,r){var e=t(32);e(e.S,"Math",{isubh:function isubh(t,n,r,e){var i=t>>>0,o=n>>>0,u=r>>>0;return o-(e>>>0)-((~i&u|~(i^u)&i-u>>>0)>>>31)|0}});},{32:32}],264:[function(t,n,r){var e=t(32);e(e.S,"Math",{umulh:function umulh(t,n){var r=65535,e=+t,i=+n,o=e&r,u=i&r,c=e>>>16,f=i>>>16,a=(c*u>>>0)+(o*u>>>16);return c*f+(a>>>16)+((o*f>>>0)+(a&r)>>>16)}});},{32:32}],265:[function(t,n,r){var e=t(32),i=t(109),o=t(3),u=t(67);t(28)&&e(e.P+t(69),"Object",{__defineGetter__:function __defineGetter__(t,n){u.f(i(this),t,{get:o(n),enumerable:!0,configurable:!0});}});},{109:109,28:28,3:3,32:32,67:67,69:69}],266:[function(t,n,r){var e=t(32),i=t(109),o=t(3),u=t(67);t(28)&&e(e.P+t(69),"Object",{__defineSetter__:function __defineSetter__(t,n){u.f(i(this),t,{set:o(n),enumerable:!0,configurable:!0});}});},{109:109,28:28,3:3,32:32,67:67,69:69}],267:[function(t,n,r){var e=t(32),i=t(79)(!0);e(e.S,"Object",{entries:function entries(t){return i(t)}});},{32:32,79:79}],268:[function(t,n,r){var e=t(32),i=t(80),o=t(107),u=t(70),c=t(24);e(e.S,"Object",{getOwnPropertyDescriptors:function getOwnPropertyDescriptors(t){for(var n,r=o(t),e=u.f,f=i(r),a={},s=0;f.length>s;)c(a,n=f[s++],e(r,n));return a}});},{107:107,24:24,32:32,70:70,80:80}],269:[function(t,n,r){var e=t(32),i=t(109),o=t(110),u=t(74),c=t(70).f;t(28)&&e(e.P+t(69),"Object",{__lookupGetter__:function __lookupGetter__(t){var n,r=i(this),e=o(t,!0);do if(n=c(r,e))return n.get;while(r=u(r))}});},{109:109,110:110,28:28,32:32,69:69,70:70,74:74}],270:[function(t,n,r){var e=t(32),i=t(109),o=t(110),u=t(74),c=t(70).f;t(28)&&e(e.P+t(69),"Object",{__lookupSetter__:function __lookupSetter__(t){var n,r=i(this),e=o(t,!0);do if(n=c(r,e))return n.set;while(r=u(r))}});},{109:109,110:110,28:28,32:32,69:69,70:70,74:74}],271:[function(t,n,r){var e=t(32),i=t(79)(!1);e(e.S,"Object",{values:function values(t){return i(t)}});},{32:32,79:79}],272:[function(t,n,r){var e=t(32),i=t(38),o=t(23),u=t(64)(),c=t(117)("observable"),f=t(3),a=t(7),s=t(6),l=t(86),h=t(40),v=t(37),p=v.RETURN,d=function(t){return null==t?void 0:f(t)},y=function(t){var n=t._c;n&&(t._c=void 0,n());},g=function(t){return void 0===t._o},b=function(t){g(t)||(t._o=void 0,y(t));},x=function(t,n){a(t),this._c=void 0,this._o=t,t=new m(this);try{var r=n(t),e=r;null!=r&&("function"==typeof r.unsubscribe?r=function(){e.unsubscribe();}:f(r),this._c=r);}catch(n){return void t.error(n)}g(this)&&y(this);};x.prototype=l({},{unsubscribe:function unsubscribe(){b(this);}});var m=function(t){this._s=t;};m.prototype=l({},{next:function next(t){var n=this._s;if(!g(n)){var r=n._o;try{var e=d(r.next);if(e)return e.call(r,t)}catch(t){try{b(n);}finally{throw t}}}},error:function error(t){var n=this._s;if(g(n))throw t;var r=n._o;n._o=void 0;try{var e=d(r.error);if(!e)throw t;t=e.call(r,t);}catch(t){try{y(n);}finally{throw t}}return y(n),t},complete:function complete(t){var n=this._s;if(!g(n)){var r=n._o;n._o=void 0;try{var e=d(r.complete);t=e?e.call(r,t):void 0;}catch(t){try{y(n);}finally{throw t}}return y(n),t}}});var w=function Observable(t){s(this,w,"Observable","_f")._f=f(t);};l(w.prototype,{subscribe:function subscribe(t){return new x(t,this._f)},forEach:function forEach(t){var n=this;return new(o.Promise||i.Promise)(function(r,e){f(t);var i=n.subscribe({next:function(n){try{return t(n)}catch(t){e(t),i.unsubscribe();}},error:e,complete:r});})}}),l(w,{from:function from(t){var n="function"==typeof this?this:w,r=d(a(t)[c]);if(r){var e=a(r.call(t));return e.constructor===n?e:new n(function(t){return e.subscribe(t)})}return new n(function(n){var r=!1;return u(function(){if(!r){try{if(v(t,!1,function(t){if(n.next(t),r)return p})===p)return}catch(t){if(r)throw t;return void n.error(t)}n.complete();}}),function(){r=!0;}})},of:function of(){for(var t=0,n=arguments.length,r=Array(n);t<n;)r[t]=arguments[t++];return new("function"==typeof this?this:w)(function(t){var n=!1;return u(function(){if(!n){for(var e=0;e<r.length;++e)if(t.next(r[e]),n)return;t.complete();}}),function(){n=!0;}})}}),h(w.prototype,c,function(){return this}),e(e.G,{Observable:w}),t(91)("Observable");},{117:117,23:23,3:3,32:32,37:37,38:38,40:40,6:6,64:64,7:7,86:86,91:91}],273:[function(t,n,r){var e=t(63),i=t(7),o=e.key,u=e.set;e.exp({defineMetadata:function defineMetadata(t,n,r,e){u(t,n,i(r),o(e));}});},{63:63,7:7}],274:[function(t,n,r){var e=t(63),i=t(7),o=e.key,u=e.map,c=e.store;e.exp({deleteMetadata:function deleteMetadata(t,n){var r=arguments.length<3?void 0:o(arguments[2]),e=u(i(n),r,!1);if(void 0===e||!e.delete(t))return !1;if(e.size)return !0;var f=c.get(n);return f.delete(r),!!f.size||c.delete(n)}});},{63:63,7:7}],275:[function(t,n,r){var e=t(220),i=t(10),o=t(63),u=t(7),c=t(74),f=o.keys,a=o.key,s=function(t,n){var r=f(t,n),o=c(t);if(null===o)return r;var u=s(o,n);return u.length?r.length?i(new e(r.concat(u))):u:r};o.exp({getMetadataKeys:function getMetadataKeys(t){return s(u(t),arguments.length<2?void 0:a(arguments[1]))}});},{10:10,220:220,63:63,7:7,74:74}],276:[function(t,n,r){var e=t(63),i=t(7),o=t(74),u=e.has,c=e.get,f=e.key,a=function(t,n,r){var e=u(t,n,r);if(e)return c(t,n,r);var i=o(n);return null!==i?a(t,i,r):void 0};e.exp({getMetadata:function getMetadata(t,n){return a(t,i(n),arguments.length<3?void 0:f(arguments[2]))}});},{63:63,7:7,74:74}],277:[function(t,n,r){var e=t(63),i=t(7),o=e.keys,u=e.key;e.exp({getOwnMetadataKeys:function getOwnMetadataKeys(t){return o(i(t),arguments.length<2?void 0:u(arguments[1]))}});},{63:63,7:7}],278:[function(t,n,r){var e=t(63),i=t(7),o=e.get,u=e.key;e.exp({getOwnMetadata:function getOwnMetadata(t,n){return o(t,i(n),arguments.length<3?void 0:u(arguments[2]))}});},{63:63,7:7}],279:[function(t,n,r){var e=t(63),i=t(7),o=t(74),u=e.has,c=e.key,f=function(t,n,r){var e=u(t,n,r);if(e)return !0;var i=o(n);return null!==i&&f(t,i,r)};e.exp({hasMetadata:function hasMetadata(t,n){return f(t,i(n),arguments.length<3?void 0:c(arguments[2]))}});},{63:63,7:7,74:74}],280:[function(t,n,r){var e=t(63),i=t(7),o=e.has,u=e.key;e.exp({hasOwnMetadata:function hasOwnMetadata(t,n){return o(t,i(n),arguments.length<3?void 0:u(arguments[2]))}});},{63:63,7:7}],281:[function(t,n,r){var e=t(63),i=t(7),o=t(3),u=e.key,c=e.set;e.exp({metadata:function metadata(t,n){return function decorator(r,e){c(t,n,(void 0!==e?i:o)(r),u(e));}}});},{3:3,63:63,7:7}],282:[function(t,n,r){var e=t(32);e(e.P+e.R,"Set",{toJSON:t(20)("Set")});},{20:20,32:32}],283:[function(t,n,r){var e=t(32),i=t(97)(!0);e(e.P,"String",{at:function at(t){return i(this,t)}});},{32:32,97:97}],284:[function(t,n,r){var e=t(32),i=t(27),o=t(108),u=t(50),c=t(36),f=RegExp.prototype,a=function(t,n){this._r=t,this._s=n;};t(52)(a,"RegExp String",function next(){var t=this._r.exec(this._s);return {value:t,done:null===t}}),e(e.P,"String",{matchAll:function matchAll(t){if(i(this),!u(t))throw TypeError(t+" is not a regexp!");var n=String(this),r="flags"in f?String(t.flags):c.call(t),e=new RegExp(t.source,~r.indexOf("g")?r:"g"+r);return e.lastIndex=o(t.lastIndex),new a(e,n)}});},{108:108,27:27,32:32,36:36,50:50,52:52}],285:[function(t,n,r){var e=t(32),i=t(100);e(e.P,"String",{padEnd:function padEnd(t){return i(this,t,arguments.length>1?arguments[1]:void 0,!1)}});},{100:100,32:32}],286:[function(t,n,r){var e=t(32),i=t(100);e(e.P,"String",{padStart:function padStart(t){return i(this,t,arguments.length>1?arguments[1]:void 0,!0)}});},{100:100,32:32}],287:[function(t,n,r){t(102)("trimLeft",function(t){return function trimLeft(){return t(this,1)}},"trimStart");},{102:102}],288:[function(t,n,r){t(102)("trimRight",function(t){return function trimRight(){return t(this,2)}},"trimEnd");},{102:102}],289:[function(t,n,r){t(115)("asyncIterator");},{115:115}],290:[function(t,n,r){t(115)("observable");},{115:115}],291:[function(t,n,r){var e=t(32);e(e.S,"System",{global:t(38)});},{32:32,38:38}],292:[function(t,n,r){for(var e=t(130),i=t(87),o=t(38),u=t(40),c=t(56),f=t(117),a=f("iterator"),s=f("toStringTag"),l=c.Array,h=["NodeList","DOMTokenList","MediaList","StyleSheetList","CSSRuleList"],v=0;v<5;v++){var p,d=h[v],y=o[d],g=y&&y.prototype;if(g){g[a]||u(g,a,l),g[s]||u(g,s,d),c[d]=l;for(p in e)g[p]||i(g,p,e[p],!0);}}},{117:117,130:130,38:38,40:40,56:56,87:87}],293:[function(t,n,r){var e=t(32),i=t(104);e(e.G+e.B,{setImmediate:i.set,clearImmediate:i.clear});},{104:104,32:32}],294:[function(t,n,r){var e=t(38),i=t(32),o=t(44),u=t(83),c=e.navigator,f=!!c&&/MSIE .\./.test(c.userAgent),a=function(t){return f?function(n,r){return t(o(u,[].slice.call(arguments,2),"function"==typeof n?n:Function(n)),r)}:t};i(i.G+i.B+i.F*f,{setTimeout:a(e.setTimeout),setInterval:a(e.setInterval)});},{32:32,38:38,44:44,83:83}],295:[function(t,n,r){t(243),t(180),t(182),t(181),t(184),t(186),t(191),t(185),t(183),t(193),t(192),t(188),t(189),t(187),t(179),t(190),t(194),t(195),t(146),t(148),t(147),t(197),t(196),t(167),t(177),t(178),t(168),t(169),t(170),t(171),t(172),t(173),t(174),t(175),t(176),t(150),t(151),t(152),t(153),t(154),t(155),t(156),t(157),t(158),t(159),t(160),t(161),t(162),t(163),t(164),t(165),t(166),t(230),t(235),t(242),t(233),t(225),t(226),t(231),t(236),t(238),t(221),t(222),t(223),t(224),t(227),t(228),t(229),t(232),t(234),t(237),t(239),t(240),t(241),t(141),t(143),t(142),t(145),t(144),t(129),t(127),t(134),t(131),t(137),t(139),t(126),t(133),t(123),t(138),t(121),t(136),t(135),t(128),t(132),t(120),t(122),t(125),t(124),t(140),t(130),t(213),t(219),t(214),t(215),t(216),t(217),t(218),t(198),t(149),t(220),t(255),t(256),t(244),t(245),t(250),t(253),t(254),t(248),t(251),t(249),t(252),t(246),t(247),t(199),t(200),t(201),t(202),t(203),t(206),t(204),t(205),t(207),t(208),t(209),t(210),t(212),t(211),t(257),t(283),t(286),t(285),t(287),t(288),t(284),t(289),t(290),t(268),t(271),t(267),t(265),t(266),t(269),t(270),t(260),t(282),t(291),t(259),t(261),t(263),t(262),t(264),t(273),t(274),t(276),t(275),t(278),t(277),t(279),t(280),t(281),t(258),t(272),t(294),t(293),t(292),n.exports=t(23);},{120:120,121:121,122:122,123:123,124:124,125:125,126:126,127:127,128:128,129:129,130:130,131:131,132:132,133:133,134:134,135:135,136:136,137:137,138:138,139:139,140:140,141:141,142:142,143:143,144:144,145:145,146:146,147:147,148:148,149:149,150:150,151:151,152:152,153:153,154:154,155:155,156:156,157:157,158:158,159:159,160:160,161:161,162:162,163:163,164:164,165:165,166:166,167:167,168:168,169:169,170:170,171:171,172:172,173:173,174:174,175:175,176:176,177:177,178:178,179:179,180:180,181:181,182:182,183:183,184:184,185:185,186:186,187:187,188:188,189:189,190:190,191:191,192:192,193:193,194:194,195:195,196:196,197:197,198:198,199:199,200:200,201:201,202:202,203:203,204:204,205:205,206:206,207:207,208:208,209:209,210:210,211:211,212:212,213:213,214:214,215:215,216:216,217:217,218:218,219:219,220:220,221:221,222:222,223:223,224:224,225:225,226:226,227:227,228:228,229:229,23:23,230:230,231:231,232:232,233:233,234:234,235:235,236:236,237:237,238:238,239:239,240:240,241:241,242:242,243:243,244:244,245:245,246:246,247:247,248:248,249:249,250:250,251:251,252:252,253:253,254:254,255:255,256:256,257:257,258:258,259:259,260:260,261:261,262:262,263:263,264:264,265:265,266:266,267:267,268:268,269:269,270:270,271:271,272:272,273:273,274:274,275:275,276:276,277:277,278:278,279:279,280:280,281:281,282:282,283:283,284:284,285:285,286:286,287:287,288:288,289:289,290:290,291:291,292:292,293:293,294:294}],296:[function(t,n,r){(function(t){!function(t){function wrap(t,n,r,e){var i=n&&n.prototype instanceof Generator?n:Generator,o=Object.create(i.prototype),u=new Context(e||[]);return o._invoke=makeInvokeMethod(t,r,u),o}function tryCatch(t,n,r){try{return {type:"normal",arg:t.call(n,r)}}catch(t){return {type:"throw",arg:t}}}function Generator(){}function GeneratorFunction(){}function GeneratorFunctionPrototype(){}function defineIteratorMethods(t){["next","throw","return"].forEach(function(n){t[n]=function(t){return this._invoke(n,t)};});}function AsyncIterator(t){function invoke(n,r,e,o){var u=tryCatch(t[n],t,r);if("throw"!==u.type){var c=u.arg,f=c.value;return f&&"object"==typeof f&&i.call(f,"__await")?Promise.resolve(f.__await).then(function(t){invoke("next",t,e,o);},function(t){invoke("throw",t,e,o);}):Promise.resolve(f).then(function(t){c.value=t,e(c);},o)}o(u.arg);}function enqueue(t,r){function callInvokeWithMethodAndArg(){return new Promise(function(n,e){invoke(t,r,n,e);})}return n=n?n.then(callInvokeWithMethodAndArg,callInvokeWithMethodAndArg):callInvokeWithMethodAndArg()}"object"==typeof process&&process.domain&&(invoke=process.domain.bind(invoke));var n;this._invoke=enqueue;}function makeInvokeMethod(t,n,e){var i=s;return function invoke(o,u){if(i===h)throw new Error("Generator is already running");if(i===v){if("throw"===o)throw u;return doneResult()}for(;;){var c=e.delegate;if(c){if("return"===o||"throw"===o&&c.iterator[o]===r){e.delegate=null;var f=c.iterator.return;if(f){var a=tryCatch(f,c.iterator,u);if("throw"===a.type){o="throw",u=a.arg;continue}}if("return"===o)continue}var a=tryCatch(c.iterator[o],c.iterator,u);if("throw"===a.type){e.delegate=null,o="throw",u=a.arg;continue}o="next",u=r;var d=a.arg;if(!d.done)return i=l,d;e[c.resultName]=d.value,e.next=c.nextLoc,e.delegate=null;}if("next"===o)e.sent=e._sent=u;else if("throw"===o){if(i===s)throw i=v,u;e.dispatchException(u)&&(o="next",u=r);}else "return"===o&&e.abrupt("return",u);i=h;var a=tryCatch(t,n,e);if("normal"===a.type){i=e.done?v:l;var d={value:a.arg,done:e.done};if(a.arg!==p)return d;e.delegate&&"next"===o&&(u=r);}else "throw"===a.type&&(i=v,o="throw",u=a.arg);}}}function pushTryEntry(t){var n={tryLoc:t[0]};1 in t&&(n.catchLoc=t[1]),2 in t&&(n.finallyLoc=t[2],n.afterLoc=t[3]),this.tryEntries.push(n);}function resetTryEntry(t){var n=t.completion||{};n.type="normal",delete n.arg,t.completion=n;}function Context(t){this.tryEntries=[{tryLoc:"root"}],t.forEach(pushTryEntry,this),this.reset(!0);}function values(t){if(t){var n=t[u];if(n)return n.call(t);if("function"==typeof t.next)return t;if(!isNaN(t.length)){var e=-1,o=function next(){for(;++e<t.length;)if(i.call(t,e))return next.value=t[e],next.done=!1,next;return next.value=r,next.done=!0,next};return o.next=o}}return {next:doneResult}}function doneResult(){return {value:r,done:!0}}var r,e=Object.prototype,i=e.hasOwnProperty,o="function"==typeof Symbol?Symbol:{},u=o.iterator||"@@iterator",c=o.toStringTag||"@@toStringTag",f="object"==typeof n,a=t.regeneratorRuntime;if(a)return void(f&&(n.exports=a));a=t.regeneratorRuntime=f?n.exports:{},a.wrap=wrap;var s="suspendedStart",l="suspendedYield",h="executing",v="completed",p={},d={};d[u]=function(){return this};var y=Object.getPrototypeOf,g=y&&y(y(values([])));g&&g!==e&&i.call(g,u)&&(d=g);var b=GeneratorFunctionPrototype.prototype=Generator.prototype=Object.create(d);GeneratorFunction.prototype=b.constructor=GeneratorFunctionPrototype,GeneratorFunctionPrototype.constructor=GeneratorFunction,GeneratorFunctionPrototype[c]=GeneratorFunction.displayName="GeneratorFunction",a.isGeneratorFunction=function(t){var n="function"==typeof t&&t.constructor;return !!n&&(n===GeneratorFunction||"GeneratorFunction"===(n.displayName||n.name))},a.mark=function(t){return Object.setPrototypeOf?Object.setPrototypeOf(t,GeneratorFunctionPrototype):(t.__proto__=GeneratorFunctionPrototype,c in t||(t[c]="GeneratorFunction")),t.prototype=Object.create(b),t},a.awrap=function(t){return {__await:t}},defineIteratorMethods(AsyncIterator.prototype),a.AsyncIterator=AsyncIterator,a.async=function(t,n,r,e){var i=new AsyncIterator(wrap(t,n,r,e));return a.isGeneratorFunction(n)?i:i.next().then(function(t){return t.done?t.value:i.next()})},defineIteratorMethods(b),b[c]="Generator",b.toString=function(){return "[object Generator]"},a.keys=function(t){var n=[];for(var r in t)n.push(r);return n.reverse(),function next(){for(;n.length;){var r=n.pop();if(r in t)return next.value=r,next.done=!1,next}return next.done=!0,next}},a.values=values,Context.prototype={constructor:Context,reset:function(t){if(this.prev=0,this.next=0,this.sent=this._sent=r,this.done=!1,this.delegate=null,this.tryEntries.forEach(resetTryEntry),!t)for(var n in this)"t"===n.charAt(0)&&i.call(this,n)&&!isNaN(+n.slice(1))&&(this[n]=r);},stop:function(){this.done=!0;var t=this.tryEntries[0],n=t.completion;if("throw"===n.type)throw n.arg;return this.rval},dispatchException:function(t){function handle(r,e){return o.type="throw",o.arg=t,n.next=r,!!e}if(this.done)throw t;for(var n=this,r=this.tryEntries.length-1;r>=0;--r){var e=this.tryEntries[r],o=e.completion;
if("root"===e.tryLoc)return handle("end");if(e.tryLoc<=this.prev){var u=i.call(e,"catchLoc"),c=i.call(e,"finallyLoc");if(u&&c){if(this.prev<e.catchLoc)return handle(e.catchLoc,!0);if(this.prev<e.finallyLoc)return handle(e.finallyLoc)}else if(u){if(this.prev<e.catchLoc)return handle(e.catchLoc,!0)}else {if(!c)throw new Error("try statement without catch or finally");if(this.prev<e.finallyLoc)return handle(e.finallyLoc)}}}},abrupt:function(t,n){for(var r=this.tryEntries.length-1;r>=0;--r){var e=this.tryEntries[r];if(e.tryLoc<=this.prev&&i.call(e,"finallyLoc")&&this.prev<e.finallyLoc){var o=e;break}}o&&("break"===t||"continue"===t)&&o.tryLoc<=n&&n<=o.finallyLoc&&(o=null);var u=o?o.completion:{};return u.type=t,u.arg=n,o?this.next=o.finallyLoc:this.complete(u),p},complete:function(t,n){if("throw"===t.type)throw t.arg;"break"===t.type||"continue"===t.type?this.next=t.arg:"return"===t.type?(this.rval=t.arg,this.next="end"):"normal"===t.type&&n&&(this.next=n);},finish:function(t){for(var n=this.tryEntries.length-1;n>=0;--n){var r=this.tryEntries[n];if(r.finallyLoc===t)return this.complete(r.completion,r.afterLoc),resetTryEntry(r),p}},catch:function(t){for(var n=this.tryEntries.length-1;n>=0;--n){var r=this.tryEntries[n];if(r.tryLoc===t){var e=r.completion;if("throw"===e.type){var i=e.arg;resetTryEntry(r);}return i}}throw new Error("illegal catch attempt")},delegateYield:function(t,n,r){return this.delegate={iterator:values(t),resultName:n,nextLoc:r},p}};}("object"==typeof t?t:"object"==typeof window?window:"object"==typeof self?self:this);}).call(this,"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{});},{}]},{},[1]);

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
    // Set a ujs adapter to support both rails-ujs and jquery-ujs
    var ujs = typeof Rails === 'undefined' ? $.rails : Rails;
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
        'X-CSRF-Token': ujs.csrfToken() || ''
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

// Place all the behaviors and hooks related to the matching controller here.

class Pages {
  connect(){
    // Set a ujs adapter to support both rails-ujs and jquery-ujs
    var ujs = typeof Rails === 'undefined' ? $.rails : Rails;
    SirTrevor.setDefaults({
      iconUrl: Spotlight$1.sirTrevorIcon,
      uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint'),
      ajaxOptions: {
        headers: {
          'X-CSRF-Token': ujs.csrfToken() || ''
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
          suggestion: Handlebars.compile(settings.template)
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
function itemsTemplate() {
  return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>';
}

function addAutocompletetoFeaturedImage(){
  if($('[data-featured-image-typeahead]').length > 0) {
    $('[data-featured-image-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: itemsTemplate()}).on('click', function() {
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
      id = $(this).attr('data-target');
      edit_view = $("[data-edit-for='"+id+"']", container).show();
      $.each(edit_view.find('input[type="text"], select'), function() {
        // Cache original values incase editing is canceled
        $(this).data('orig', $(this).val());
      });
    }

    function cancel_edit(event) {
      event.preventDefault();
      id = $(this).closest('tr').attr('data-edit-for');
      edit_view = $("[data-edit-for='"+id+"']", container).hide();
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
      id = $(this).attr('data-target');
      $("[data-destroy-for='"+id+"']", container).val('1');
    }

    function new_user(event) {
      event.preventDefault();
      edit_view = $("[data-edit-for='new']", container).show();
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

      if (this['autocomplete_template'] === undefined) {
        this.autocomplete_url = function() { return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' };
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
      $('[data-twitter-typeahead]', this.inner).spotlightSearchTypeAhead({bloodhound: this.bloodhound(), template: this.autocomplete_template()}).on('typeahead:selected typeahead:autocompleted', this.autocompletedHandler()).on( 'focus', function() {
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
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}">{{#if thumbnail_image_url}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail_image_url}}" /></div>{{/if}}<span class="autocomplete-title">{{full_title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },

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
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}"><span class="autocomplete-title">{{title}}</span><br/></div>' },
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
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}">{{#if thumbnail_image_url}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail_image_url}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },
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
    autocomplete_template: function() { return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },

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

    _itemPanelIiifFields: function(index, data) {
      return [
        // '<input type="hidden" name="item[' + index + '][iiif_region]" value="' + (data.iiif_region) + '"/>',
        // for legacy compatiblity:
        '<input type="hidden" name="item[' + index + '][thumbnail_image_url]" value="' + (data.thumbnail_image_url || data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][full_image_url]" value="' + (data.full_image_url || data.thumbnail_image_url || data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_tilesource]" value="' + (data.iiif_tilesource) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_manifest_url]" value="' + (data.iiif_manifest_url) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_canvas_id]" value="' + (data.iiif_canvas_id) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_image_id]" value="' + (data.iiif_image_id) + '"/>',
      ].join("\n");
    },
    setIiifFields: function(panel, data, initialize) {
      var legacyThumbnailField = $(panel).find('[name$="[thumbnail_image_url]"]');
      var legacyFullField = $(panel).find('[name$="[full_image_url]"]');

      if (initialize && legacyThumbnailField.val().length > 0) {
        return;
      }

      legacyThumbnailField.val("");
      legacyFullField.val("");
      $(panel).find('[name$="[iiif_image_id]"]').val(data.imageId);
      $(panel).find('[name$="[iiif_tilesource]"]').val(data.tilesource);
      $(panel).find('[name$="[iiif_manifest_url]"]').val(data.manifest);
      $(panel).find('[name$="[iiif_canvas_id]"]').val(data.canvasId);
      $(panel).find('img.img-thumbnail').attr('src', data.thumbnail_image_url || data.tilesource.replace("/info.json", "/full/100,100/0/default.jpg"));
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
            </div>,
            <input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />
          </div>'
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

// import '../../../../vendor/assets/javascripts/sir-trevor'


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
//# sourceMappingURL=spotlight.esm.js.map
