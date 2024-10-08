(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory(require('leaflet'), require('clipboard'), require('blacklight-frontend'), require('sir-trevor')) :
  typeof define === 'function' && define.amd ? define(['leaflet', 'clipboard', 'blacklight-frontend', 'sir-trevor'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.Spotlight = factory(global.L, global.Clipboard, global.Blacklight, global.SirTrevor));
})(this, (function (require$$0, Clipboard, Blacklight, SirTrevor) { 'use strict';

  const _interopDefaultLegacy = e => e && typeof e === 'object' && 'default' in e ? e : { default: e };

  const require$$0__default = /*#__PURE__*/_interopDefaultLegacy(require$$0);
  const Clipboard__default = /*#__PURE__*/_interopDefaultLegacy(Clipboard);
  const Blacklight__default = /*#__PURE__*/_interopDefaultLegacy(Blacklight);
  const SirTrevor__default = /*#__PURE__*/_interopDefaultLegacy(SirTrevor);

  // Includes an unreleased RTL support pull request: https://github.com/ganlanyuan/tiny-slider/pull/658
  // Includes "export default tns" at the end of the file for spotlight/user/browse_group_categories.js
  var tns = (function (){
  var win = window;

  var raf = win.requestAnimationFrame
    || win.webkitRequestAnimationFrame
    || win.mozRequestAnimationFrame
    || win.msRequestAnimationFrame
    || function(cb) { return setTimeout(cb, 16); };

  var win$1 = window;

  var caf = win$1.cancelAnimationFrame
    || win$1.mozCancelAnimationFrame
    || function(id){ clearTimeout(id); };

  function extend() {
    var obj, name, copy,
        target = arguments[0] || {},
        i = 1,
        length = arguments.length;

    for (; i < length; i++) {
      if ((obj = arguments[i]) !== null) {
        for (name in obj) {
          copy = obj[name];

          if (target === copy) {
            continue;
          } else if (copy !== undefined) {
            target[name] = copy;
          }
        }
      }
    }
    return target;
  }

  function checkStorageValue (value) {
    return ['true', 'false'].indexOf(value) >= 0 ? JSON.parse(value) : value;
  }

  function setLocalStorage(storage, key, value, access) {
    if (access) {
      try { storage.setItem(key, value); } catch (e) {}
    }
    return value;
  }

  function getSlideId() {
    var id = window.tnsId;
    window.tnsId = !id ? 1 : id + 1;
    
    return 'tns' + window.tnsId;
  }

  function getBody () {
    var doc = document,
        body = doc.body;

    if (!body) {
      body = doc.createElement('body');
      body.fake = true;
    }

    return body;
  }

  var docElement = document.documentElement;

  function setFakeBody (body) {
    var docOverflow = '';
    if (body.fake) {
      docOverflow = docElement.style.overflow;
      //avoid crashing IE8, if background image is used
      body.style.background = '';
      //Safari 5.13/5.1.4 OSX stops loading if ::-webkit-scrollbar is used and scrollbars are visible
      body.style.overflow = docElement.style.overflow = 'hidden';
      docElement.appendChild(body);
    }

    return docOverflow;
  }

  function resetFakeBody (body, docOverflow) {
    if (body.fake) {
      body.remove();
      docElement.style.overflow = docOverflow;
      // Trigger layout so kinetic scrolling isn't disabled in iOS6+
      // eslint-disable-next-line
      docElement.offsetHeight;
    }
  }

  // get css-calc 

  function calc() {
    var doc = document, 
        body = getBody(),
        docOverflow = setFakeBody(body),
        div = doc.createElement('div'), 
        result = false;

    body.appendChild(div);
    try {
      var str = '(10px * 10)',
          vals = ['calc' + str, '-moz-calc' + str, '-webkit-calc' + str],
          val;
      for (var i = 0; i < 3; i++) {
        val = vals[i];
        div.style.width = val;
        if (div.offsetWidth === 100) { 
          result = val.replace(str, ''); 
          break;
        }
      }
    } catch (e) {}
    
    body.fake ? resetFakeBody(body, docOverflow) : div.remove();

    return result;
  }

  // get subpixel support value

  function percentageLayout() {
    // check subpixel layout supporting
    var doc = document,
        body = getBody(),
        docOverflow = setFakeBody(body),
        wrapper = doc.createElement('div'),
        outer = doc.createElement('div'),
        str = '',
        count = 70,
        perPage = 3,
        supported = false;

    wrapper.className = "tns-t-subp2";
    outer.className = "tns-t-ct";

    for (var i = 0; i < count; i++) {
      str += '<div></div>';
    }

    outer.innerHTML = str;
    wrapper.appendChild(outer);
    body.appendChild(wrapper);

    supported = Math.abs(wrapper.getBoundingClientRect().left - outer.children[count - perPage].getBoundingClientRect().left) < 2;

    body.fake ? resetFakeBody(body, docOverflow) : wrapper.remove();

    return supported;
  }

  function mediaquerySupport () {
    if (window.matchMedia || window.msMatchMedia) {
      return true;
    }
    
    var doc = document,
        body = getBody(),
        docOverflow = setFakeBody(body),
        div = doc.createElement('div'),
        style = doc.createElement('style'),
        rule = '@media all and (min-width:1px){.tns-mq-test{position:absolute}}',
        position;

    style.type = 'text/css';
    div.className = 'tns-mq-test';

    body.appendChild(style);
    body.appendChild(div);

    if (style.styleSheet) {
      style.styleSheet.cssText = rule;
    } else {
      style.appendChild(doc.createTextNode(rule));
    }

    position = window.getComputedStyle ? window.getComputedStyle(div).position : div.currentStyle['position'];

    body.fake ? resetFakeBody(body, docOverflow) : div.remove();

    return position === "absolute";
  }

  // create and append style sheet
  function createStyleSheet (media, nonce) {
    // Create the <style> tag
    var style = document.createElement("style");
    // style.setAttribute("type", "text/css");

    // Add a media (and/or media query) here if you'd like!
    // style.setAttribute("media", "screen")
    // style.setAttribute("media", "only screen and (max-width : 1024px)")
    if (media) { style.setAttribute("media", media); }

    // Add nonce attribute for Content Security Policy
    if (nonce) { style.setAttribute("nonce", nonce); }

    // WebKit hack :(
    // style.appendChild(document.createTextNode(""));

    // Add the <style> element to the page
    document.querySelector('head').appendChild(style);

    return style.sheet ? style.sheet : style.styleSheet;
  }

  // cross browsers addRule method
  function addCSSRule(sheet, selector, rules, index) {
    // return raf(function() {
      'insertRule' in sheet ?
        sheet.insertRule(selector + '{' + rules + '}', index) :
        sheet.addRule(selector, rules, index);
    // });
  }

  // cross browsers addRule method
  function removeCSSRule(sheet, index) {
    // return raf(function() {
      'deleteRule' in sheet ?
        sheet.deleteRule(index) :
        sheet.removeRule(index);
    // });
  }

  function getCssRulesLength(sheet) {
    var rule = ('insertRule' in sheet) ? sheet.cssRules : sheet.rules;
    return rule.length;
  }

  function toDegree (y, x) {
    return Math.atan2(y, x) * (180 / Math.PI);
  }

  function getTouchDirection(angle, range) {
    var direction = false,
        gap = Math.abs(90 - Math.abs(angle));
        
    if (gap >= 90 - range) {
      direction = 'horizontal';
    } else if (gap <= range) {
      direction = 'vertical';
    }

    return direction;
  }

  // https://toddmotto.com/ditch-the-array-foreach-call-nodelist-hack/
  function forEach (arr, callback, scope) {
    for (var i = 0, l = arr.length; i < l; i++) {
      callback.call(scope, arr[i], i);
    }
  }

  var classListSupport = 'classList' in document.createElement('_');

  var hasClass = classListSupport ?
      function (el, str) { return el.classList.contains(str); } :
      function (el, str) { return el.className.indexOf(str) >= 0; };

  var addClass = classListSupport ?
      function (el, str) {
        if (!hasClass(el,  str)) { el.classList.add(str); }
      } :
      function (el, str) {
        if (!hasClass(el,  str)) { el.className += ' ' + str; }
      };

  var removeClass = classListSupport ?
      function (el, str) {
        if (hasClass(el,  str)) { el.classList.remove(str); }
      } :
      function (el, str) {
        if (hasClass(el, str)) { el.className = el.className.replace(str, ''); }
      };

  function hasAttr(el, attr) {
    return el.hasAttribute(attr);
  }

  function getAttr(el, attr) {
    return el.getAttribute(attr);
  }

  function isNodeList(el) {
    // Only NodeList has the "item()" function
    return typeof el.item !== "undefined"; 
  }

  function setAttrs(els, attrs) {
    els = (isNodeList(els) || els instanceof Array) ? els : [els];
    if (Object.prototype.toString.call(attrs) !== '[object Object]') { return; }

    for (var i = els.length; i--;) {
      for(var key in attrs) {
        els[i].setAttribute(key, attrs[key]);
      }
    }
  }

  function removeAttrs(els, attrs) {
    els = (isNodeList(els) || els instanceof Array) ? els : [els];
    attrs = (attrs instanceof Array) ? attrs : [attrs];

    var attrLength = attrs.length;
    for (var i = els.length; i--;) {
      for (var j = attrLength; j--;) {
        els[i].removeAttribute(attrs[j]);
      }
    }
  }

  function arrayFromNodeList (nl) {
    var arr = [];
    for (var i = 0, l = nl.length; i < l; i++) {
      arr.push(nl[i]);
    }
    return arr;
  }

  function hideElement(el, forceHide) {
    if (el.style.display !== 'none') { el.style.display = 'none'; }
  }

  function showElement(el, forceHide) {
    if (el.style.display === 'none') { el.style.display = ''; }
  }

  function isVisible(el) {
    return window.getComputedStyle(el).display !== 'none';
  }

  function whichProperty(props){
    if (typeof props === 'string') {
      var arr = [props],
          Props = props.charAt(0).toUpperCase() + props.substr(1),
          prefixes = ['Webkit', 'Moz', 'ms', 'O'];
          
      prefixes.forEach(function(prefix) {
        if (prefix !== 'ms' || props === 'transform') {
          arr.push(prefix + Props);
        }
      });

      props = arr;
    }

    var el = document.createElement('fakeelement');
        props.length;
    for(var i = 0; i < props.length; i++){
      var prop = props[i];
      if( el.style[prop] !== undefined ){ return prop; }
    }

    return false; // explicit for ie9-
  }

  function has3DTransforms(tf){
    if (!tf) { return false; }
    if (!window.getComputedStyle) { return false; }
    
    var doc = document,
        body = getBody(),
        docOverflow = setFakeBody(body),
        el = doc.createElement('p'),
        has3d,
        cssTF = tf.length > 9 ? '-' + tf.slice(0, -9).toLowerCase() + '-' : '';

    cssTF += 'transform';

    // Add it to the body to get the computed style
    body.insertBefore(el, null);

    el.style[tf] = 'translate3d(1px,1px,1px)';
    has3d = window.getComputedStyle(el).getPropertyValue(cssTF);

    body.fake ? resetFakeBody(body, docOverflow) : el.remove();

    return (has3d !== undefined && has3d.length > 0 && has3d !== "none");
  }

  // get transitionend, animationend based on transitionDuration
  // @propin: string
  // @propOut: string, first-letter uppercase
  // Usage: getEndProperty('WebkitTransitionDuration', 'Transition') => webkitTransitionEnd
  function getEndProperty(propIn, propOut) {
    var endProp = false;
    if (/^Webkit/.test(propIn)) {
      endProp = 'webkit' + propOut + 'End';
    } else if (/^O/.test(propIn)) {
      endProp = 'o' + propOut + 'End';
    } else if (propIn) {
      endProp = propOut.toLowerCase() + 'end';
    }
    return endProp;
  }

  // Test via a getter in the options object to see if the passive property is accessed
  var supportsPassive = false;
  try {
    var opts = Object.defineProperty({}, 'passive', {
      get: function() {
        supportsPassive = true;
      }
    });
    window.addEventListener("test", null, opts);
  } catch (e) {}
  var passiveOption = supportsPassive ? { passive: true } : false;

  function addEvents(el, obj, preventScrolling) {
    for (var prop in obj) {
      var option = ['touchstart', 'touchmove'].indexOf(prop) >= 0 && !preventScrolling ? passiveOption : false;
      el.addEventListener(prop, obj[prop], option);
    }
  }

  function removeEvents(el, obj) {
    for (var prop in obj) {
      var option = ['touchstart', 'touchmove'].indexOf(prop) >= 0 ? passiveOption : false;
      el.removeEventListener(prop, obj[prop], option);
    }
  }

  function Events() {
    return {
      topics: {},
      on: function (eventName, fn) {
        this.topics[eventName] = this.topics[eventName] || [];
        this.topics[eventName].push(fn);
      },
      off: function(eventName, fn) {
        if (this.topics[eventName]) {
          for (var i = 0; i < this.topics[eventName].length; i++) {
            if (this.topics[eventName][i] === fn) {
              this.topics[eventName].splice(i, 1);
              break;
            }
          }
        }
      },
      emit: function (eventName, data) {
        data.type = eventName;
        if (this.topics[eventName]) {
          this.topics[eventName].forEach(function(fn) {
            fn(data, eventName);
          });
        }
      }
    };
  }

  function jsTransform(element, attr, prefix, postfix, to, duration, callback) {
    var tick = Math.min(duration, 10),
        unit = (to.indexOf('%') >= 0) ? '%' : 'px',
        to = to.replace(unit, ''),
        from = Number(element.style[attr].replace(prefix, '').replace(postfix, '').replace(unit, '')),
        positionTick = (to - from) / duration * tick;

    setTimeout(moveElement, tick);
    function moveElement() {
      duration -= tick;
      from += positionTick;
      element.style[attr] = prefix + from + unit + postfix;
      if (duration > 0) { 
        setTimeout(moveElement, tick); 
      } else {
        callback();
      }
    }
  }

  // Object.keys
  if (!Object.keys) {
    Object.keys = function(object) {
      var keys = [];
      for (var name in object) {
        if (Object.prototype.hasOwnProperty.call(object, name)) {
          keys.push(name);
        }
      }
      return keys;
    };
  }

  // ChildNode.remove
  if(!("remove" in Element.prototype)){
    Element.prototype.remove = function(){
      if(this.parentNode) {
        this.parentNode.removeChild(this);
      }
    };
  }

  var tns = function(options) {
    options = extend({
      container: '.slider',
      mode: 'carousel',
      axis: 'horizontal',
      items: 1,
      gutter: 0,
      edgePadding: 0,
      fixedWidth: false,
      autoWidth: false,
      viewportMax: false,
      slideBy: 1,
      center: false,
      controls: true,
      controlsPosition: 'top',
      controlsText: ['prev', 'next'],
      controlsContainer: false,
      prevButton: false,
      nextButton: false,
      nav: true,
      navPosition: 'top',
      navContainer: false,
      navAsThumbnails: false,
      arrowKeys: false,
      speed: 300,
      autoplay: false,
      autoplayPosition: 'top',
      autoplayTimeout: 5000,
      autoplayDirection: 'forward',
      autoplayText: ['start', 'stop'],
      autoplayHoverPause: false,
      autoplayButton: false,
      autoplayButtonOutput: true,
      autoplayResetOnVisibility: true,
      animateIn: 'tns-fadeIn',
      animateOut: 'tns-fadeOut',
      animateNormal: 'tns-normal',
      animateDelay: false,
      loop: true,
      rewind: false,
      autoHeight: false,
      responsive: false,
      lazyload: false,
      lazyloadSelector: '.tns-lazy-img',
      touch: true,
      mouseDrag: false,
      swipeAngle: 15,
      nested: false,
      preventActionWhenRunning: false,
      preventScrollOnTouch: false,
      freezable: true,
      onInit: false,
      useLocalStorage: true,
      textDirection: 'ltr',
      nonce: false
    }, options || {});

    var doc = document,
        win = window,
        KEYS = {
          ENTER: 13,
          SPACE: 32,
          LEFT: 37,
          RIGHT: 39
        },
        tnsStorage = {},
        localStorageAccess = options.useLocalStorage;

    if (localStorageAccess) {
      // check browser version and local storage access
      var browserInfo = navigator.userAgent;
      var uid = new Date;

      try {
        tnsStorage = win.localStorage;
        if (tnsStorage) {
          tnsStorage.setItem(uid, uid);
          localStorageAccess = tnsStorage.getItem(uid) == uid;
          tnsStorage.removeItem(uid);
        } else {
          localStorageAccess = false;
        }
        if (!localStorageAccess) { tnsStorage = {}; }
      } catch(e) {
        localStorageAccess = false;
      }

      if (localStorageAccess) {
        // remove storage when browser version changes
        if (tnsStorage['tnsApp'] && tnsStorage['tnsApp'] !== browserInfo) {
          ['tC', 'tPL', 'tMQ', 'tTf', 't3D', 'tTDu', 'tTDe', 'tADu', 'tADe', 'tTE', 'tAE'].forEach(function(item) { tnsStorage.removeItem(item); });
        }
        // update browserInfo
        localStorage['tnsApp'] = browserInfo;
      }
    }

    var CALC = tnsStorage['tC'] ? checkStorageValue(tnsStorage['tC']) : setLocalStorage(tnsStorage, 'tC', calc(), localStorageAccess),
        PERCENTAGELAYOUT = tnsStorage['tPL'] ? checkStorageValue(tnsStorage['tPL']) : setLocalStorage(tnsStorage, 'tPL', percentageLayout(), localStorageAccess),
        CSSMQ = tnsStorage['tMQ'] ? checkStorageValue(tnsStorage['tMQ']) : setLocalStorage(tnsStorage, 'tMQ', mediaquerySupport(), localStorageAccess),
        TRANSFORM = tnsStorage['tTf'] ? checkStorageValue(tnsStorage['tTf']) : setLocalStorage(tnsStorage, 'tTf', whichProperty('transform'), localStorageAccess),
        HAS3DTRANSFORMS = tnsStorage['t3D'] ? checkStorageValue(tnsStorage['t3D']) : setLocalStorage(tnsStorage, 't3D', has3DTransforms(TRANSFORM), localStorageAccess),
        TRANSITIONDURATION = tnsStorage['tTDu'] ? checkStorageValue(tnsStorage['tTDu']) : setLocalStorage(tnsStorage, 'tTDu', whichProperty('transitionDuration'), localStorageAccess),
        TRANSITIONDELAY = tnsStorage['tTDe'] ? checkStorageValue(tnsStorage['tTDe']) : setLocalStorage(tnsStorage, 'tTDe', whichProperty('transitionDelay'), localStorageAccess),
        ANIMATIONDURATION = tnsStorage['tADu'] ? checkStorageValue(tnsStorage['tADu']) : setLocalStorage(tnsStorage, 'tADu', whichProperty('animationDuration'), localStorageAccess),
        ANIMATIONDELAY = tnsStorage['tADe'] ? checkStorageValue(tnsStorage['tADe']) : setLocalStorage(tnsStorage, 'tADe', whichProperty('animationDelay'), localStorageAccess),
        TRANSITIONEND = tnsStorage['tTE'] ? checkStorageValue(tnsStorage['tTE']) : setLocalStorage(tnsStorage, 'tTE', getEndProperty(TRANSITIONDURATION, 'Transition'), localStorageAccess),
        ANIMATIONEND = tnsStorage['tAE'] ? checkStorageValue(tnsStorage['tAE']) : setLocalStorage(tnsStorage, 'tAE', getEndProperty(ANIMATIONDURATION, 'Animation'), localStorageAccess);

    // get element nodes from selectors
    var supportConsoleWarn = win.console && typeof win.console.warn === "function",
        tnsList = ['container', 'controlsContainer', 'prevButton', 'nextButton', 'navContainer', 'autoplayButton'],
        optionsElements = {};

    tnsList.forEach(function(item) {
      if (typeof options[item] === 'string') {
        var str = options[item],
            el = doc.querySelector(str);
        optionsElements[item] = str;

        if (el && el.nodeName) {
          options[item] = el;
        } else {
          if (supportConsoleWarn) { console.warn('Can\'t find', options[item]); }
          return;
        }
      }
    });

    // make sure at least 1 slide
    if (options.container.children.length < 1) {
      if (supportConsoleWarn) { console.warn('No slides found in', options.container); }
      return;
     }

    // update options
    var responsive = options.responsive,
        nested = options.nested,
        carousel = options.mode === 'carousel' ? true : false;

    if (responsive) {
      // apply responsive[0] to options and remove it
      if (0 in responsive) {
        options = extend(options, responsive[0]);
        delete responsive[0];
      }

      var responsiveTem = {};
      for (var key in responsive) {
        var val = responsive[key];
        // update responsive
        // from: 300: 2
        // to:
        //   300: {
        //     items: 2
        //   }
        val = typeof val === 'number' ? {items: val} : val;
        responsiveTem[key] = val;
      }
      responsive = responsiveTem;
      responsiveTem = null;
    }

    // update options
    function updateOptions (obj) {
      for (var key in obj) {
        if (!carousel) {
          if (key === 'slideBy') { obj[key] = 'page'; }
          if (key === 'edgePadding') { obj[key] = false; }
          if (key === 'autoHeight') { obj[key] = false; }
        }

        // update responsive options
        if (key === 'responsive') { updateOptions(obj[key]); }
      }
    }
    if (!carousel) { updateOptions(options); }


    // === define and set variables ===
    if (!carousel) {
      options.axis = 'horizontal';
      options.slideBy = 'page';
      options.edgePadding = false;

      var animateIn = options.animateIn,
          animateOut = options.animateOut,
          animateDelay = options.animateDelay,
          animateNormal = options.animateNormal;
    }

    var horizontal = options.axis === 'horizontal' ? true : false,
        outerWrapper = doc.createElement('div'),
        innerWrapper = doc.createElement('div'),
        middleWrapper,
        container = options.container,
        containerParent = container.parentNode,
        containerHTML = container.outerHTML,
        slideItems = container.children,
        slideCount = slideItems.length,
        breakpointZone,
        windowWidth = getWindowWidth(),
        isOn = false;
    if (responsive) { setBreakpointZone(); }
    if (carousel) { container.className += ' tns-vpfix'; }

    // fixedWidth: viewport > rightBoundary > indexMax
    var autoWidth = options.autoWidth,
        fixedWidth = getOption('fixedWidth'),
        edgePadding = getOption('edgePadding'),
        gutter = getOption('gutter'),
        viewport = getViewportWidth(),
        center = getOption('center'),
        items = !autoWidth ? Math.floor(getOption('items')) : 1,
        slideBy = getOption('slideBy'),
        viewportMax = options.viewportMax || options.fixedWidthViewportWidth,
        arrowKeys = getOption('arrowKeys'),
        speed = getOption('speed'),
        rewind = options.rewind,
        loop = rewind ? false : options.loop,
        autoHeight = getOption('autoHeight'),
        controls = getOption('controls'),
        controlsText = getOption('controlsText'),
        textDirection = getOption('textDirection'),
        nav = getOption('nav'),
        touch = getOption('touch'),
        mouseDrag = getOption('mouseDrag'),
        autoplay = getOption('autoplay'),
        autoplayTimeout = getOption('autoplayTimeout'),
        autoplayText = getOption('autoplayText'),
        autoplayHoverPause = getOption('autoplayHoverPause'),
        autoplayResetOnVisibility = getOption('autoplayResetOnVisibility'),
        sheet = createStyleSheet(null, getOption('nonce')),
        lazyload = options.lazyload,
        lazyloadSelector = options.lazyloadSelector,
        slidePositions, // collection of slide positions
        slideItemsOut = [],
        cloneCount = loop ? getCloneCountForLoop() : 0,
        slideCountNew = !carousel ? slideCount + cloneCount : slideCount + cloneCount * 2,
        hasRightDeadZone = (fixedWidth || autoWidth) && !loop ? true : false,
        rightBoundary = fixedWidth ? getRightBoundary() : null,
        updateIndexBeforeTransform = (!carousel || !loop) ? true : false,
        // transform
        transformAttr = horizontal ? 'left' : 'top',
        transformPrefix = '',
        transformPostfix = '',
        // index
        getIndexMax = (function () {
          if (fixedWidth) {
            return function() { return center && !loop ? slideCount - 1 : Math.ceil(- rightBoundary / (fixedWidth + gutter)); };
          } else if (autoWidth) {
            return function() {
              for (var i = 0; i < slideCountNew; i++) {
                if (slidePositions[i] >= - rightBoundary) { return i; }
              }
            };
          } else {
            return function() {
              if (center && carousel && !loop) {
                return slideCount - 1;
              } else {
                return loop || carousel ? Math.max(0, slideCountNew - Math.ceil(items)) : slideCountNew - 1;
              }
            };
          }
        })(),
        index = getStartIndex(getOption('startIndex')),
        indexCached = index;
        getCurrentSlide();
        var indexMin = 0,
        indexMax = !autoWidth ? getIndexMax() : null,
        preventActionWhenRunning = options.preventActionWhenRunning,
        swipeAngle = options.swipeAngle,
        moveDirectionExpected = swipeAngle ? '?' : true,
        running = false,
        onInit = options.onInit,
        events = new Events(),
        // id, class
        newContainerClasses = ' tns-slider tns-' + options.mode,
        slideId = container.id || getSlideId(),
        disable = getOption('disable'),
        disabled = false,
        freezable = options.freezable,
        freeze = freezable && !autoWidth ? getFreeze() : false,
        frozen = false,
        controlsEvents = {
          'click': onControlsClick,
          'keydown': onControlsKeydown
        },
        navEvents = {
          'click': onNavClick,
          'keydown': onNavKeydown
        },
        hoverEvents = {
          'mouseover': mouseoverPause,
          'mouseout': mouseoutRestart
        },
        visibilityEvent = {'visibilitychange': onVisibilityChange},
        docmentKeydownEvent = {'keydown': onDocumentKeydown},
        touchEvents = {
          'touchstart': onPanStart,
          'touchmove': onPanMove,
          'touchend': onPanEnd,
          'touchcancel': onPanEnd
        }, dragEvents = {
          'mousedown': onPanStart,
          'mousemove': onPanMove,
          'mouseup': onPanEnd,
          'mouseleave': onPanEnd
        },
        hasControls = hasOption('controls'),
        hasNav = hasOption('nav'),
        navAsThumbnails = autoWidth ? true : options.navAsThumbnails,
        hasAutoplay = hasOption('autoplay'),
        hasTouch = hasOption('touch'),
        hasMouseDrag = hasOption('mouseDrag'),
        slideActiveClass = 'tns-slide-active',
        slideClonedClass = 'tns-slide-cloned',
        imgCompleteClass = 'tns-complete',
        imgEvents = {
          'load': onImgLoaded,
          'error': onImgFailed
        },
        imgsComplete,
        liveregionCurrent,
        preventScroll = options.preventScrollOnTouch === 'force' ? true : false;

    // controls
    if (hasControls) {
      var controlsContainer = options.controlsContainer,
          controlsContainerHTML = options.controlsContainer ? options.controlsContainer.outerHTML : '',
          prevButton = options.prevButton,
          nextButton = options.nextButton,
          prevButtonHTML = options.prevButton ? options.prevButton.outerHTML : '',
          nextButtonHTML = options.nextButton ? options.nextButton.outerHTML : '',
          prevIsButton,
          nextIsButton;
    }

    // nav
    if (hasNav) {
      var navContainer = options.navContainer,
          navContainerHTML = options.navContainer ? options.navContainer.outerHTML : '',
          navItems,
          pages = autoWidth ? slideCount : getPages(),
          pagesCached = 0,
          navClicked = -1,
          navCurrentIndex = getCurrentNavIndex(),
          navCurrentIndexCached = navCurrentIndex,
          navActiveClass = 'tns-nav-active',
          navStr = 'Carousel Page ',
          navStrCurrent = ' (Current Slide)';
    }

    // autoplay
    if (hasAutoplay) {
      var autoplayDirection = options.autoplayDirection === 'forward' ? 1 : -1,
          autoplayButton = options.autoplayButton,
          autoplayButtonHTML = options.autoplayButton ? options.autoplayButton.outerHTML : '',
          autoplayHtmlStrings = ['<span class=\'tns-visually-hidden\'>', ' animation</span>'],
          autoplayTimer,
          animating,
          autoplayHoverPaused,
          autoplayUserPaused,
          autoplayVisibilityPaused;
    }

    if (hasTouch || hasMouseDrag) {
      var initPosition = {},
          lastPosition = {},
          translateInit,
          panStart = false,
          rafIndex,
          getDist = horizontal ?
            function(a, b) { return a.x - b.x; } :
            function(a, b) { return a.y - b.y; };
    }

    // disable slider when slidecount <= items
    if (!autoWidth) { resetVariblesWhenDisable(disable || freeze); }

    if (TRANSFORM) {
      transformAttr = TRANSFORM;
      transformPrefix = 'translate';

      if (HAS3DTRANSFORMS) {
        transformPrefix += horizontal ? '3d(' : '3d(0px, ';
        transformPostfix = horizontal ? ', 0px, 0px)' : ', 0px)';
      } else {
        transformPrefix += horizontal ? 'X(' : 'Y(';
        transformPostfix = ')';
      }

    }

    if (carousel) { container.className = container.className.replace('tns-vpfix', ''); }
    initStructure();
    initSheet();
    initSliderTransform();

    // === COMMON FUNCTIONS === //
    function resetVariblesWhenDisable (condition) {
      if (condition) {
        controls = nav = touch = mouseDrag = arrowKeys = autoplay = autoplayHoverPause = autoplayResetOnVisibility = false;
      }
    }

    function getCurrentSlide () {
      var tem = carousel ? index - cloneCount : index;
      while (tem < 0) { tem += slideCount; }
      return tem%slideCount + 1;
    }

    function getStartIndex (ind) {
      ind = ind ? Math.max(0, Math.min(loop ? slideCount - 1 : slideCount - items, ind)) : 0;
      return carousel ? ind + cloneCount : ind;
    }

    function getAbsIndex (i) {
      if (i == null) { i = index; }

      if (carousel) { i -= cloneCount; }
      while (i < 0) { i += slideCount; }

      return Math.floor(i%slideCount);
    }

    function getCurrentNavIndex () {
      var absIndex = getAbsIndex(),
          result;

      result = navAsThumbnails ? absIndex :
        fixedWidth || autoWidth ? Math.ceil((absIndex + 1) * pages / slideCount - 1) :
            Math.floor(absIndex / items);

      // set active nav to the last one when reaches the right edge
      if (!loop && carousel && index === indexMax) { result = pages - 1; }

      return result;
    }

    function getItemsMax () {
      // fixedWidth or autoWidth while viewportMax is not available
      if (autoWidth || (fixedWidth && !viewportMax)) {
        return slideCount - 1;
      // most cases
      } else {
        var str = fixedWidth ? 'fixedWidth' : 'items',
            arr = [];

        if (fixedWidth || options[str] < slideCount) { arr.push(options[str]); }

        if (responsive) {
          for (var bp in responsive) {
            var tem = responsive[bp][str];
            if (tem && (fixedWidth || tem < slideCount)) { arr.push(tem); }
          }
        }

        if (!arr.length) { arr.push(0); }

        return Math.ceil(fixedWidth ? viewportMax / Math.min.apply(null, arr) : Math.max.apply(null, arr));
      }
    }

    function getCloneCountForLoop () {
      var itemsMax = getItemsMax(),
          result = carousel ? Math.ceil((itemsMax * 5 - slideCount)/2) : (itemsMax * 4 - slideCount);
      result = Math.max(itemsMax, result);

      return hasOption('edgePadding') ? result + 1 : result;
    }

    function getWindowWidth () {
      return win.innerWidth || doc.documentElement.clientWidth || doc.body.clientWidth;
    }

    function getInsertPosition (pos) {
      return pos === 'top' ? 'afterbegin' : 'beforeend';
    }

    function getClientWidth (el) {
      if (el == null) { return; }
      var div = doc.createElement('div'), rect, width;
      el.appendChild(div);
      rect = div.getBoundingClientRect();
      width = rect.right - rect.left;
      div.remove();
      return width || getClientWidth(el.parentNode);
    }

    function getViewportWidth () {
      var gap = edgePadding ? edgePadding * 2 - gutter : 0;
      return getClientWidth(containerParent) - gap;
    }

    function hasOption (item) {
      if (options[item]) {
        return true;
      } else {
        if (responsive) {
          for (var bp in responsive) {
            if (responsive[bp][item]) { return true; }
          }
        }
        return false;
      }
    }

    // get option:
    // fixed width: viewport, fixedWidth, gutter => items
    // others: window width => all variables
    // all: items => slideBy
    function getOption (item, ww) {
      if (ww == null) { ww = windowWidth; }

      if (item === 'items' && fixedWidth) {
        return Math.floor((viewport + gutter) / (fixedWidth + gutter)) || 1;

      } else {
        var result = options[item];

        if (responsive) {
          for (var bp in responsive) {
            // bp: convert string to number
            if (ww >= parseInt(bp)) {
              if (item in responsive[bp]) { result = responsive[bp][item]; }
            }
          }
        }

        if (item === 'slideBy' && result === 'page') { result = getOption('items'); }
        if (!carousel && (item === 'slideBy' || item === 'items')) { result = Math.floor(result); }

        return result;
      }
    }

    function getSlideMarginLeft (i) {
      return CALC ?
        CALC + '(' + i * 100 + '% / ' + slideCountNew + ')' :
        i * 100 / slideCountNew + '%';
    }

    function getInnerWrapperStyles (edgePaddingTem, gutterTem, fixedWidthTem, speedTem, autoHeightBP) {
      var str = '';

      if (edgePaddingTem !== undefined) {
        var gap = edgePaddingTem;
        if (gutterTem) { gap -= gutterTem; }
        str = horizontal ?
          'margin: 0 ' + gap + 'px 0 ' + edgePaddingTem + 'px;' :
          'margin: ' + edgePaddingTem + 'px 0 ' + gap + 'px 0;';
      } else if (gutterTem && !fixedWidthTem) {
        var gutterTemUnit = '-' + gutterTem + 'px',
            dir = horizontal ? gutterTemUnit + ' 0 0' : '0 ' + gutterTemUnit + ' 0';
        str = 'margin: 0 ' + dir + ';';
      }

      if (!carousel && autoHeightBP && TRANSITIONDURATION && speedTem) { str += getTransitionDurationStyle(speedTem); }
      return str;
    }

    function getContainerWidth (fixedWidthTem, gutterTem, itemsTem) {
      if (fixedWidthTem) {
        return (fixedWidthTem + gutterTem) * slideCountNew + 'px';
      } else {
        return CALC ?
          CALC + '(' + slideCountNew * 100 + '% / ' + itemsTem + ')' :
          slideCountNew * 100 / itemsTem + '%';
      }
    }

    function getSlideWidthStyle (fixedWidthTem, gutterTem, itemsTem) {
      var width;

      if (fixedWidthTem) {
        width = (fixedWidthTem + gutterTem) + 'px';
      } else {
        if (!carousel) { itemsTem = Math.floor(itemsTem); }
        var dividend = carousel ? slideCountNew : itemsTem;
        width = CALC ?
          CALC + '(100% / ' + dividend + ')' :
          100 / dividend + '%';
      }

      width = 'width:' + width;

      // inner slider: overwrite outer slider styles
      return nested !== 'inner' ? width + ';' : width + ' !important;';
    }

    function getSlideGutterStyle (gutterTem) {
      var str = '';

      // gutter maybe interger || 0
      // so can't use 'if (gutter)'
      if (gutterTem !== false) {
        var prop = horizontal ? 'padding-' : 'margin-',
            dir = horizontal ? 'right' : 'bottom';
        str = prop +  dir + ': ' + gutterTem + 'px;';
      }

      return str;
    }

    function getCSSPrefix (name, num) {
      var prefix = name.substring(0, name.length - num).toLowerCase();
      if (prefix) { prefix = '-' + prefix + '-'; }

      return prefix;
    }

    function getTransitionDurationStyle (speed) {
      return getCSSPrefix(TRANSITIONDURATION, 18) + 'transition-duration:' + speed / 1000 + 's;';
    }

    function getAnimationDurationStyle (speed) {
      return getCSSPrefix(ANIMATIONDURATION, 17) + 'animation-duration:' + speed / 1000 + 's;';
    }

    function initStructure () {
      var classOuter = 'tns-outer',
          classInner = 'tns-inner';
          hasOption('gutter');

      outerWrapper.className = classOuter;
      innerWrapper.className = classInner;
      outerWrapper.id = slideId + '-ow';
      innerWrapper.id = slideId + '-iw';

      // set container properties
      if (container.id === '') { container.id = slideId; }
      newContainerClasses += PERCENTAGELAYOUT || autoWidth ? ' tns-subpixel' : ' tns-no-subpixel';
      newContainerClasses += CALC ? ' tns-calc' : ' tns-no-calc';
      if (autoWidth) { newContainerClasses += ' tns-autowidth'; }
      newContainerClasses += ' tns-' + options.axis;
      container.className += newContainerClasses;

      // add constrain layer for carousel
      if (carousel) {
        middleWrapper = doc.createElement('div');
        middleWrapper.id = slideId + '-mw';
        middleWrapper.className = 'tns-ovh';

        outerWrapper.appendChild(middleWrapper);
        middleWrapper.appendChild(innerWrapper);
      } else {
        outerWrapper.appendChild(innerWrapper);
      }

      if (autoHeight) {
        var wp = middleWrapper ? middleWrapper : innerWrapper;
        wp.className += ' tns-ah';
      }

      containerParent.insertBefore(outerWrapper, container);
      innerWrapper.appendChild(container);

      // add id, class, aria attributes
      // before clone slides
      forEach(slideItems, function(item, i) {
        addClass(item, 'tns-item');
        if (!item.id) { item.id = slideId + '-item' + i; }
        if (!carousel && animateNormal) { addClass(item, animateNormal); }
        setAttrs(item, {
          'aria-hidden': 'true',
          'tabindex': '-1'
        });
      });

      // ## clone slides
      // carousel: n + slides + n
      // gallery:      slides + n
      if (cloneCount) {
        var fragmentBefore = doc.createDocumentFragment(),
            fragmentAfter = doc.createDocumentFragment();

        for (var j = cloneCount; j--;) {
          var num = j%slideCount,
              cloneFirst = slideItems[num].cloneNode(true);
          addClass(cloneFirst, slideClonedClass);
          removeAttrs(cloneFirst, 'id');
          fragmentAfter.insertBefore(cloneFirst, fragmentAfter.firstChild);

          if (carousel) {
            var cloneLast = slideItems[slideCount - 1 - num].cloneNode(true);
            addClass(cloneLast, slideClonedClass);
            removeAttrs(cloneLast, 'id');
            fragmentBefore.appendChild(cloneLast);
          }
        }

        container.insertBefore(fragmentBefore, container.firstChild);
        container.appendChild(fragmentAfter);
        slideItems = container.children;
      }

    }

    function initSliderTransform () {
      // ## images loaded/failed
      if (hasOption('autoHeight') || autoWidth || !horizontal) {
        var imgs = container.querySelectorAll('img');

        // add img load event listener
        forEach(imgs, function(img) {
          var src = img.src;

          if (!lazyload) {
            // not data img
            if (src && src.indexOf('data:image') < 0) {
              img.src = '';
              addEvents(img, imgEvents);
              addClass(img, 'loading');

              img.src = src;
            // data img
            } else {
              imgLoaded(img);
            }
          }
        });

        // set imgsComplete
        raf(function(){ imgsLoadedCheck(arrayFromNodeList(imgs), function() { imgsComplete = true; }); });

        // reset imgs for auto height: check visible imgs only
        if (hasOption('autoHeight')) { imgs = getImageArray(index, Math.min(index + items - 1, slideCountNew - 1)); }

        lazyload ? initSliderTransformStyleCheck() : raf(function(){ imgsLoadedCheck(arrayFromNodeList(imgs), initSliderTransformStyleCheck); });

      } else {
        // set container transform property
        if (carousel) { doContainerTransformSilent(); }

        // update slider tools and events
        initTools();
        initEvents();
      }
    }

    function initSliderTransformStyleCheck () {
      if (autoWidth && slideCount > 1) {
        // check styles application
        var num = loop ? index : slideCount - 1;

        (function stylesApplicationCheck() {
          var left = slideItems[num].getBoundingClientRect().left;
          var right = slideItems[num - 1].getBoundingClientRect().right;

          (Math.abs(left - right) <= 1) ?
            initSliderTransformCore() :
            setTimeout(function(){ stylesApplicationCheck(); }, 16);
        })();

      } else {
        initSliderTransformCore();
      }
    }


    function initSliderTransformCore () {
      // run Fn()s which are rely on image loading
      if (!horizontal || autoWidth) {
        setSlidePositions();

        if (autoWidth) {
          rightBoundary = getRightBoundary();
          if (freezable) { freeze = getFreeze(); }
          indexMax = getIndexMax(); // <= slidePositions, rightBoundary <=
          resetVariblesWhenDisable(disable || freeze);
        } else {
          updateContentWrapperHeight();
        }
      }

      // set container transform property
      if (carousel) { doContainerTransformSilent(); }

      // update slider tools and events
      initTools();
      initEvents();
    }

    function initSheet () {
      // gallery:
      // set animation classes and left value for gallery slider
      if (!carousel) {
        for (var i = index, l = index + Math.min(slideCount, items); i < l; i++) {
          var item = slideItems[i];
          item.style.left = (i - index) * 100 / items + '%';
          addClass(item, animateIn);
          removeClass(item, animateNormal);
        }
      }

      // #### LAYOUT

      // ## INLINE-BLOCK VS FLOAT

      // ## PercentageLayout:
      // slides: inline-block
      // remove blank space between slides by set font-size: 0

      // ## Non PercentageLayout:
      // slides: float
      //         margin-right: -100%
      //         margin-left: ~

      // Resource: https://docs.google.com/spreadsheets/d/147up245wwTXeQYve3BRSAD4oVcvQmuGsFteJOeA5xNQ/edit?usp=sharing
      if (horizontal) {
        if (PERCENTAGELAYOUT || autoWidth) {
          addCSSRule(sheet, '#' + slideId + ' > .tns-item', 'font-size:' + win.getComputedStyle(slideItems[0]).fontSize + ';', getCssRulesLength(sheet));
          addCSSRule(sheet, '#' + slideId, 'font-size:0;', getCssRulesLength(sheet));
        } else if (carousel) {
          forEach(slideItems, function (slide, i) {
            slide.style.marginLeft = getSlideMarginLeft(i);
          });
        }
      }


      // ## BASIC STYLES
      if (CSSMQ) {
        // middle wrapper style
        if (TRANSITIONDURATION) {
          var str = middleWrapper && options.autoHeight ? getTransitionDurationStyle(options.speed) : '';
          addCSSRule(sheet, '#' + slideId + '-mw', str, getCssRulesLength(sheet));
        }

        // inner wrapper styles
        str = getInnerWrapperStyles(options.edgePadding, options.gutter, options.fixedWidth, options.speed, options.autoHeight);
        addCSSRule(sheet, '#' + slideId + '-iw', str, getCssRulesLength(sheet));

        // container styles
        if (carousel) {
          str = horizontal && !autoWidth ? 'width:' + getContainerWidth(options.fixedWidth, options.gutter, options.items) + ';' : '';
          if (TRANSITIONDURATION) { str += getTransitionDurationStyle(speed); }
          addCSSRule(sheet, '#' + slideId, str, getCssRulesLength(sheet));
        }

        // slide styles
        str = horizontal && !autoWidth ? getSlideWidthStyle(options.fixedWidth, options.gutter, options.items) : '';
        if (options.gutter) { str += getSlideGutterStyle(options.gutter); }
        // set gallery items transition-duration
        if (!carousel) {
          if (TRANSITIONDURATION) { str += getTransitionDurationStyle(speed); }
          if (ANIMATIONDURATION) { str += getAnimationDurationStyle(speed); }
        }
        if (str) { addCSSRule(sheet, '#' + slideId + ' > .tns-item', str, getCssRulesLength(sheet)); }

      // non CSS mediaqueries: IE8
      // ## update inner wrapper, container, slides if needed
      // set inline styles for inner wrapper & container
      // insert stylesheet (one line) for slides only (since slides are many)
      } else {
        // middle wrapper styles
        update_carousel_transition_duration();

        // inner wrapper styles
        innerWrapper.style.cssText = getInnerWrapperStyles(edgePadding, gutter, fixedWidth, autoHeight);

        // container styles
        if (carousel && horizontal && !autoWidth) {
          container.style.width = getContainerWidth(fixedWidth, gutter, items);
        }

        // slide styles
        var str = horizontal && !autoWidth ? getSlideWidthStyle(fixedWidth, gutter, items) : '';
        if (gutter) { str += getSlideGutterStyle(gutter); }

        // append to the last line
        if (str) { addCSSRule(sheet, '#' + slideId + ' > .tns-item', str, getCssRulesLength(sheet)); }
      }

      // ## MEDIAQUERIES
      if (responsive && CSSMQ) {
        for (var bp in responsive) {
          // bp: convert string to number
          bp = parseInt(bp);

          var opts = responsive[bp],
              str = '',
              middleWrapperStr = '',
              innerWrapperStr = '',
              containerStr = '',
              slideStr = '',
              itemsBP = !autoWidth ? getOption('items', bp) : null,
              fixedWidthBP = getOption('fixedWidth', bp),
              speedBP = getOption('speed', bp),
              edgePaddingBP = getOption('edgePadding', bp),
              autoHeightBP = getOption('autoHeight', bp),
              gutterBP = getOption('gutter', bp);

          // middle wrapper string
          if (TRANSITIONDURATION && middleWrapper && getOption('autoHeight', bp) && 'speed' in opts) {
            middleWrapperStr = '#' + slideId + '-mw{' + getTransitionDurationStyle(speedBP) + '}';
          }

          // inner wrapper string
          if ('edgePadding' in opts || 'gutter' in opts) {
            innerWrapperStr = '#' + slideId + '-iw{' + getInnerWrapperStyles(edgePaddingBP, gutterBP, fixedWidthBP, speedBP, autoHeightBP) + '}';
          }

          // container string
          if (carousel && horizontal && !autoWidth && ('fixedWidth' in opts || 'items' in opts || (fixedWidth && 'gutter' in opts))) {
            containerStr = 'width:' + getContainerWidth(fixedWidthBP, gutterBP, itemsBP) + ';';
          }
          if (TRANSITIONDURATION && 'speed' in opts) {
            containerStr += getTransitionDurationStyle(speedBP);
          }
          if (containerStr) {
            containerStr = '#' + slideId + '{' + containerStr + '}';
          }

          // slide string
          if ('fixedWidth' in opts || (fixedWidth && 'gutter' in opts) || !carousel && 'items' in opts) {
            slideStr += getSlideWidthStyle(fixedWidthBP, gutterBP, itemsBP);
          }
          if ('gutter' in opts) {
            slideStr += getSlideGutterStyle(gutterBP);
          }
          // set gallery items transition-duration
          if (!carousel && 'speed' in opts) {
            if (TRANSITIONDURATION) { slideStr += getTransitionDurationStyle(speedBP); }
            if (ANIMATIONDURATION) { slideStr += getAnimationDurationStyle(speedBP); }
          }
          if (slideStr) { slideStr = '#' + slideId + ' > .tns-item{' + slideStr + '}'; }

          // add up
          str = middleWrapperStr + innerWrapperStr + containerStr + slideStr;

          if (str) {
            sheet.insertRule('@media (min-width: ' + bp / 16 + 'em) {' + str + '}', sheet.cssRules.length);
          }
        }
      }
    }

    function initTools () {
      // == slides ==
      updateSlideStatus();

      // == live region ==
      outerWrapper.insertAdjacentHTML('afterbegin', '<div class="tns-liveregion tns-visually-hidden" aria-live="polite" aria-atomic="true">slide <span class="current">' + getLiveRegionStr() + '</span>  of ' + slideCount + '</div>');
      liveregionCurrent = outerWrapper.querySelector('.tns-liveregion .current');

      // == autoplayInit ==
      if (hasAutoplay) {
        var txt = autoplay ? 'stop' : 'start';
        if (autoplayButton) {
          setAttrs(autoplayButton, {'data-action': txt});
        } else if (options.autoplayButtonOutput) {
          outerWrapper.insertAdjacentHTML(getInsertPosition(options.autoplayPosition), '<button type="button" data-action="' + txt + '">' + autoplayHtmlStrings[0] + txt + autoplayHtmlStrings[1] + autoplayText[0] + '</button>');
          autoplayButton = outerWrapper.querySelector('[data-action]');
        }

        // add event
        if (autoplayButton) {
          addEvents(autoplayButton, {'click': toggleAutoplay});
        }

        if (autoplay) {
          startAutoplay();
          if (autoplayHoverPause) { addEvents(container, hoverEvents); }
          if (autoplayResetOnVisibility) { addEvents(container, visibilityEvent); }
        }
      }

      // == navInit ==
      if (hasNav) {
        // customized nav
        // will not hide the navs in case they're thumbnails
        if (navContainer) {
          setAttrs(navContainer, {'aria-label': 'Carousel Pagination'});
          navItems = navContainer.children;
          forEach(navItems, function(item, i) {
            setAttrs(item, {
              'data-nav': i,
              'tabindex': '-1',
              'aria-label': navStr + (i + 1),
              'aria-controls': slideId,
            });
          });

        // generated nav
        } else {
          var navHtml = '',
              hiddenStr = navAsThumbnails ? '' : 'style="display:none"';
          for (var i = 0; i < slideCount; i++) {
            // hide nav items by default
            navHtml += '<button type="button" data-nav="' + i +'" tabindex="-1" aria-controls="' + slideId + '" ' + hiddenStr + ' aria-label="' + navStr + (i + 1) +'"></button>';
          }
          navHtml = '<div class="tns-nav" aria-label="Carousel Pagination">' + navHtml + '</div>';
          outerWrapper.insertAdjacentHTML(getInsertPosition(options.navPosition), navHtml);

          navContainer = outerWrapper.querySelector('.tns-nav');
          navItems = navContainer.children;
        }

        updateNavVisibility();

        // add transition
        if (TRANSITIONDURATION) {
          var prefix = TRANSITIONDURATION.substring(0, TRANSITIONDURATION.length - 18).toLowerCase(),
              str = 'transition: all ' + speed / 1000 + 's';

          if (prefix) {
            str = '-' + prefix + '-' + str;
          }

          addCSSRule(sheet, '[aria-controls^=' + slideId + '-item]', str, getCssRulesLength(sheet));
        }

        setAttrs(navItems[navCurrentIndex], {'aria-label': navStr + (navCurrentIndex + 1) + navStrCurrent});
        removeAttrs(navItems[navCurrentIndex], 'tabindex');
        addClass(navItems[navCurrentIndex], navActiveClass);

        // add events
        addEvents(navContainer, navEvents);
      }



      // == controlsInit ==
      if (hasControls) {
        if (!controlsContainer && (!prevButton || !nextButton)) {
          outerWrapper.insertAdjacentHTML(getInsertPosition(options.controlsPosition), '<div class="tns-controls" aria-label="Carousel Navigation" tabindex="0"><button type="button" data-controls="prev" tabindex="-1" aria-controls="' + slideId +'">' + controlsText[0] + '</button><button type="button" data-controls="next" tabindex="-1" aria-controls="' + slideId +'">' + controlsText[1] + '</button></div>');

          controlsContainer = outerWrapper.querySelector('.tns-controls');
        }

        if (!prevButton || !nextButton) {
          prevButton = controlsContainer.children[0];
          nextButton = controlsContainer.children[1];
        }

        if (options.controlsContainer) {
          setAttrs(controlsContainer, {
            'aria-label': 'Carousel Navigation',
            'tabindex': '0'
          });
        }

        if (options.controlsContainer || (options.prevButton && options.nextButton)) {
          setAttrs([prevButton, nextButton], {
            'aria-controls': slideId,
            'tabindex': '-1',
          });
        }

        if (options.controlsContainer || (options.prevButton && options.nextButton)) {
          setAttrs(prevButton, {'data-controls' : 'prev'});
          setAttrs(nextButton, {'data-controls' : 'next'});
        }

        prevIsButton = isButton(prevButton);
        nextIsButton = isButton(nextButton);

        updateControlsStatus();

        // add events
        if (controlsContainer) {
          addEvents(controlsContainer, controlsEvents);
        } else {
          addEvents(prevButton, controlsEvents);
          addEvents(nextButton, controlsEvents);
        }
      }

      // hide tools if needed
      disableUI();
    }

    function initEvents () {
      // add events
      if (carousel && TRANSITIONEND) {
        var eve = {};
        eve[TRANSITIONEND] = onTransitionEnd;
        addEvents(container, eve);
      }

      if (touch) { addEvents(container, touchEvents, options.preventScrollOnTouch); }
      if (mouseDrag) { addEvents(container, dragEvents); }
      if (arrowKeys) { addEvents(doc, docmentKeydownEvent); }

      if (nested === 'inner') {
        events.on('outerResized', function () {
          resizeTasks();
          events.emit('innerLoaded', info());
        });
      } else if (responsive || fixedWidth || autoWidth || autoHeight || !horizontal) {
        addEvents(win, {'resize': onResize});
      }

      if (autoHeight) {
        if (nested === 'outer') {
          events.on('innerLoaded', doAutoHeight);
        } else if (!disable) { doAutoHeight(); }
      }

      doLazyLoad();
      if (disable) { disableSlider(); } else if (freeze) { freezeSlider(); }

      events.on('indexChanged', additionalUpdates);
      if (nested === 'inner') { events.emit('innerLoaded', info()); }
      if (typeof onInit === 'function') { onInit(info()); }
      isOn = true;
    }

    function destroy () {
      // sheet
      sheet.disabled = true;
      if (sheet.ownerNode) { sheet.ownerNode.remove(); }

      // remove win event listeners
      removeEvents(win, {'resize': onResize});

      // arrowKeys, controls, nav
      if (arrowKeys) { removeEvents(doc, docmentKeydownEvent); }
      if (controlsContainer) { removeEvents(controlsContainer, controlsEvents); }
      if (navContainer) { removeEvents(navContainer, navEvents); }

      // autoplay
      removeEvents(container, hoverEvents);
      removeEvents(container, visibilityEvent);
      if (autoplayButton) { removeEvents(autoplayButton, {'click': toggleAutoplay}); }
      if (autoplay) { clearInterval(autoplayTimer); }

      // container
      if (carousel && TRANSITIONEND) {
        var eve = {};
        eve[TRANSITIONEND] = onTransitionEnd;
        removeEvents(container, eve);
      }
      if (touch) { removeEvents(container, touchEvents); }
      if (mouseDrag) { removeEvents(container, dragEvents); }

      // cache Object values in options && reset HTML
      var htmlList = [containerHTML, controlsContainerHTML, prevButtonHTML, nextButtonHTML, navContainerHTML, autoplayButtonHTML];

      tnsList.forEach(function(item, i) {
        var el = item === 'container' ? outerWrapper : options[item];

        if (typeof el === 'object' && el) {
          var prevEl = el.previousElementSibling ? el.previousElementSibling : false,
              parentEl = el.parentNode;
          el.outerHTML = htmlList[i];
          options[item] = prevEl ? prevEl.nextElementSibling : parentEl.firstElementChild;
        }
      });


      // reset variables
      tnsList = animateIn = animateOut = animateDelay = animateNormal = horizontal = outerWrapper = innerWrapper = container = containerParent = containerHTML = slideItems = slideCount = breakpointZone = windowWidth = autoWidth = fixedWidth = edgePadding = gutter = viewport = items = slideBy = viewportMax = arrowKeys = speed = rewind = loop = autoHeight = sheet = lazyload = slidePositions = slideItemsOut = cloneCount = slideCountNew = hasRightDeadZone = rightBoundary = updateIndexBeforeTransform = transformAttr = transformPrefix = transformPostfix = getIndexMax = index = indexCached = indexMin = indexMax = swipeAngle = moveDirectionExpected = running = onInit = events = newContainerClasses = slideId = disable = disabled = freezable = freeze = frozen = controlsEvents = navEvents = hoverEvents = visibilityEvent = docmentKeydownEvent = touchEvents = dragEvents = hasControls = hasNav = navAsThumbnails = hasAutoplay = hasTouch = hasMouseDrag = slideActiveClass = imgCompleteClass = imgEvents = imgsComplete = controls = controlsText = controlsContainer = controlsContainerHTML = prevButton = nextButton = prevIsButton = nextIsButton = nav = navContainer = navContainerHTML = navItems = pages = pagesCached = navClicked = navCurrentIndex = navCurrentIndexCached = navActiveClass = navStr = navStrCurrent = autoplay = autoplayTimeout = autoplayDirection = autoplayText = autoplayHoverPause = autoplayButton = autoplayButtonHTML = autoplayResetOnVisibility = autoplayHtmlStrings = autoplayTimer = animating = autoplayHoverPaused = autoplayUserPaused = autoplayVisibilityPaused = initPosition = lastPosition = translateInit = panStart = rafIndex = getDist = touch = mouseDrag = null;
      // check variables
      // [animateIn, animateOut, animateDelay, animateNormal, horizontal, outerWrapper, innerWrapper, container, containerParent, containerHTML, slideItems, slideCount, breakpointZone, windowWidth, autoWidth, fixedWidth, edgePadding, gutter, viewport, items, slideBy, viewportMax, arrowKeys, speed, rewind, loop, autoHeight, sheet, lazyload, slidePositions, slideItemsOut, cloneCount, slideCountNew, hasRightDeadZone, rightBoundary, updateIndexBeforeTransform, transformAttr, transformPrefix, transformPostfix, getIndexMax, index, indexCached, indexMin, indexMax, resizeTimer, swipeAngle, moveDirectionExpected, running, onInit, events, newContainerClasses, slideId, disable, disabled, freezable, freeze, frozen, controlsEvents, navEvents, hoverEvents, visibilityEvent, docmentKeydownEvent, touchEvents, dragEvents, hasControls, hasNav, navAsThumbnails, hasAutoplay, hasTouch, hasMouseDrag, slideActiveClass, imgCompleteClass, imgEvents, imgsComplete, controls, controlsText, controlsContainer, controlsContainerHTML, prevButton, nextButton, prevIsButton, nextIsButton, nav, navContainer, navContainerHTML, navItems, pages, pagesCached, navClicked, navCurrentIndex, navCurrentIndexCached, navActiveClass, navStr, navStrCurrent, autoplay, autoplayTimeout, autoplayDirection, autoplayText, autoplayHoverPause, autoplayButton, autoplayButtonHTML, autoplayResetOnVisibility, autoplayHtmlStrings, autoplayTimer, animating, autoplayHoverPaused, autoplayUserPaused, autoplayVisibilityPaused, initPosition, lastPosition, translateInit, disX, disY, panStart, rafIndex, getDist, touch, mouseDrag ].forEach(function(item) { if (item !== null) { console.log(item); } });

      for (var a in this) {
        if (a !== 'rebuild') { this[a] = null; }
      }
      isOn = false;
    }

  // === ON RESIZE ===
    // responsive || fixedWidth || autoWidth || !horizontal
    function onResize (e) {
      raf(function(){ resizeTasks(getEvent(e)); });
    }

    function resizeTasks (e) {
      if (!isOn) { return; }
      if (nested === 'outer') { events.emit('outerResized', info(e)); }
      windowWidth = getWindowWidth();
      var bpChanged,
          breakpointZoneTem = breakpointZone,
          needContainerTransform = false;

      if (responsive) {
        setBreakpointZone();
        bpChanged = breakpointZoneTem !== breakpointZone;
        // if (hasRightDeadZone) { needContainerTransform = true; } // *?
        if (bpChanged) { events.emit('newBreakpointStart', info(e)); }
      }

      var indChanged,
          itemsChanged,
          itemsTem = items,
          disableTem = disable,
          freezeTem = freeze,
          arrowKeysTem = arrowKeys,
          controlsTem = controls,
          navTem = nav,
          touchTem = touch,
          mouseDragTem = mouseDrag,
          autoplayTem = autoplay,
          autoplayHoverPauseTem = autoplayHoverPause,
          autoplayResetOnVisibilityTem = autoplayResetOnVisibility,
          indexTem = index;

      if (bpChanged) {
        var fixedWidthTem = fixedWidth,
            autoHeightTem = autoHeight,
            controlsTextTem = controlsText,
            centerTem = center,
            autoplayTextTem = autoplayText;

        if (!CSSMQ) {
          var gutterTem = gutter,
              edgePaddingTem = edgePadding;
        }
      }

      // get option:
      // fixed width: viewport, fixedWidth, gutter => items
      // others: window width => all variables
      // all: items => slideBy
      arrowKeys = getOption('arrowKeys');
      controls = getOption('controls');
      nav = getOption('nav');
      touch = getOption('touch');
      center = getOption('center');
      mouseDrag = getOption('mouseDrag');
      autoplay = getOption('autoplay');
      autoplayHoverPause = getOption('autoplayHoverPause');
      autoplayResetOnVisibility = getOption('autoplayResetOnVisibility');

      if (bpChanged) {
        disable = getOption('disable');
        fixedWidth = getOption('fixedWidth');
        speed = getOption('speed');
        autoHeight = getOption('autoHeight');
        controlsText = getOption('controlsText');
        autoplayText = getOption('autoplayText');
        autoplayTimeout = getOption('autoplayTimeout');

        if (!CSSMQ) {
          edgePadding = getOption('edgePadding');
          gutter = getOption('gutter');
        }
      }
      // update options
      resetVariblesWhenDisable(disable);

      viewport = getViewportWidth(); // <= edgePadding, gutter
      if ((!horizontal || autoWidth) && !disable) {
        setSlidePositions();
        if (!horizontal) {
          updateContentWrapperHeight(); // <= setSlidePositions
          needContainerTransform = true;
        }
      }
      if (fixedWidth || autoWidth) {
        rightBoundary = getRightBoundary(); // autoWidth: <= viewport, slidePositions, gutter
                                            // fixedWidth: <= viewport, fixedWidth, gutter
        indexMax = getIndexMax(); // autoWidth: <= rightBoundary, slidePositions
                                  // fixedWidth: <= rightBoundary, fixedWidth, gutter
      }

      if (bpChanged || fixedWidth) {
        items = getOption('items');
        slideBy = getOption('slideBy');
        itemsChanged = items !== itemsTem;

        if (itemsChanged) {
          if (!fixedWidth && !autoWidth) { indexMax = getIndexMax(); } // <= items
          // check index before transform in case
          // slider reach the right edge then items become bigger
          updateIndex();
        }
      }

      if (bpChanged) {
        if (disable !== disableTem) {
          if (disable) {
            disableSlider();
          } else {
            enableSlider(); // <= slidePositions, rightBoundary, indexMax
          }
        }
      }

      if (freezable && (bpChanged || fixedWidth || autoWidth)) {
        freeze = getFreeze(); // <= autoWidth: slidePositions, gutter, viewport, rightBoundary
                              // <= fixedWidth: fixedWidth, gutter, rightBoundary
                              // <= others: items

        if (freeze !== freezeTem) {
          if (freeze) {
            doContainerTransform(getContainerTransformValue(getStartIndex(0)));
            freezeSlider();
          } else {
            unfreezeSlider();
            needContainerTransform = true;
          }
        }
      }

      resetVariblesWhenDisable(disable || freeze); // controls, nav, touch, mouseDrag, arrowKeys, autoplay, autoplayHoverPause, autoplayResetOnVisibility
      if (!autoplay) { autoplayHoverPause = autoplayResetOnVisibility = false; }

      if (arrowKeys !== arrowKeysTem) {
        arrowKeys ?
          addEvents(doc, docmentKeydownEvent) :
          removeEvents(doc, docmentKeydownEvent);
      }
      if (controls !== controlsTem) {
        if (controls) {
          if (controlsContainer) {
            showElement(controlsContainer);
          } else {
            if (prevButton) { showElement(prevButton); }
            if (nextButton) { showElement(nextButton); }
          }
        } else {
          if (controlsContainer) {
            hideElement(controlsContainer);
          } else {
            if (prevButton) { hideElement(prevButton); }
            if (nextButton) { hideElement(nextButton); }
          }
        }
      }
      if (nav !== navTem) {
        if (nav) {
          showElement(navContainer);
          updateNavVisibility();
        } else {
          hideElement(navContainer);
        }
      }
      if (touch !== touchTem) {
        touch ?
          addEvents(container, touchEvents, options.preventScrollOnTouch) :
          removeEvents(container, touchEvents);
      }
      if (mouseDrag !== mouseDragTem) {
        mouseDrag ?
          addEvents(container, dragEvents) :
          removeEvents(container, dragEvents);
      }
      if (autoplay !== autoplayTem) {
        if (autoplay) {
          if (autoplayButton) { showElement(autoplayButton); }
          if (!animating && !autoplayUserPaused) { startAutoplay(); }
        } else {
          if (autoplayButton) { hideElement(autoplayButton); }
          if (animating) { stopAutoplay(); }
        }
      }
      if (autoplayHoverPause !== autoplayHoverPauseTem) {
        autoplayHoverPause ?
          addEvents(container, hoverEvents) :
          removeEvents(container, hoverEvents);
      }
      if (autoplayResetOnVisibility !== autoplayResetOnVisibilityTem) {
        autoplayResetOnVisibility ?
          addEvents(doc, visibilityEvent) :
          removeEvents(doc, visibilityEvent);
      }

      if (bpChanged) {
        if (fixedWidth !== fixedWidthTem || center !== centerTem) { needContainerTransform = true; }

        if (autoHeight !== autoHeightTem) {
          if (!autoHeight) { innerWrapper.style.height = ''; }
        }

        if (controls && controlsText !== controlsTextTem) {
          prevButton.innerHTML = controlsText[0];
          nextButton.innerHTML = controlsText[1];
        }

        if (autoplayButton && autoplayText !== autoplayTextTem) {
          var i = autoplay ? 1 : 0,
              html = autoplayButton.innerHTML,
              len = html.length - autoplayTextTem[i].length;
          if (html.substring(len) === autoplayTextTem[i]) {
            autoplayButton.innerHTML = html.substring(0, len) + autoplayText[i];
          }
        }
      } else {
        if (center && (fixedWidth || autoWidth)) { needContainerTransform = true; }
      }

      if (itemsChanged || fixedWidth && !autoWidth) {
        pages = getPages();
        updateNavVisibility();
      }

      indChanged = index !== indexTem;
      if (indChanged) {
        events.emit('indexChanged', info());
        needContainerTransform = true;
      } else if (itemsChanged) {
        if (!indChanged) { additionalUpdates(); }
      } else if (fixedWidth || autoWidth) {
        doLazyLoad();
        updateSlideStatus();
        updateLiveRegion();
      }

      if (itemsChanged && !carousel) { updateGallerySlidePositions(); }

      if (!disable && !freeze) {
        // non-mediaqueries: IE8
        if (bpChanged && !CSSMQ) {
          // middle wrapper styles

          // inner wrapper styles
          if (edgePadding !== edgePaddingTem || gutter !== gutterTem) {
            innerWrapper.style.cssText = getInnerWrapperStyles(edgePadding, gutter, fixedWidth, speed, autoHeight);
          }

          if (horizontal) {
            // container styles
            if (carousel) {
              container.style.width = getContainerWidth(fixedWidth, gutter, items);
            }

            // slide styles
            var str = getSlideWidthStyle(fixedWidth, gutter, items) +
                      getSlideGutterStyle(gutter);

            // remove the last line and
            // add new styles
            removeCSSRule(sheet, getCssRulesLength(sheet) - 1);
            addCSSRule(sheet, '#' + slideId + ' > .tns-item', str, getCssRulesLength(sheet));
          }
        }

        // auto height
        if (autoHeight) { doAutoHeight(); }

        if (needContainerTransform) {
          doContainerTransformSilent();
          indexCached = index;
        }
      }

      if (bpChanged) { events.emit('newBreakpointEnd', info(e)); }
    }





    // === INITIALIZATION FUNCTIONS === //
    function getFreeze () {
      if (!fixedWidth && !autoWidth) {
        var a = center ? items - (items - 1) / 2 : items;
        return  slideCount <= a;
      }

      var width = fixedWidth ? (fixedWidth + gutter) * slideCount : slidePositions[slideCount],
          vp = edgePadding ? viewport + edgePadding * 2 : viewport + gutter;

      if (center) {
        vp -= fixedWidth ? (viewport - fixedWidth) / 2 : (viewport - (slidePositions[index + 1] - slidePositions[index] - gutter)) / 2;
      }

      return width <= vp;
    }

    function setBreakpointZone () {
      breakpointZone = 0;
      for (var bp in responsive) {
        bp = parseInt(bp); // convert string to number
        if (windowWidth >= bp) { breakpointZone = bp; }
      }
    }

    // (slideBy, indexMin, indexMax) => index
    var updateIndex = (function () {
      return loop ?
        carousel ?
          // loop + carousel
          function () {
            var leftEdge = indexMin,
                rightEdge = indexMax;

            leftEdge += slideBy;
            rightEdge -= slideBy;

            // adjust edges when has edge paddings
            // or fixed-width slider with extra space on the right side
            if (edgePadding) {
              leftEdge += 1;
              rightEdge -= 1;
            } else if (fixedWidth) {
              if ((viewport + gutter)%(fixedWidth + gutter)) { rightEdge -= 1; }
            }

            if (cloneCount) {
              if (index > rightEdge) {
                index -= slideCount;
              } else if (index < leftEdge) {
                index += slideCount;
              }
            }
          } :
          // loop + gallery
          function() {
            if (index > indexMax) {
              while (index >= indexMin + slideCount) { index -= slideCount; }
            } else if (index < indexMin) {
              while (index <= indexMax - slideCount) { index += slideCount; }
            }
          } :
        // non-loop
        function() {
          index = Math.max(indexMin, Math.min(indexMax, index));
        };
    })();

    function disableUI () {
      if (!autoplay && autoplayButton) { hideElement(autoplayButton); }
      if (!nav && navContainer) { hideElement(navContainer); }
      if (!controls) {
        if (controlsContainer) {
          hideElement(controlsContainer);
        } else {
          if (prevButton) { hideElement(prevButton); }
          if (nextButton) { hideElement(nextButton); }
        }
      }
    }

    function enableUI () {
      if (autoplay && autoplayButton) { showElement(autoplayButton); }
      if (nav && navContainer) { showElement(navContainer); }
      if (controls) {
        if (controlsContainer) {
          showElement(controlsContainer);
        } else {
          if (prevButton) { showElement(prevButton); }
          if (nextButton) { showElement(nextButton); }
        }
      }
    }

    function freezeSlider () {
      if (frozen) { return; }

      // remove edge padding from inner wrapper
      if (edgePadding) { innerWrapper.style.margin = '0px'; }

      // add class tns-transparent to cloned slides
      if (cloneCount) {
        var str = 'tns-transparent';
        for (var i = cloneCount; i--;) {
          if (carousel) { addClass(slideItems[i], str); }
          addClass(slideItems[slideCountNew - i - 1], str);
        }
      }

      // update tools
      disableUI();

      frozen = true;
    }

    function unfreezeSlider () {
      if (!frozen) { return; }

      // restore edge padding for inner wrapper
      // for mordern browsers
      if (edgePadding && CSSMQ) { innerWrapper.style.margin = ''; }

      // remove class tns-transparent to cloned slides
      if (cloneCount) {
        var str = 'tns-transparent';
        for (var i = cloneCount; i--;) {
          if (carousel) { removeClass(slideItems[i], str); }
          removeClass(slideItems[slideCountNew - i - 1], str);
        }
      }

      // update tools
      enableUI();

      frozen = false;
    }

    function disableSlider () {
      if (disabled) { return; }

      sheet.disabled = true;
      container.className = container.className.replace(newContainerClasses.substring(1), '');
      removeAttrs(container, ['style']);
      if (loop) {
        for (var j = cloneCount; j--;) {
          if (carousel) { hideElement(slideItems[j]); }
          hideElement(slideItems[slideCountNew - j - 1]);
        }
      }

      // vertical slider
      if (!horizontal || !carousel) { removeAttrs(innerWrapper, ['style']); }

      // gallery
      if (!carousel) {
        for (var i = index, l = index + slideCount; i < l; i++) {
          var item = slideItems[i];
          removeAttrs(item, ['style']);
          removeClass(item, animateIn);
          removeClass(item, animateNormal);
        }
      }

      // update tools
      disableUI();

      disabled = true;
    }

    function enableSlider () {
      if (!disabled) { return; }

      sheet.disabled = false;
      container.className += newContainerClasses;
      doContainerTransformSilent();

      if (loop) {
        for (var j = cloneCount; j--;) {
          if (carousel) { showElement(slideItems[j]); }
          showElement(slideItems[slideCountNew - j - 1]);
        }
      }

      // gallery
      if (!carousel) {
        for (var i = index, l = index + slideCount; i < l; i++) {
          var item = slideItems[i],
              classN = i < index + items ? animateIn : animateNormal;
          item.style.left = (i - index) * 100 / items + '%';
          addClass(item, classN);
        }
      }

      // update tools
      enableUI();

      disabled = false;
    }

    function updateLiveRegion () {
      var str = getLiveRegionStr();
      if (liveregionCurrent.innerHTML !== str) { liveregionCurrent.innerHTML = str; }
    }

    function getLiveRegionStr () {
      var arr = getVisibleSlideRange(),
          start = arr[0] + 1,
          end = arr[1] + 1;
      return start === end ? start + '' : start + ' to ' + end;
    }

    function getVisibleSlideRange (val) {
      if (val == null) { val = getContainerTransformValue(); }
      var start = index, end, rangestart, rangeend;

      // get range start, range end for autoWidth and fixedWidth
      if (center || edgePadding) {
        if (autoWidth || fixedWidth) {
          rangestart = - (parseFloat(val) + edgePadding);
          rangeend = rangestart + viewport + edgePadding * 2;
        }
      } else {
        if (autoWidth) {
          rangestart = slidePositions[index];
          rangeend = rangestart + viewport;
        }
      }

      // get start, end
      // - check auto width
      if (autoWidth) {
        slidePositions.forEach(function(point, i) {
          if (i < slideCountNew) {
            if ((center || edgePadding) && point <= rangestart + 0.5) { start = i; }
            if (rangeend - point >= 0.5) { end = i; }
          }
        });

      // - check percentage width, fixed width
      } else {

        if (fixedWidth) {
          var cell = fixedWidth + gutter;
          if (center || edgePadding) {
            start = Math.floor(rangestart/cell);
            end = Math.ceil(rangeend/cell - 1);
          } else {
            end = start + Math.ceil(viewport/cell) - 1;
          }

        } else {
          if (center || edgePadding) {
            var a = items - 1;
            if (center) {
              start -= a / 2;
              end = index + a / 2;
            } else {
              end = index + a;
            }

            if (edgePadding) {
              var b = edgePadding * items / viewport;
              start -= b;
              end += b;
            }

            start = Math.floor(start);
            end = Math.ceil(end);
          } else {
            end = start + items - 1;
          }
        }

        start = Math.max(start, 0);
        end = Math.min(end, slideCountNew - 1);
      }

      return [start, end];
    }

    function doLazyLoad () {
      if (lazyload && !disable) {
        var arg = getVisibleSlideRange();
        arg.push(lazyloadSelector);

        getImageArray.apply(null, arg).forEach(function (img) {
          if (!hasClass(img, imgCompleteClass)) {
            // stop propagation transitionend event to container
            var eve = {};
            eve[TRANSITIONEND] = function (e) { e.stopPropagation(); };
            addEvents(img, eve);

            addEvents(img, imgEvents);

            // update src
            img.src = getAttr(img, 'data-src');

            // update srcset
            var srcset = getAttr(img, 'data-srcset');
            if (srcset) { img.srcset = srcset; }

            addClass(img, 'loading');
          }
        });
      }
    }

    function onImgLoaded (e) {
      imgLoaded(getTarget(e));
    }

    function onImgFailed (e) {
      imgFailed(getTarget(e));
    }

    function imgLoaded (img) {
      addClass(img, 'loaded');
      imgCompleted(img);
    }

    function imgFailed (img) {
      addClass(img, 'failed');
      imgCompleted(img);
    }

    function imgCompleted (img) {
      addClass(img, imgCompleteClass);
      removeClass(img, 'loading');
      removeEvents(img, imgEvents);
    }

    function getImageArray (start, end, imgSelector) {
      var imgs = [];
      if (!imgSelector) { imgSelector = 'img'; }

      while (start <= end) {
        forEach(slideItems[start].querySelectorAll(imgSelector), function (img) { imgs.push(img); });
        start++;
      }

      return imgs;
    }

    // check if all visible images are loaded
    // and update container height if it's done
    function doAutoHeight () {
      var imgs = getImageArray.apply(null, getVisibleSlideRange());
      raf(function(){ imgsLoadedCheck(imgs, updateInnerWrapperHeight); });
    }

    function imgsLoadedCheck (imgs, cb) {
      // execute callback function if all images are complete
      if (imgsComplete) { return cb(); }

      // check image classes
      imgs.forEach(function (img, index) {
        if (!lazyload && img.complete) { imgCompleted(img); } // Check image.complete
        if (hasClass(img, imgCompleteClass)) { imgs.splice(index, 1); }
      });

      // execute callback function if selected images are all complete
      if (!imgs.length) { return cb(); }

      // otherwise execute this functiona again
      raf(function(){ imgsLoadedCheck(imgs, cb); });
    }

    function additionalUpdates () {
      doLazyLoad();
      updateSlideStatus();
      updateLiveRegion();
      updateControlsStatus();
      updateNavStatus();
    }


    function update_carousel_transition_duration () {
      if (carousel && autoHeight) {
        middleWrapper.style[TRANSITIONDURATION] = speed / 1000 + 's';
      }
    }

    function getMaxSlideHeight (slideStart, slideRange) {
      var heights = [];
      for (var i = slideStart, l = Math.min(slideStart + slideRange, slideCountNew); i < l; i++) {
        heights.push(slideItems[i].offsetHeight);
      }

      return Math.max.apply(null, heights);
    }

    // update inner wrapper height
    // 1. get the max-height of the visible slides
    // 2. set transitionDuration to speed
    // 3. update inner wrapper height to max-height
    // 4. set transitionDuration to 0s after transition done
    function updateInnerWrapperHeight () {
      var maxHeight = autoHeight ? getMaxSlideHeight(index, items) : getMaxSlideHeight(cloneCount, slideCount),
          wp = middleWrapper ? middleWrapper : innerWrapper;

      if (wp.style.height !== maxHeight) { wp.style.height = maxHeight + 'px'; }
    }

    // get the distance from the top edge of the first slide to each slide
    // (init) => slidePositions
    function setSlidePositions () {
      slidePositions = [0];
      var attr = horizontal ? 'left' : 'top',
          attr2 = horizontal ? 'right' : 'bottom',
          base = slideItems[0].getBoundingClientRect()[attr];

      forEach(slideItems, function(item, i) {
        // skip the first slide
        if (i) { slidePositions.push(item.getBoundingClientRect()[attr] - base); }
        // add the end edge
        if (i === slideCountNew - 1) { slidePositions.push(item.getBoundingClientRect()[attr2] - base); }
      });
    }

    // update slide
    function updateSlideStatus () {
      var range = getVisibleSlideRange(),
          start = range[0],
          end = range[1];

      forEach(slideItems, function(item, i) {
        // show slides
        if (i >= start && i <= end) {
          if (hasAttr(item, 'aria-hidden')) {
            removeAttrs(item, ['aria-hidden', 'tabindex']);
            addClass(item, slideActiveClass);
          }
        // hide slides
        } else {
          if (!hasAttr(item, 'aria-hidden')) {
            setAttrs(item, {
              'aria-hidden': 'true',
              'tabindex': '-1'
            });
            removeClass(item, slideActiveClass);
          }
        }
      });
    }

    // gallery: update slide position
    function updateGallerySlidePositions () {
      var l = index + Math.min(slideCount, items);
      for (var i = slideCountNew; i--;) {
        var item = slideItems[i];

        if (i >= index && i < l) {
          // add transitions to visible slides when adjusting their positions
          addClass(item, 'tns-moving');

          item.style.left = (i - index) * 100 / items + '%';
          addClass(item, animateIn);
          removeClass(item, animateNormal);
        } else if (item.style.left) {
          item.style.left = '';
          addClass(item, animateNormal);
          removeClass(item, animateIn);
        }

        // remove outlet animation
        removeClass(item, animateOut);
      }

      // removing '.tns-moving'
      setTimeout(function() {
        forEach(slideItems, function(el) {
          removeClass(el, 'tns-moving');
        });
      }, 300);
    }

    // set tabindex on Nav
    function updateNavStatus () {
      // get current nav
      if (nav) {
        navCurrentIndex = navClicked >= 0 ? navClicked : getCurrentNavIndex();
        navClicked = -1;

        if (navCurrentIndex !== navCurrentIndexCached) {
          var navPrev = navItems[navCurrentIndexCached],
              navCurrent = navItems[navCurrentIndex];

          setAttrs(navPrev, {
            'tabindex': '-1',
            'aria-label': navStr + (navCurrentIndexCached + 1)
          });
          removeClass(navPrev, navActiveClass);

          setAttrs(navCurrent, {'aria-label': navStr + (navCurrentIndex + 1) + navStrCurrent});
          removeAttrs(navCurrent, 'tabindex');
          addClass(navCurrent, navActiveClass);

          navCurrentIndexCached = navCurrentIndex;
        }
      }
    }

    function getLowerCaseNodeName (el) {
      return el.nodeName.toLowerCase();
    }

    function isButton (el) {
      return getLowerCaseNodeName(el) === 'button';
    }

    function isAriaDisabled (el) {
      return el.getAttribute('aria-disabled') === 'true';
    }

    function disEnableElement (isButton, el, val) {
      if (isButton) {
        el.disabled = val;
      } else {
        el.setAttribute('aria-disabled', val.toString());
      }
    }

    // set 'disabled' to true on controls when reach the edges
    function updateControlsStatus () {
      if (!controls || rewind || loop) { return; }

      var prevDisabled = (prevIsButton) ? prevButton.disabled : isAriaDisabled(prevButton),
          nextDisabled = (nextIsButton) ? nextButton.disabled : isAriaDisabled(nextButton),
          disablePrev = (index <= indexMin) ? true : false,
          disableNext = (!rewind && index >= indexMax) ? true : false;

      if (disablePrev && !prevDisabled) {
        disEnableElement(prevIsButton, prevButton, true);
      }
      if (!disablePrev && prevDisabled) {
        disEnableElement(prevIsButton, prevButton, false);
      }
      if (disableNext && !nextDisabled) {
        disEnableElement(nextIsButton, nextButton, true);
      }
      if (!disableNext && nextDisabled) {
        disEnableElement(nextIsButton, nextButton, false);
      }
    }

    // set duration
    function resetDuration (el, str) {
      if (TRANSITIONDURATION) { el.style[TRANSITIONDURATION] = str; }
    }

    function getSliderWidth () {
      return fixedWidth ? (fixedWidth + gutter) * slideCountNew : slidePositions[slideCountNew];
    }

    function getCenterGap (num) {
      if (num == null) { num = index; }

      var gap = edgePadding ? gutter : 0;
      return autoWidth ? ((viewport - gap) - (slidePositions[num + 1] - slidePositions[num] - gutter))/2 :
        fixedWidth ? (viewport - fixedWidth) / 2 :
          (items - 1) / 2;
    }

    function getRightBoundary () {
      var gap = edgePadding ? gutter : 0,
          result = (viewport + gap) - getSliderWidth();

      if (center && !loop) {
        result = fixedWidth ? - (fixedWidth + gutter) * (slideCountNew - 1) - getCenterGap() :
          getCenterGap(slideCountNew - 1) - slidePositions[slideCountNew - 1];
      }
      if (result > 0) { result = 0; }

      return result;
    }

    function getContainerTransformValue (num) {
      if (num == null) { num = index; }

      var val;
      if (horizontal && !autoWidth) {
        if (fixedWidth) {
          val = - (fixedWidth + gutter) * num;
          if (center) { val += getCenterGap(); }
        } else {
          var denominator = TRANSFORM ? slideCountNew : items;
          if (center) { num -= getCenterGap(); }
          val = - num * 100 / denominator;
        }
      } else {
        val = - slidePositions[num];
        if (center && autoWidth) {
          val += getCenterGap();
        }
      }

      if (hasRightDeadZone) { val = Math.max(val, rightBoundary); }

      val += (horizontal && !autoWidth && !fixedWidth) ? '%' : 'px';

      return val;
    }

    function doContainerTransformSilent (val) {
      resetDuration(container, '0s');
      doContainerTransform(val);
    }

    function doContainerTransform (val) {
      if (val == null) { val = getContainerTransformValue(); }
      if (textDirection === 'rtl' && val.charAt(0) === '-') {
        val = val.substr(1);
      }
      container.style[transformAttr] = transformPrefix + val + transformPostfix;
    }

    function animateSlide (number, classOut, classIn, isOut) {
      var l = number + items;
      if (!loop) { l = Math.min(l, slideCountNew); }

      for (var i = number; i < l; i++) {
          var item = slideItems[i];

        // set item positions
        if (!isOut) { item.style.left = (i - index) * 100 / items + '%'; }

        if (animateDelay && TRANSITIONDELAY) {
          item.style[TRANSITIONDELAY] = item.style[ANIMATIONDELAY] = animateDelay * (i - number) / 1000 + 's';
        }
        removeClass(item, classOut);
        addClass(item, classIn);

        if (isOut) { slideItemsOut.push(item); }
      }
    }

    // make transfer after click/drag:
    // 1. change 'transform' property for mordern browsers
    // 2. change 'left' property for legacy browsers
    var transformCore = (function () {
      return carousel ?
        function () {
          resetDuration(container, '');
          if (TRANSITIONDURATION || !speed) {
            // for morden browsers with non-zero duration or
            // zero duration for all browsers
            doContainerTransform();
            // run fallback function manually
            // when duration is 0 / container is hidden
            if (!speed || !isVisible(container)) { onTransitionEnd(); }

          } else {
            // for old browser with non-zero duration
            jsTransform(container, transformAttr, transformPrefix, transformPostfix, getContainerTransformValue(), speed, onTransitionEnd);
          }

          if (!horizontal) { updateContentWrapperHeight(); }
        } :
        function () {
          slideItemsOut = [];

          var eve = {};
          eve[TRANSITIONEND] = eve[ANIMATIONEND] = onTransitionEnd;
          removeEvents(slideItems[indexCached], eve);
          addEvents(slideItems[index], eve);

          animateSlide(indexCached, animateIn, animateOut, true);
          animateSlide(index, animateNormal, animateIn);

          // run fallback function manually
          // when transition or animation not supported / duration is 0
          if (!TRANSITIONEND || !ANIMATIONEND || !speed || !isVisible(container)) { onTransitionEnd(); }
        };
    })();

    function render (e, sliderMoved) {
      if (updateIndexBeforeTransform) { updateIndex(); }

      // render when slider was moved (touch or drag) even though index may not change
      if (index !== indexCached || sliderMoved) {
        // events
        events.emit('indexChanged', info());
        events.emit('transitionStart', info());
        if (autoHeight) { doAutoHeight(); }

        // pause autoplay when click or keydown from user
        if (animating && e && ['click', 'keydown'].indexOf(e.type) >= 0) { stopAutoplay(); }

        running = true;
        transformCore();
      }
    }

    /*
     * Transfer prefixed properties to the same format
     * CSS: -Webkit-Transform => webkittransform
     * JS: WebkitTransform => webkittransform
     * @param {string} str - property
     *
     */
    function strTrans (str) {
      return str.toLowerCase().replace(/-/g, '');
    }

    // AFTER TRANSFORM
    // Things need to be done after a transfer:
    // 1. check index
    // 2. add classes to visible slide
    // 3. disable controls buttons when reach the first/last slide in non-loop slider
    // 4. update nav status
    // 5. lazyload images
    // 6. update container height
    function onTransitionEnd (event) {
      // check running on gallery mode
      // make sure trantionend/animationend events run only once
      if (carousel || running) {
        events.emit('transitionEnd', info(event));

        if (!carousel && slideItemsOut.length > 0) {
          for (var i = 0; i < slideItemsOut.length; i++) {
            var item = slideItemsOut[i];
            // set item positions
            item.style.left = '';

            if (ANIMATIONDELAY && TRANSITIONDELAY) {
              item.style[ANIMATIONDELAY] = '';
              item.style[TRANSITIONDELAY] = '';
            }
            removeClass(item, animateOut);
            addClass(item, animateNormal);
          }
        }

        /* update slides, nav, controls after checking ...
         * => legacy browsers who don't support 'event'
         *    have to check event first, otherwise event.target will cause an error
         * => or 'gallery' mode:
         *   + event target is slide item
         * => or 'carousel' mode:
         *   + event target is container,
         *   + event.property is the same with transform attribute
         */
        if (!event ||
            !carousel && event.target.parentNode === container ||
            event.target === container && strTrans(event.propertyName) === strTrans(transformAttr)) {

          if (!updateIndexBeforeTransform) {
            var indexTem = index;
            updateIndex();
            if (index !== indexTem) {
              events.emit('indexChanged', info());

              doContainerTransformSilent();
            }
          }

          if (nested === 'inner') { events.emit('innerLoaded', info()); }
          running = false;
          indexCached = index;
        }
      }

    }

    // # ACTIONS
    function goTo (targetIndex, e) {
      if (freeze) { return; }

      // prev slideBy
      if (targetIndex === 'prev') {
        onControlsClick(e, -1);

      // next slideBy
      } else if (targetIndex === 'next') {
        onControlsClick(e, 1);

      // go to exact slide
      } else {
        if (running) {
          if (preventActionWhenRunning) { return; } else { onTransitionEnd(); }
        }

        var absIndex = getAbsIndex(),
            indexGap = 0;

        if (targetIndex === 'first') {
          indexGap = - absIndex;
        } else if (targetIndex === 'last') {
          indexGap = carousel ? slideCount - items - absIndex : slideCount - 1 - absIndex;
        } else {
          if (typeof targetIndex !== 'number') { targetIndex = parseInt(targetIndex); }

          if (!isNaN(targetIndex)) {
            // from directly called goTo function
            if (!e) { targetIndex = Math.max(0, Math.min(slideCount - 1, targetIndex)); }

            indexGap = targetIndex - absIndex;
          }
        }

        // gallery: make sure new page won't overlap with current page
        if (!carousel && indexGap && Math.abs(indexGap) < items) {
          var factor = indexGap > 0 ? 1 : -1;
          indexGap += (index + indexGap - slideCount) >= indexMin ? slideCount * factor : slideCount * 2 * factor * -1;
        }

        index += indexGap;

        // make sure index is in range
        if (carousel && loop) {
          if (index < indexMin) { index += slideCount; }
          if (index > indexMax) { index -= slideCount; }
        }

        // if index is changed, start rendering
        if (getAbsIndex(index) !== getAbsIndex(indexCached)) {
          render(e);
        }

      }
    }

    // on controls click
    function onControlsClick (e, dir) {
      if (running) {
        if (preventActionWhenRunning) { return; } else { onTransitionEnd(); }
      }
      var passEventObject;

      if (!dir) {
        e = getEvent(e);
        var target = getTarget(e);

        while (target !== controlsContainer && [prevButton, nextButton].indexOf(target) < 0) { target = target.parentNode; }

        var targetIn = [prevButton, nextButton].indexOf(target);
        if (targetIn >= 0) {
          passEventObject = true;
          dir = targetIn === 0 ? -1 : 1;
        }
      }

      if (rewind) {
        if (index === indexMin && dir === -1) {
          goTo('last', e);
          return;
        } else if (index === indexMax && dir === 1) {
          goTo('first', e);
          return;
        }
      }

      if (dir) {
        index += slideBy * dir;
        if (autoWidth) { index = Math.floor(index); }
        // pass e when click control buttons or keydown
        render((passEventObject || (e && e.type === 'keydown')) ? e : null);
      }
    }

    // on nav click
    function onNavClick (e) {
      if (running) {
        if (preventActionWhenRunning) { return; } else { onTransitionEnd(); }
      }

      e = getEvent(e);
      var target = getTarget(e), navIndex;

      // find the clicked nav item
      while (target !== navContainer && !hasAttr(target, 'data-nav')) { target = target.parentNode; }
      if (hasAttr(target, 'data-nav')) {
        var navIndex = navClicked = Number(getAttr(target, 'data-nav')),
            targetIndexBase = fixedWidth || autoWidth ? navIndex * slideCount / pages : navIndex * items,
            targetIndex = navAsThumbnails ? navIndex : Math.min(Math.ceil(targetIndexBase), slideCount - 1);
        goTo(targetIndex, e);

        if (navCurrentIndex === navIndex) {
          if (animating) { stopAutoplay(); }
          navClicked = -1; // reset navClicked
        }
      }
    }

    // autoplay functions
    function setAutoplayTimer () {
      autoplayTimer = setInterval(function () {
        onControlsClick(null, autoplayDirection);
      }, autoplayTimeout);

      animating = true;
    }

    function stopAutoplayTimer () {
      clearInterval(autoplayTimer);
      animating = false;
    }

    function updateAutoplayButton (action, txt) {
      setAttrs(autoplayButton, {'data-action': action});
      autoplayButton.innerHTML = autoplayHtmlStrings[0] + action + autoplayHtmlStrings[1] + txt;
    }

    function startAutoplay () {
      setAutoplayTimer();
      if (autoplayButton) { updateAutoplayButton('stop', autoplayText[1]); }
    }

    function stopAutoplay () {
      stopAutoplayTimer();
      if (autoplayButton) { updateAutoplayButton('start', autoplayText[0]); }
    }

    // programaitcally play/pause the slider
    function play () {
      if (autoplay && !animating) {
        startAutoplay();
        autoplayUserPaused = false;
      }
    }
    function pause () {
      if (animating) {
        stopAutoplay();
        autoplayUserPaused = true;
      }
    }

    function toggleAutoplay () {
      if (animating) {
        stopAutoplay();
        autoplayUserPaused = true;
      } else {
        startAutoplay();
        autoplayUserPaused = false;
      }
    }

    function onVisibilityChange () {
      if (doc.hidden) {
        if (animating) {
          stopAutoplayTimer();
          autoplayVisibilityPaused = true;
        }
      } else if (autoplayVisibilityPaused) {
        setAutoplayTimer();
        autoplayVisibilityPaused = false;
      }
    }

    function mouseoverPause () {
      if (animating) {
        stopAutoplayTimer();
        autoplayHoverPaused = true;
      }
    }

    function mouseoutRestart () {
      if (autoplayHoverPaused) {
        setAutoplayTimer();
        autoplayHoverPaused = false;
      }
    }

    // keydown events on document
    function onDocumentKeydown (e) {
      e = getEvent(e);
      var keyIndex = [KEYS.LEFT, KEYS.RIGHT].indexOf(e.keyCode);

      if (keyIndex >= 0) {
        onControlsClick(e, keyIndex === 0 ? -1 : 1);
      }
    }

    // on key control
    function onControlsKeydown (e) {
      e = getEvent(e);
      var keyIndex = [KEYS.LEFT, KEYS.RIGHT].indexOf(e.keyCode);

      if (keyIndex >= 0) {
        if (keyIndex === 0) {
          if (!prevButton.disabled) { onControlsClick(e, -1); }
        } else if (!nextButton.disabled) {
          onControlsClick(e, 1);
        }
      }
    }

    // set focus
    function setFocus (el) {
      el.focus();
    }

    // on key nav
    function onNavKeydown (e) {
      e = getEvent(e);
      var curElement = doc.activeElement;
      if (!hasAttr(curElement, 'data-nav')) { return; }

      // var code = e.keyCode,
      var keyIndex = [KEYS.LEFT, KEYS.RIGHT, KEYS.ENTER, KEYS.SPACE].indexOf(e.keyCode),
          navIndex = Number(getAttr(curElement, 'data-nav'));

      if (keyIndex >= 0) {
        if (keyIndex === 0) {
          if (navIndex > 0) { setFocus(navItems[navIndex - 1]); }
        } else if (keyIndex === 1) {
          if (navIndex < pages - 1) { setFocus(navItems[navIndex + 1]); }
        } else {
          navClicked = navIndex;
          goTo(navIndex, e);
        }
      }
    }

    function getEvent (e) {
      e = e || win.event;
      return isTouchEvent(e) ? e.changedTouches[0] : e;
    }
    function getTarget (e) {
      return e.target || win.event.srcElement;
    }

    function isTouchEvent (e) {
      return e.type.indexOf('touch') >= 0;
    }

    function preventDefaultBehavior (e) {
      e.preventDefault ? e.preventDefault() : e.returnValue = false;
    }

    function getMoveDirectionExpected () {
      return getTouchDirection(toDegree(lastPosition.y - initPosition.y, lastPosition.x - initPosition.x), swipeAngle) === options.axis;
    }

    function onPanStart (e) {
      if (running) {
        if (preventActionWhenRunning) { return; } else { onTransitionEnd(); }
      }

      if (autoplay && animating) { stopAutoplayTimer(); }

      panStart = true;
      if (rafIndex) {
        caf(rafIndex);
        rafIndex = null;
      }

      var $ = getEvent(e);
      events.emit(isTouchEvent(e) ? 'touchStart' : 'dragStart', info(e));

      if (!isTouchEvent(e) && ['img', 'a'].indexOf(getLowerCaseNodeName(getTarget(e))) >= 0) {
        preventDefaultBehavior(e);
      }

      lastPosition.x = initPosition.x = $.clientX;
      lastPosition.y = initPosition.y = $.clientY;
      if (carousel) {
        translateInit = parseFloat(container.style[transformAttr].replace(transformPrefix, ''));
        resetDuration(container, '0s');
      }
    }

    function onPanMove (e) {
      if (panStart) {
        var $ = getEvent(e);
        lastPosition.x = $.clientX;
        lastPosition.y = $.clientY;

        if (carousel) {
          if (!rafIndex) { rafIndex = raf(function(){ panUpdate(e); }); }
        } else {
          if (moveDirectionExpected === '?') { moveDirectionExpected = getMoveDirectionExpected(); }
          if (moveDirectionExpected) { preventScroll = true; }
        }

        if ((typeof e.cancelable !== 'boolean' || e.cancelable) && preventScroll) {
          e.preventDefault();
        }
      }
    }

    function panUpdate (e) {
      if (!moveDirectionExpected) {
        panStart = false;
        return;
      }
      caf(rafIndex);
      if (panStart) { rafIndex = raf(function(){ panUpdate(e); }); }

      if (moveDirectionExpected === '?') { moveDirectionExpected = getMoveDirectionExpected(); }
      if (moveDirectionExpected) {
        if (!preventScroll && isTouchEvent(e)) { preventScroll = true; }

        try {
          if (e.type) { events.emit(isTouchEvent(e) ? 'touchMove' : 'dragMove', info(e)); }
        } catch(err) {}

        var x = translateInit,
            dist = getDist(lastPosition, initPosition);
        if (!horizontal || fixedWidth || autoWidth) {
          x += dist;
          x += 'px';
        } else {
          var percentageX = TRANSFORM ? dist * items * 100 / ((viewport + gutter) * slideCountNew): dist * 100 / (viewport + gutter);
          x += percentageX;
          x += '%';
        }

        container.style[transformAttr] = transformPrefix + x + transformPostfix;
      }
    }

    function onPanEnd (e) {
      if (panStart) {
        if (rafIndex) {
          caf(rafIndex);
          rafIndex = null;
        }
        if (carousel) { resetDuration(container, ''); }
        panStart = false;

        var $ = getEvent(e);
        lastPosition.x = $.clientX;
        lastPosition.y = $.clientY;
        var dist = getDist(lastPosition, initPosition);

        if (Math.abs(dist)) {
          // drag vs click
          if (!isTouchEvent(e)) {
            // prevent "click"
            var target = getTarget(e);
            addEvents(target, {'click': function preventClick (e) {
              preventDefaultBehavior(e);
              removeEvents(target, {'click': preventClick});
            }});
          }

          if (carousel) {
            rafIndex = raf(function() {
              if (horizontal && !autoWidth) {
                var indexMoved = - dist * items / (viewport + gutter);
                indexMoved = dist > 0 ? Math.floor(indexMoved) : Math.ceil(indexMoved);
                if (textDirection === 'rtl') { 
                  index += indexMoved * -1;
                } else {
                  index += indexMoved;
                }
              } else {
                var moved = - (translateInit + dist);
                if (moved <= 0) {
                  index = indexMin;
                } else if (moved >= slidePositions[slideCountNew - 1]) {
                  index = indexMax;
                } else {
                  var i = 0;
                  while (i < slideCountNew && moved >= slidePositions[i]) {
                    index = i;
                    if (moved > slidePositions[i] && dist < 0) { index += 1; }
                    i++;
                  }
                }
              }

              render(e, dist);
              events.emit(isTouchEvent(e) ? 'touchEnd' : 'dragEnd', info(e));
            });
          } else {
            if (moveDirectionExpected) {
              onControlsClick(e, dist > 0 ? -1 : 1);
            }
          }
        }
      }

      // reset
      if (options.preventScrollOnTouch === 'auto') { preventScroll = false; }
      if (swipeAngle) { moveDirectionExpected = '?'; }
      if (autoplay && !animating) { setAutoplayTimer(); }
    }

    // === RESIZE FUNCTIONS === //
    // (slidePositions, index, items) => vertical_conentWrapper.height
    function updateContentWrapperHeight () {
      var wp = middleWrapper ? middleWrapper : innerWrapper;
      wp.style.height = slidePositions[index + items] - slidePositions[index] + 'px';
    }

    function getPages () {
      var rough = fixedWidth ? (fixedWidth + gutter) * slideCount / viewport : slideCount / items;
      return Math.min(Math.ceil(rough), slideCount);
    }

    /*
     * 1. update visible nav items list
     * 2. add "hidden" attributes to previous visible nav items
     * 3. remove "hidden" attrubutes to new visible nav items
     */
    function updateNavVisibility () {
      if (!nav || navAsThumbnails) { return; }

      if (pages !== pagesCached) {
        var min = pagesCached,
            max = pages,
            fn = showElement;

        if (pagesCached > pages) {
          min = pages;
          max = pagesCached;
          fn = hideElement;
        }

        while (min < max) {
          fn(navItems[min]);
          min++;
        }

        // cache pages
        pagesCached = pages;
      }
    }

    function info (e) {
      return {
        container: container,
        slideItems: slideItems,
        navContainer: navContainer,
        navItems: navItems,
        controlsContainer: controlsContainer,
        hasControls: hasControls,
        prevButton: prevButton,
        nextButton: nextButton,
        items: items,
        slideBy: slideBy,
        cloneCount: cloneCount,
        slideCount: slideCount,
        slideCountNew: slideCountNew,
        index: index,
        indexCached: indexCached,
        displayIndex: getCurrentSlide(),
        navCurrentIndex: navCurrentIndex,
        navCurrentIndexCached: navCurrentIndexCached,
        pages: pages,
        pagesCached: pagesCached,
        sheet: sheet,
        isOn: isOn,
        event: e || {},
      };
    }

    return {
      version: '2.9.3',
      getInfo: info,
      events: events,
      goTo: goTo,
      play: play,
      pause: pause,
      isOn: isOn,
      updateSliderHeight: updateInnerWrapperHeight,
      refresh: initSliderTransform,
      destroy: destroy,
      rebuild: function() {
        return tns(extend(options, optionsElements));
      }
    };
  };

  return tns;
  })();

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
      if ($.fn.carousel) {
        $('.carousel').carousel();
      }
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
        const target_val = container.attr('data-target') || container.attr('data-bs-target');
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
   * typeahead.js 0.10.2
   * https://github.com/twitter/typeahead.js
   * Copyright 2013-2014 Twitter, Inc. and other contributors; Licensed MIT
   */

  !function(a){var b={isMsie:function(){return /(msie|trident)/i.test(navigator.userAgent)?navigator.userAgent.match(/(msie |rv:)(\d+(.\d+)?)/i)[2]:!1},isBlankString:function(a){return !a||/^\s*$/.test(a)},escapeRegExChars:function(a){return a.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g,"\\$&")},isString:function(a){return "string"==typeof a},isNumber:function(a){return "number"==typeof a},isArray:a.isArray,isFunction:a.isFunction,isObject:a.isPlainObject,isUndefined:function(a){return "undefined"==typeof a},bind:a.proxy,each:function(b,c){function d(a,b){return c(b,a)}a.each(b,d);},map:a.map,filter:a.grep,every:function(b,c){var d=!0;return b?(a.each(b,function(a,e){return (d=c.call(null,e,a,b))?void 0:!1}),!!d):d},some:function(b,c){var d=!1;return b?(a.each(b,function(a,e){return (d=c.call(null,e,a,b))?!1:void 0}),!!d):d},mixin:a.extend,getUniqueId:function(){var a=0;return function(){return a++}}(),templatify:function(b){function c(){return String(b)}return a.isFunction(b)?b:c},defer:function(a){setTimeout(a,0);},debounce:function(a,b,c){var d,e;return function(){var f,g,h=this,i=arguments;return f=function(){d=null,c||(e=a.apply(h,i));},g=c&&!d,clearTimeout(d),d=setTimeout(f,b),g&&(e=a.apply(h,i)),e}},throttle:function(a,b){var c,d,e,f,g,h;return g=0,h=function(){g=new Date,e=null,f=a.apply(c,d);},function(){var i=new Date,j=b-(i-g);return c=this,d=arguments,0>=j?(clearTimeout(e),e=null,g=i,f=a.apply(c,d)):e||(e=setTimeout(h,j)),f}},noop:function(){}},c="0.10.2",d=function(){function a(a){return a.split(/\s+/)}function b(a){return a.split(/\W+/)}function c(a){return function(b){return function(c){return a(c[b])}}}return {nonword:b,whitespace:a,obj:{nonword:c(b),whitespace:c(a)}}}(),e=function(){function a(a){this.maxSize=a||100,this.size=0,this.hash={},this.list=new c;}function c(){this.head=this.tail=null;}function d(a,b){this.key=a,this.val=b,this.prev=this.next=null;}return b.mixin(a.prototype,{set:function(a,b){var c,e=this.list.tail;this.size>=this.maxSize&&(this.list.remove(e),delete this.hash[e.key]),(c=this.hash[a])?(c.val=b,this.list.moveToFront(c)):(c=new d(a,b),this.list.add(c),this.hash[a]=c,this.size++);},get:function(a){var b=this.hash[a];return b?(this.list.moveToFront(b),b.val):void 0}}),b.mixin(c.prototype,{add:function(a){this.head&&(a.next=this.head,this.head.prev=a),this.head=a,this.tail=this.tail||a;},remove:function(a){a.prev?a.prev.next=a.next:this.head=a.next,a.next?a.next.prev=a.prev:this.tail=a.prev;},moveToFront:function(a){this.remove(a),this.add(a);}}),a}(),f=function(){function a(a){this.prefix=["__",a,"__"].join(""),this.ttlKey="__ttl__",this.keyMatcher=new RegExp("^"+this.prefix);}function c(){return (new Date).getTime()}function d(a){return JSON.stringify(b.isUndefined(a)?null:a)}function e(a){return JSON.parse(a)}var f,g;try{f=window.localStorage,f.setItem("~~~","!"),f.removeItem("~~~");}catch(h){f=null;}return g=f&&window.JSON?{_prefix:function(a){return this.prefix+a},_ttlKey:function(a){return this._prefix(a)+this.ttlKey},get:function(a){return this.isExpired(a)&&this.remove(a),e(f.getItem(this._prefix(a)))},set:function(a,e,g){return b.isNumber(g)?f.setItem(this._ttlKey(a),d(c()+g)):f.removeItem(this._ttlKey(a)),f.setItem(this._prefix(a),d(e))},remove:function(a){return f.removeItem(this._ttlKey(a)),f.removeItem(this._prefix(a)),this},clear:function(){var a,b,c=[],d=f.length;for(a=0;d>a;a++)(b=f.key(a)).match(this.keyMatcher)&&c.push(b.replace(this.keyMatcher,""));for(a=c.length;a--;)this.remove(c[a]);return this},isExpired:function(a){var d=e(f.getItem(this._ttlKey(a)));return b.isNumber(d)&&c()>d?!0:!1}}:{get:b.noop,set:b.noop,remove:b.noop,clear:b.noop,isExpired:b.noop},b.mixin(a.prototype,g),a}(),g=function(){function c(b){b=b||{},this._send=b.transport?d(b.transport):a.ajax,this._get=b.rateLimiter?b.rateLimiter(this._get):this._get;}function d(c){return function(d,e){function f(a){b.defer(function(){h.resolve(a);});}function g(a){b.defer(function(){h.reject(a);});}var h=a.Deferred();return c(d,e,f,g),h}}var f=0,g={},h=6,i=new e(10);return c.setMaxPendingRequests=function(a){h=a;},c.resetCache=function(){i=new e(10);},b.mixin(c.prototype,{_get:function(a,b,c){function d(b){c&&c(null,b),i.set(a,b);}function e(){c&&c(!0);}function j(){f--,delete g[a],l.onDeckRequestArgs&&(l._get.apply(l,l.onDeckRequestArgs),l.onDeckRequestArgs=null);}var k,l=this;(k=g[a])?k.done(d).fail(e):h>f?(f++,g[a]=this._send(a,b).done(d).fail(e).always(j)):this.onDeckRequestArgs=[].slice.call(arguments,0);},get:function(a,c,d){var e;return b.isFunction(c)&&(d=c,c={}),(e=i.get(a))?b.defer(function(){d&&d(null,e);}):this._get(a,c,d),!!e}}),c}(),h=function(){function c(b){b=b||{},b.datumTokenizer&&b.queryTokenizer||a.error("datumTokenizer and queryTokenizer are both required"),this.datumTokenizer=b.datumTokenizer,this.queryTokenizer=b.queryTokenizer,this.reset();}function d(a){return a=b.filter(a,function(a){return !!a}),a=b.map(a,function(a){return a.toLowerCase()})}function e(){return {ids:[],children:{}}}function f(a){for(var b={},c=[],d=0;d<a.length;d++)b[a[d]]||(b[a[d]]=!0,c.push(a[d]));return c}function g(a,b){function c(a,b){return a-b}var d=0,e=0,f=[];for(a=a.sort(c),b=b.sort(c);d<a.length&&e<b.length;)a[d]<b[e]?d++:a[d]>b[e]?e++:(f.push(a[d]),d++,e++);return f}return b.mixin(c.prototype,{bootstrap:function(a){this.datums=a.datums,this.trie=a.trie;},add:function(a){var c=this;a=b.isArray(a)?a:[a],b.each(a,function(a){var f,g;f=c.datums.push(a)-1,g=d(c.datumTokenizer(a)),b.each(g,function(a){var b,d,g;for(b=c.trie,d=a.split("");g=d.shift();)b=b.children[g]||(b.children[g]=e()),b.ids.push(f);});});},get:function(a){var c,e,h=this;return c=d(this.queryTokenizer(a)),b.each(c,function(a){var b,c,d,f;if(e&&0===e.length)return !1;for(b=h.trie,c=a.split("");b&&(d=c.shift());)b=b.children[d];return b&&0===c.length?(f=b.ids.slice(0),void(e=e?g(e,f):f)):(e=[],!1)}),e?b.map(f(e),function(a){return h.datums[a]}):[]},reset:function(){this.datums=[],this.trie=e();},serialize:function(){return {datums:this.datums,trie:this.trie}}}),c}(),i=function(){function d(a){return a.local||null}function e(d){var e,f;return f={url:null,thumbprint:"",ttl:864e5,filter:null,ajax:{}},(e=d.prefetch||null)&&(e=b.isString(e)?{url:e}:e,e=b.mixin(f,e),e.thumbprint=c+e.thumbprint,e.ajax.type=e.ajax.type||"GET",e.ajax.dataType=e.ajax.dataType||"json",!e.url&&a.error("prefetch requires url to be set")),e}function f(c){function d(a){return function(c){return b.debounce(c,a)}}function e(a){return function(c){return b.throttle(c,a)}}var f,g;return g={url:null,wildcard:"%QUERY",replace:null,rateLimitBy:"debounce",rateLimitWait:300,send:null,filter:null,ajax:{}},(f=c.remote||null)&&(f=b.isString(f)?{url:f}:f,f=b.mixin(g,f),f.rateLimiter=/^throttle$/i.test(f.rateLimitBy)?e(f.rateLimitWait):d(f.rateLimitWait),f.ajax.type=f.ajax.type||"GET",f.ajax.dataType=f.ajax.dataType||"json",delete f.rateLimitBy,delete f.rateLimitWait,!f.url&&a.error("remote requires url to be set")),f}return {local:d,prefetch:e,remote:f}}();!function(c){function e(b){b&&(b.local||b.prefetch||b.remote)||a.error("one of local, prefetch, or remote is required"),this.limit=b.limit||5,this.sorter=j(b.sorter),this.dupDetector=b.dupDetector||k,this.local=i.local(b),this.prefetch=i.prefetch(b),this.remote=i.remote(b),this.cacheKey=this.prefetch?this.prefetch.cacheKey||this.prefetch.url:null,this.index=new h({datumTokenizer:b.datumTokenizer,queryTokenizer:b.queryTokenizer}),this.storage=this.cacheKey?new f(this.cacheKey):null;}function j(a){function c(b){return b.sort(a)}function d(a){return a}return b.isFunction(a)?c:d}function k(){return !1}var l,m;return l=c.Bloodhound,m={data:"data",protocol:"protocol",thumbprint:"thumbprint"},c.Bloodhound=e,e.noConflict=function(){return c.Bloodhound=l,e},e.tokenizers=d,b.mixin(e.prototype,{_loadPrefetch:function(b){function c(a){f.clear(),f.add(b.filter?b.filter(a):a),f._saveToStorage(f.index.serialize(),b.thumbprint,b.ttl);}var d,e,f=this;return (d=this._readFromStorage(b.thumbprint))?(this.index.bootstrap(d),e=a.Deferred().resolve()):e=a.ajax(b.url,b.ajax).done(c),e},_getFromRemote:function(a,b){function c(a,c){b(a?[]:f.remote.filter?f.remote.filter(c):c);}var d,e,f=this;return a=a||"",e=encodeURIComponent(a),d=this.remote.replace?this.remote.replace(this.remote.url,a):this.remote.url.replace(this.remote.wildcard,e),this.transport.get(d,this.remote.ajax,c)},_saveToStorage:function(a,b,c){this.storage&&(this.storage.set(m.data,a,c),this.storage.set(m.protocol,location.protocol,c),this.storage.set(m.thumbprint,b,c));},_readFromStorage:function(a){var b,c={};return this.storage&&(c.data=this.storage.get(m.data),c.protocol=this.storage.get(m.protocol),c.thumbprint=this.storage.get(m.thumbprint)),b=c.thumbprint!==a||c.protocol!==location.protocol,c.data&&!b?c.data:null},_initialize:function(){function c(){e.add(b.isFunction(f)?f():f);}var d,e=this,f=this.local;return d=this.prefetch?this._loadPrefetch(this.prefetch):a.Deferred().resolve(),f&&d.done(c),this.transport=this.remote?new g(this.remote):null,this.initPromise=d.promise()},initialize:function(a){return !this.initPromise||a?this._initialize():this.initPromise},add:function(a){this.index.add(a);},get:function(a,c){function d(a){var d=f.slice(0);b.each(a,function(a){var c;return c=b.some(d,function(b){return e.dupDetector(a,b)}),!c&&d.push(a),d.length<e.limit}),c&&c(e.sorter(d));}var e=this,f=[],g=!1;f=this.index.get(a),f=this.sorter(f).slice(0,this.limit),f.length<this.limit&&this.transport&&(g=this._getFromRemote(a,d)),g||(f.length>0||!this.transport)&&c&&c(f);},clear:function(){this.index.reset();},clearPrefetchCache:function(){this.storage&&this.storage.clear();},clearRemoteCache:function(){this.transport&&g.resetCache();},ttAdapter:function(){return b.bind(this.get,this)}}),e}(this);var j={wrapper:'<span class="twitter-typeahead"></span>',dropdown:'<span class="tt-dropdown-menu"></span>',dataset:'<div class="tt-dataset-%CLASS%"></div>',suggestions:'<span class="tt-suggestions"></span>',suggestion:'<div class="tt-suggestion"></div>'},k={wrapper:{position:"relative",display:"inline-block"},hint:{position:"absolute",top:"0",left:"0",borderColor:"transparent",boxShadow:"none"},input:{position:"relative",verticalAlign:"top",backgroundColor:"transparent"},inputWithNoHint:{position:"relative",verticalAlign:"top"},dropdown:{position:"absolute",top:"100%",left:"0",zIndex:"100",display:"none"},suggestions:{display:"block"},suggestion:{whiteSpace:"nowrap",cursor:"pointer"},suggestionChild:{whiteSpace:"normal"},ltr:{left:"0",right:"auto"},rtl:{left:"auto",right:" 0"}};b.isMsie()&&b.mixin(k.input,{backgroundImage:"url(data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7)"}),b.isMsie()&&b.isMsie()<=7&&b.mixin(k.input,{marginTop:"-1px"});var l=function(){function c(b){b&&b.el||a.error("EventBus initialized without el"),this.$el=a(b.el);}var d="typeahead:";return b.mixin(c.prototype,{trigger:function(a){var b=[].slice.call(arguments,1);this.$el.trigger(d+a,b);}}),c}(),m=function(){function a(a,b,c,d){var e;if(!c)return this;for(b=b.split(i),c=d?h(c,d):c,this._callbacks=this._callbacks||{};e=b.shift();)this._callbacks[e]=this._callbacks[e]||{sync:[],async:[]},this._callbacks[e][a].push(c);return this}function b(b,c,d){return a.call(this,"async",b,c,d)}function c(b,c,d){return a.call(this,"sync",b,c,d)}function d(a){var b;if(!this._callbacks)return this;for(a=a.split(i);b=a.shift();)delete this._callbacks[b];return this}function e(a){var b,c,d,e,g;if(!this._callbacks)return this;for(a=a.split(i),d=[].slice.call(arguments,1);(b=a.shift())&&(c=this._callbacks[b]);)e=f(c.sync,this,[b].concat(d)),g=f(c.async,this,[b].concat(d)),e()&&j(g);return this}function f(a,b,c){function d(){for(var d,e=0;!d&&e<a.length;e+=1)d=a[e].apply(b,c)===!1;return !d}return d}function g(){return window.setImmediate?function(a){setImmediate(function(){a();});}:function(a){setTimeout(function(){a();},0);}}function h(a,b){return a.bind?a.bind(b):function(){a.apply(b,[].slice.call(arguments,0));}}var i=/\s+/,j=g();return {onSync:c,onAsync:b,off:d,trigger:e}}(),n=function(a){function c(a,c,d){for(var e,f=[],g=0;g<a.length;g++)f.push(b.escapeRegExChars(a[g]));return e=d?"\\b("+f.join("|")+")\\b":"("+f.join("|")+")",c?new RegExp(e):new RegExp(e,"i")}var d={node:null,pattern:null,tagName:"strong",className:null,wordsOnly:!1,caseSensitive:!1};return function(e){function f(b){var c,d;return (c=h.exec(b.data))&&(wrapperNode=a.createElement(e.tagName),e.className&&(wrapperNode.className=e.className),d=b.splitText(c.index),d.splitText(c[0].length),wrapperNode.appendChild(d.cloneNode(!0)),b.parentNode.replaceChild(wrapperNode,d)),!!c}function g(a,b){for(var c,d=3,e=0;e<a.childNodes.length;e++)c=a.childNodes[e],c.nodeType===d?e+=b(c)?1:0:g(c,b);}var h;e=b.mixin({},d,e),e.node&&e.pattern&&(e.pattern=b.isArray(e.pattern)?e.pattern:[e.pattern],h=c(e.pattern,e.caseSensitive,e.wordsOnly),g(e.node,f));}}(window.document),o=function(){function c(c){var e,f,h,i,j=this;c=c||{},c.input||a.error("input is missing"),e=b.bind(this._onBlur,this),f=b.bind(this._onFocus,this),h=b.bind(this._onKeydown,this),i=b.bind(this._onInput,this),this.$hint=a(c.hint),this.$input=a(c.input).on("blur.tt",e).on("focus.tt",f).on("keydown.tt",h),0===this.$hint.length&&(this.setHint=this.getHint=this.clearHint=this.clearHintIfInvalid=b.noop),b.isMsie()?this.$input.on("keydown.tt keypress.tt cut.tt paste.tt",function(a){g[a.which||a.keyCode]||b.defer(b.bind(j._onInput,j,a));}):this.$input.on("input.tt",i),this.query=this.$input.val(),this.$overflowHelper=d(this.$input);}function d(b){return a('<pre aria-hidden="true"></pre>').css({position:"absolute",visibility:"hidden",whiteSpace:"pre",fontFamily:b.css("font-family"),fontSize:b.css("font-size"),fontStyle:b.css("font-style"),fontVariant:b.css("font-variant"),fontWeight:b.css("font-weight"),wordSpacing:b.css("word-spacing"),letterSpacing:b.css("letter-spacing"),textIndent:b.css("text-indent"),textRendering:b.css("text-rendering"),textTransform:b.css("text-transform")}).insertAfter(b)}function e(a,b){return c.normalizeQuery(a)===c.normalizeQuery(b)}function f(a){return a.altKey||a.ctrlKey||a.metaKey||a.shiftKey}var g;return g={9:"tab",27:"esc",37:"left",39:"right",13:"enter",38:"up",40:"down"},c.normalizeQuery=function(a){return (a||"").replace(/^\s*/g,"").replace(/\s{2,}/g," ")},b.mixin(c.prototype,m,{_onBlur:function(){this.resetInputValue(),this.trigger("blurred");},_onFocus:function(){this.trigger("focused");},_onKeydown:function(a){var b=g[a.which||a.keyCode];this._managePreventDefault(b,a),b&&this._shouldTrigger(b,a)&&this.trigger(b+"Keyed",a);},_onInput:function(){this._checkInputValue();},_managePreventDefault:function(a,b){var c,d,e;switch(a){case"tab":d=this.getHint(),e=this.getInputValue(),c=d&&d!==e&&!f(b);break;case"up":case"down":c=!f(b);break;default:c=!1;}c&&b.preventDefault();},_shouldTrigger:function(a,b){var c;switch(a){case"tab":c=!f(b);break;default:c=!0;}return c},_checkInputValue:function(){var a,b,c;a=this.getInputValue(),b=e(a,this.query),c=b?this.query.length!==a.length:!1,b?c&&this.trigger("whitespaceChanged",this.query):this.trigger("queryChanged",this.query=a);},focus:function(){this.$input.focus();},blur:function(){this.$input.blur();},getQuery:function(){return this.query},setQuery:function(a){this.query=a;},getInputValue:function(){return this.$input.val()},setInputValue:function(a,b){this.$input.val(a),b?this.clearHint():this._checkInputValue();},resetInputValue:function(){this.setInputValue(this.query,!0);},getHint:function(){return this.$hint.val()},setHint:function(a){this.$hint.val(a);},clearHint:function(){this.setHint("");},clearHintIfInvalid:function(){var a,b,c,d;a=this.getInputValue(),b=this.getHint(),c=a!==b&&0===b.indexOf(a),d=""!==a&&c&&!this.hasOverflow(),!d&&this.clearHint();},getLanguageDirection:function(){return (this.$input.css("direction")||"ltr").toLowerCase()},hasOverflow:function(){var a=this.$input.width()-2;return this.$overflowHelper.text(this.getInputValue()),this.$overflowHelper.width()>=a},isCursorAtEnd:function(){var a,c,d;return a=this.$input.val().length,c=this.$input[0].selectionStart,b.isNumber(c)?c===a:document.selection?(d=document.selection.createRange(),d.moveStart("character",-a),a===d.text.length):!0},destroy:function(){this.$hint.off(".tt"),this.$input.off(".tt"),this.$hint=this.$input=this.$overflowHelper=null;}}),c}(),p=function(){function c(c){c=c||{},c.templates=c.templates||{},c.source||a.error("missing source"),c.name&&!f(c.name)&&a.error("invalid dataset name: "+c.name),this.query=null,this.highlight=!!c.highlight,this.name=c.name||b.getUniqueId(),this.source=c.source,this.displayFn=d(c.display||c.displayKey),this.templates=e(c.templates,this.displayFn),this.$el=a(j.dataset.replace("%CLASS%",this.name));}function d(a){function c(b){return b[a]}return a=a||"value",b.isFunction(a)?a:c}function e(a,c){function d(a){return "<p>"+c(a)+"</p>"}return {empty:a.empty&&b.templatify(a.empty),header:a.header&&b.templatify(a.header),footer:a.footer&&b.templatify(a.footer),suggestion:a.suggestion||d}}function f(a){return /^[_a-zA-Z0-9-]+$/.test(a)}var g="ttDataset",h="ttValue",i="ttDatum";return c.extractDatasetName=function(b){return a(b).data(g)},c.extractValue=function(b){return a(b).data(h)},c.extractDatum=function(b){return a(b).data(i)},b.mixin(c.prototype,m,{_render:function(c,d){function e(){return p.templates.empty({query:c,isEmpty:!0})}function f(){function e(b){var c;return c=a(j.suggestion).append(p.templates.suggestion(b)).data(g,p.name).data(h,p.displayFn(b)).data(i,b),c.children().each(function(){a(this).css(k.suggestionChild);}),c}var f,l;return f=a(j.suggestions).css(k.suggestions),l=b.map(d,e),f.append.apply(f,l),p.highlight&&n({node:f[0],pattern:c}),f}function l(){return p.templates.header({query:c,isEmpty:!o})}function m(){return p.templates.footer({query:c,isEmpty:!o})}if(this.$el){var o,p=this;this.$el.empty(),o=d&&d.length,!o&&this.templates.empty?this.$el.html(e()).prepend(p.templates.header?l():null).append(p.templates.footer?m():null):o&&this.$el.html(f()).prepend(p.templates.header?l():null).append(p.templates.footer?m():null),this.trigger("rendered");}},getRoot:function(){return this.$el},update:function(a){function b(b){c.canceled||a!==c.query||c._render(a,b);}var c=this;this.query=a,this.canceled=!1,this.source(a,b);},cancel:function(){this.canceled=!0;},clear:function(){this.cancel(),this.$el.empty(),this.trigger("rendered");},isEmpty:function(){return this.$el.is(":empty")},destroy:function(){this.$el=null;}}),c}(),q=function(){function c(c){var e,f,g,h=this;c=c||{},c.menu||a.error("menu is required"),this.isOpen=!1,this.isEmpty=!0,this.datasets=b.map(c.datasets,d),e=b.bind(this._onSuggestionClick,this),f=b.bind(this._onSuggestionMouseEnter,this),g=b.bind(this._onSuggestionMouseLeave,this),this.$menu=a(c.menu).on("click.tt",".tt-suggestion",e).on("mouseenter.tt",".tt-suggestion",f).on("mouseleave.tt",".tt-suggestion",g),b.each(this.datasets,function(a){h.$menu.append(a.getRoot()),a.onSync("rendered",h._onRendered,h);});}function d(a){return new p(a)}return b.mixin(c.prototype,m,{_onSuggestionClick:function(b){this.trigger("suggestionClicked",a(b.currentTarget));},_onSuggestionMouseEnter:function(b){this._removeCursor(),this._setCursor(a(b.currentTarget),!0);},_onSuggestionMouseLeave:function(){this._removeCursor();},_onRendered:function(){function a(a){return a.isEmpty()}this.isEmpty=b.every(this.datasets,a),this.isEmpty?this._hide():this.isOpen&&this._show(),this.trigger("datasetRendered");},_hide:function(){this.$menu.hide();},_show:function(){this.$menu.css("display","block");},_getSuggestions:function(){return this.$menu.find(".tt-suggestion")},_getCursor:function(){return this.$menu.find(".tt-cursor").first()},_setCursor:function(a,b){a.first().addClass("tt-cursor"),!b&&this.trigger("cursorMoved");},_removeCursor:function(){this._getCursor().removeClass("tt-cursor");},_moveCursor:function(a){var b,c,d,e;if(this.isOpen){if(c=this._getCursor(),b=this._getSuggestions(),this._removeCursor(),d=b.index(c)+a,d=(d+1)%(b.length+1)-1,-1===d)return void this.trigger("cursorRemoved");-1>d&&(d=b.length-1),this._setCursor(e=b.eq(d)),this._ensureVisible(e);}},_ensureVisible:function(a){var b,c,d,e;b=a.position().top,c=b+a.outerHeight(!0),d=this.$menu.scrollTop(),e=this.$menu.height()+parseInt(this.$menu.css("paddingTop"),10)+parseInt(this.$menu.css("paddingBottom"),10),0>b?this.$menu.scrollTop(d+b):c>e&&this.$menu.scrollTop(d+(c-e));},close:function(){this.isOpen&&(this.isOpen=!1,this._removeCursor(),this._hide(),this.trigger("closed"));},open:function(){this.isOpen||(this.isOpen=!0,!this.isEmpty&&this._show(),this.trigger("opened"));},setLanguageDirection:function(a){this.$menu.css("ltr"===a?k.ltr:k.rtl);},moveCursorUp:function(){this._moveCursor(-1);},moveCursorDown:function(){this._moveCursor(1);},getDatumForSuggestion:function(a){var b=null;return a.length&&(b={raw:p.extractDatum(a),value:p.extractValue(a),datasetName:p.extractDatasetName(a)}),b},getDatumForCursor:function(){return this.getDatumForSuggestion(this._getCursor().first())},getDatumForTopSuggestion:function(){return this.getDatumForSuggestion(this._getSuggestions().first())},update:function(a){function c(b){b.update(a);}b.each(this.datasets,c);},empty:function(){function a(a){a.clear();}b.each(this.datasets,a),this.isEmpty=!0;},isVisible:function(){return this.isOpen&&!this.isEmpty},destroy:function(){function a(a){a.destroy();}this.$menu.off(".tt"),this.$menu=null,b.each(this.datasets,a);}}),c}(),r=function(){function c(c){var e,f,g;c=c||{},c.input||a.error("missing input"),this.isActivated=!1,this.autoselect=!!c.autoselect,this.minLength=b.isNumber(c.minLength)?c.minLength:1,this.$node=d(c.input,c.withHint),e=this.$node.find(".tt-dropdown-menu"),f=this.$node.find(".tt-input"),g=this.$node.find(".tt-hint"),f.on("blur.tt",function(a){var c,d,g;c=document.activeElement,d=e.is(c),g=e.has(c).length>0,b.isMsie()&&(d||g)&&(a.preventDefault(),a.stopImmediatePropagation(),b.defer(function(){f.focus();}));}),e.on("mousedown.tt",function(a){a.preventDefault();}),this.eventBus=c.eventBus||new l({el:f}),this.dropdown=new q({menu:e,datasets:c.datasets}).onSync("suggestionClicked",this._onSuggestionClicked,this).onSync("cursorMoved",this._onCursorMoved,this).onSync("cursorRemoved",this._onCursorRemoved,this).onSync("opened",this._onOpened,this).onSync("closed",this._onClosed,this).onAsync("datasetRendered",this._onDatasetRendered,this),this.input=new o({input:f,hint:g}).onSync("focused",this._onFocused,this).onSync("blurred",this._onBlurred,this).onSync("enterKeyed",this._onEnterKeyed,this).onSync("tabKeyed",this._onTabKeyed,this).onSync("escKeyed",this._onEscKeyed,this).onSync("upKeyed",this._onUpKeyed,this).onSync("downKeyed",this._onDownKeyed,this).onSync("leftKeyed",this._onLeftKeyed,this).onSync("rightKeyed",this._onRightKeyed,this).onSync("queryChanged",this._onQueryChanged,this).onSync("whitespaceChanged",this._onWhitespaceChanged,this),this._setLanguageDirection();}function d(b,c){var d,f,h,i;d=a(b),f=a(j.wrapper).css(k.wrapper),h=a(j.dropdown).css(k.dropdown),i=d.clone().css(k.hint).css(e(d)),i.val("").removeData().addClass("tt-hint").removeAttr("id name placeholder").prop("disabled",!0).attr({autocomplete:"off",spellcheck:"false"}),d.data(g,{dir:d.attr("dir"),autocomplete:d.attr("autocomplete"),spellcheck:d.attr("spellcheck"),style:d.attr("style")}),d.addClass("tt-input").attr({autocomplete:"off",spellcheck:!1}).css(c?k.input:k.inputWithNoHint);try{!d.attr("dir")&&d.attr("dir","auto");}catch(l){}return d.wrap(f).parent().prepend(c?i:null).append(h)}function e(a){return {backgroundAttachment:a.css("background-attachment"),backgroundClip:a.css("background-clip"),backgroundColor:a.css("background-color"),backgroundImage:a.css("background-image"),backgroundOrigin:a.css("background-origin"),backgroundPosition:a.css("background-position"),backgroundRepeat:a.css("background-repeat"),backgroundSize:a.css("background-size")}}function f(a){var c=a.find(".tt-input");b.each(c.data(g),function(a,d){b.isUndefined(a)?c.removeAttr(d):c.attr(d,a);}),c.detach().removeData(g).removeClass("tt-input").insertAfter(a),a.remove();}var g="ttAttrs";return b.mixin(c.prototype,{_onSuggestionClicked:function(a,b){var c;(c=this.dropdown.getDatumForSuggestion(b))&&this._select(c);},_onCursorMoved:function(){var a=this.dropdown.getDatumForCursor();this.input.setInputValue(a.value,!0),this.eventBus.trigger("cursorchanged",a.raw,a.datasetName);},_onCursorRemoved:function(){this.input.resetInputValue(),this._updateHint();},_onDatasetRendered:function(){this._updateHint();},_onOpened:function(){this._updateHint(),this.eventBus.trigger("opened");},_onClosed:function(){this.input.clearHint(),this.eventBus.trigger("closed");},_onFocused:function(){this.isActivated=!0,this.dropdown.open();},_onBlurred:function(){this.isActivated=!1,this.dropdown.empty(),this.dropdown.close();},_onEnterKeyed:function(a,b){var c,d;c=this.dropdown.getDatumForCursor(),d=this.dropdown.getDatumForTopSuggestion(),c?(this._select(c),b.preventDefault()):this.autoselect&&d&&(this._select(d),b.preventDefault());},_onTabKeyed:function(a,b){var c;(c=this.dropdown.getDatumForCursor())?(this._select(c),b.preventDefault()):this._autocomplete(!0);},_onEscKeyed:function(){this.dropdown.close(),this.input.resetInputValue();},_onUpKeyed:function(){var a=this.input.getQuery();this.dropdown.isEmpty&&a.length>=this.minLength?this.dropdown.update(a):this.dropdown.moveCursorUp(),this.dropdown.open();},_onDownKeyed:function(){var a=this.input.getQuery();this.dropdown.isEmpty&&a.length>=this.minLength?this.dropdown.update(a):this.dropdown.moveCursorDown(),this.dropdown.open();},_onLeftKeyed:function(){"rtl"===this.dir&&this._autocomplete();},_onRightKeyed:function(){"ltr"===this.dir&&this._autocomplete();},_onQueryChanged:function(a,b){this.input.clearHintIfInvalid(),b.length>=this.minLength?this.dropdown.update(b):this.dropdown.empty(),this.dropdown.open(),this._setLanguageDirection();},_onWhitespaceChanged:function(){this._updateHint(),this.dropdown.open();},_setLanguageDirection:function(){var a;this.dir!==(a=this.input.getLanguageDirection())&&(this.dir=a,this.$node.css("direction",a),this.dropdown.setLanguageDirection(a));},_updateHint:function(){var a,c,d,e,f,g;a=this.dropdown.getDatumForTopSuggestion(),a&&this.dropdown.isVisible()&&!this.input.hasOverflow()?(c=this.input.getInputValue(),d=o.normalizeQuery(c),e=b.escapeRegExChars(d),f=new RegExp("^(?:"+e+")(.+$)","i"),g=f.exec(a.value),g?this.input.setHint(c+g[1]):this.input.clearHint()):this.input.clearHint();},_autocomplete:function(a){var b,c,d,e;b=this.input.getHint(),c=this.input.getQuery(),d=a||this.input.isCursorAtEnd(),b&&c!==b&&d&&(e=this.dropdown.getDatumForTopSuggestion(),e&&this.input.setInputValue(e.value),this.eventBus.trigger("autocompleted",e.raw,e.datasetName));},_select:function(a){this.input.setQuery(a.value),this.input.setInputValue(a.value,!0),this._setLanguageDirection(),this.eventBus.trigger("selected",a.raw,a.datasetName),this.dropdown.close(),b.defer(b.bind(this.dropdown.empty,this.dropdown));},open:function(){this.dropdown.open();},close:function(){this.dropdown.close();},setVal:function(a){this.isActivated?this.input.setInputValue(a):(this.input.setQuery(a),this.input.setInputValue(a,!0)),this._setLanguageDirection();},getVal:function(){return this.input.getQuery()},destroy:function(){this.input.destroy(),this.dropdown.destroy(),f(this.$node),this.$node=null;}}),c}();!function(){var c,d,e;c=a.fn.typeahead,d="ttTypeahead",e={initialize:function(c,e){function f(){var g,h=a(this);b.each(e,function(a){a.highlight=!!c.highlight;}),g=new r({input:h,eventBus:new l({el:h}),withHint:b.isUndefined(c.hint)?!0:!!c.hint,minLength:c.minLength,autoselect:c.autoselect,datasets:e}),h.data(d,g);}return e=b.isArray(e)?e:[].slice.call(arguments,1),c=c||{},this.each(f)},open:function(){function b(){var b,c=a(this);(b=c.data(d))&&b.open();}return this.each(b)},close:function(){function b(){var b,c=a(this);(b=c.data(d))&&b.close();}return this.each(b)},val:function(b){function c(){var c,e=a(this);(c=e.data(d))&&c.setVal(b);}function e(a){var b,c;return (b=a.data(d))&&(c=b.getVal()),c}return arguments.length?this.each(c):e(this.first())},destroy:function(){function b(){var b,c=a(this);(b=c.data(d))&&(b.destroy(),c.removeData(d));}return this.each(b)}},a.fn.typeahead=function(a){return e[a]?e[a].apply(this,[].slice.call(arguments,1)):e.initialize.apply(this,arguments)},a.fn.typeahead.noConflict=function(){return a.fn.typeahead=c,this};}();}(window.jQuery);

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

  var Leaflet_Editable = {exports: {}};

  Leaflet_Editable.exports;

  (function (module, exports) {
  	(function (factory, window) {
  	    /*globals define, module, require*/

  	    // define an AMD module that relies on 'leaflet'
  	    {
  	        module.exports = factory(require$$0__default.default);
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
  	            }	        }

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
  } (Leaflet_Editable, Leaflet_Editable.exports));

  Leaflet_Editable.exports;

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
          new Clipboard__default.default('.copy-email-addresses');
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
        this.sirTrevorIcon = window.sirTrevorIcon;
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
  window.SirTrevor = SirTrevor__default.default;

  Blacklight__default.default.onLoad(function() {
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

      document.addEventListener('turbo:submit-end', (event) => {
        const response = event.detail.fetchResponse;
        if (!response.succeeded && response.response.status === 404) {
          const path = new URL(event.target.action).pathname;
          const deleteButton = document.querySelector(`.contact-email-delete[href="${path}"]`);
          if (deleteButton) {
            const errSpan = deleteButton.closest('.contact').querySelector('.contact-email-delete-error');
            const errorMsg = errSpan.querySelector('.error-msg');
            errSpan.style.display = 'block';
            errorMsg.textContent = 'Not Found';
          }
        }
      });

      if ($.fn.tooltip) {
        $('.btn-with-tooltip').tooltip();
      }

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
      $(window).on('beforeunload page:before-change turbolinks:before-visit turbo:before-visit', function(event) {
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

  (function($, _){
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

  class Pages {
    connect(){
      SirTrevor__default.default.setDefaults({
        iconUrl: Spotlight.sirTrevorIcon,
        uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint'),
        ajaxOptions: {
          headers: {
            'X-CSRF-Token': Spotlight$1.csrfToken() || ''
          },
          credentials: 'same-origin'
        }
      });

      SirTrevor__default.default.Blocks.Heading.prototype.toolbarEnabled = true;
      SirTrevor__default.default.Blocks.Quote.prototype.toolbarEnabled = true;
      SirTrevor__default.default.Blocks.Text.prototype.toolbarEnabled = true;

      var instance = $('.js-st-instance').first();

      if (instance.length) {
        var editor = new SirTrevor__default.default.Editor({
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

  // Blacklight's BookmarkToggle is doing the real work, this only adds/removes the "blacklight-private" class.
  const VisibilityToggle = (e) => {
    if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
      const form = e.target.closest('form');
      if (form) {
        // Add/remove the "private" label to the document row when visibility is toggled
        const docRow = form.closest('tr');
        if (docRow) docRow.classList.toggle('blacklight-private');
      }
    }
  };
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
    SirTrevor__default.default.BlockMixins.Autocompleteable = {
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


    SirTrevor__default.default.Block.prototype.availableMixins.push("autocompleteable");
  })(jQuery);

  (function ($){
    SirTrevor__default.default.BlockMixins.Formable = {
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
            this.setTextBlockHTML(SirTrevor__default.default.toHTML(data.text, this.type));
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


    SirTrevor__default.default.Block.prototype.availableMixins.push("formable");
  })(jQuery);

  (function ($){
    SirTrevor__default.default.BlockMixins.Plustextable = {
      mixinName: "Textable",
      preload: true,

      initializeTextable: function() {
        if (this['formId'] === undefined) {
          this.withMixin(SirTrevor__default.default.BlockMixins.Formable);
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
    

    SirTrevor__default.default.Block.prototype.availableMixins.push("plustextable");
  })(jQuery);

  (function ($){
    Spotlight$1.Block = SirTrevor__default.default.Block.extend({
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
          if (this[mixin] && SirTrevor__default.default.BlockMixins[this.capitalize(mixin)].preload) {
            this.withMixin(SirTrevor__default.default.BlockMixins[this.capitalize(mixin)]);
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
                      <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.title}</div>
                      <div>${(data.slug || data.id)}</div>
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

  SirTrevor__default.default.Blocks.Browse = (function(){

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

  SirTrevor__default.default.Blocks.BrowseGroupCategories = (function(){

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

  SirTrevor__default.default.Blocks.Iframe = (function(){

    return SirTrevor__default.default.Block.extend({
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

  SirTrevor__default.default.Blocks.LinkToSearch = (function(){

    return SirTrevor__default.default.Blocks.Browse.extend({

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

  SirTrevor__default.default.Blocks.Oembed =  (function(){

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

  SirTrevor__default.default.Blocks.FeaturedPages = (function(){

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

  SirTrevor__default.default.Blocks.Rule = (function(){

    return SirTrevor__default.default.Block.extend({
      type: "rule",
      
      title: function() { return i18n.t('blocks:rule:title'); },

      icon_name: "rule",
      
      editorHTML: function() {
        return '<hr />'
      }
    });
  })();

  //= require spotlight/admin/blocks/browse_block

  SirTrevor__default.default.Blocks.SearchResults =  (function(){

    return SirTrevor__default.default.Blocks.Browse.extend({

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

  SirTrevor__default.default.Blocks.SolrDocumentsBase = (function(){

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

  SirTrevor__default.default.Blocks.SolrDocuments = (function(){

    return SirTrevor__default.default.Blocks.SolrDocumentsBase.extend({
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

  SirTrevor__default.default.Blocks.SolrDocumentsCarousel = (function(){

    return SirTrevor__default.default.Blocks.SolrDocumentsBase.extend({
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

  SirTrevor__default.default.Blocks.SolrDocumentsEmbed = (function(){

    return SirTrevor__default.default.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_embed",

      icon_name: "item_embed",

      item_options: function() { return "" },

      afterPreviewLoad: function(options) {
        $(this.inner).find('picture[data-openseadragon]').openseadragon();
      }
    });

  })();

  //= require spotlight/admin/blocks/solr_documents_base_block

  SirTrevor__default.default.Blocks.SolrDocumentsFeatures = (function(){

    return SirTrevor__default.default.Blocks.SolrDocumentsBase.extend({
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

  SirTrevor__default.default.Blocks.SolrDocumentsGrid = (function(){

    return SirTrevor__default.default.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_grid",

      icon_name: "item_grid",


      item_options: function() { return "" }
    });

  })();

  SirTrevor__default.default.Blocks.UploadedItems = (function(){
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
      use.setAttributeNS('https://www.w3.org/1999/xlink', 'href', SirTrevor__default.default.config.defaults.iconUrl + "#" + block.icon_name);
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
      var el = render(SirTrevor__default.default.Blocks, editor.blockManager.blockTypes);

      function hide() {
        var parent = el.parentNode;
        if (!parent) { return; }
        parent.removeChild(el);
        parent.classList.remove("st-block--controls-active");
        return parent;
      }

      function destroy() {
        window.SirTrevor = null;
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
    SirTrevor__default.default.EventBus.on('block:create:new', this.checkBlockTypeLimitOnAdd());
    SirTrevor__default.default.EventBus.on('block:remove', this.checkGlobalBlockTypeLimit());
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
        var block_type = SirTrevor__default.default.Blocks[type].prototype;

        var control = $(editor.blockControls.el).find(".st-block-controls__button[data-type='" + block_type.type + "']");
        control.prop("disabled", !editor.blockManager.canCreateBlock(type));
      });
    };
  };

  SirTrevor__default.default.Locales.en.blocks = $.extend(SirTrevor__default.default.Locales.en.blocks, {
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
