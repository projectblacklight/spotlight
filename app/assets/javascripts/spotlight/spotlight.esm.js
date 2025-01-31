import Clipboard from 'clipboard';
import SirTrevor$1 from 'sir-trevor';
import Sortable from 'sortablejs';
import { Controller } from '@hotwired/stimulus';

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
window.SirTrevor = SirTrevor$1;

class Crop {
  constructor(cropArea, preserveAspectRatio = true) {
    this.cropArea = cropArea;
    this.cropArea.data('iiifCropper', this);
    // This element will also have the IIIF input elements contained
    // There may be multiple elements with data-cropper attributes, but
    // there should only one element with this data-cropper attribute value.
    this.cropSelector = '[data-cropper="' + cropArea.data('cropperKey') + '"]';
    this.cropTool = $(this.cropSelector);
    // Exhibit and masthead cropping requires the ratio between image width and height
    // to be consistent, whereas item widget cropping allows any combination of 
    // image width and height.
    this.preserveAspectRatio = preserveAspectRatio;
    // Get the IIIF input elements used to store/reference IIIF information
    this.inputPrefix = this.cropTool.data('input-prefix');
    this.iiifUrlField = this.iiifInputElement(this.inputPrefix, 'iiif_tilesource', this.cropTool);
    this.iiifRegionField = this.iiifInputElement(this.inputPrefix, 'iiif_region', this.cropTool);
    this.iiifManifestField = this.iiifInputElement(this.inputPrefix, 'iiif_manifest_url', this.cropTool);
    this.iiifCanvasField = this.iiifInputElement(this.inputPrefix, 'iiif_canvas_id', this.cropTool);
    this.iiifImageField = this.iiifInputElement(this.inputPrefix, 'iiif_image_id', this.cropTool);
    // Get the closest form element
    this.form = cropArea.closest('form');
    this.tileSource = null;
  }

  // Return the iiif input element based on the fieldname.
  // Multiple input fields with the same name on the page may be related 
  // to a cropper. We thus need to pass in a parent element. 
  iiifInputElement(inputPrefix, fieldName, inputParentElement) {
    return $('input[name="' + inputPrefix + '[' + fieldName + ']"]', inputParentElement);
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

    var cropperOptions = {
      editable: true,
      center: [0, 0],
      crs: L.CRS.Simple,
      zoom: 0
    };

    if(this.preserveAspectRatio) {
      cropperOptions['editOptions'] = {
        rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(this.aspectRatio())
      };
    }

    this.cropperMap = L.map(this.cropArea.attr('id'), cropperOptions);
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
    
    // Not every page which uses this module has autocomplete linked directly to the cropping tool
    if(input.length) {
      var panel = $(input.data('target-panel'));
      addImageSelector(input, panel, this.iiifManifestField.val(), !this.iiifImageField.val());
    }
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
    // This input is currently used for exhibit masthead or thumbnail image upload.
    // The name should be sufficient in this case, as we don't use this part of the
    // code for solr document widgets where we enable cropping. 
    // If we require more specificity, we can scope this to this.cropTool. 
    $('input[name="' + this.inputPrefix + '[upload_id]"]').val(id);
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

class CroppableModal {

  attachModalHandlers() {
    // Attach handler for when modal first loads, to show the cropper
    this.attachModalLoadBehavior();
    // Attach handler for save by checking if clicking in the modal is on a save button
    this.attachModalSaveHandler();
  }

  attachModalLoadBehavior() {
    // Listen for event thrown when modal is displayed with content
    document.addEventListener('loaded.blacklight.blacklight-modal', function(e) {
      var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      
      if(dataCropperDiv) {
        new Crop(dataCropperDiv, false).render();
      }
    });
  }

  // Field names are of the format item[item_0][iiif_image_id]
  iiifInputField(itemIndex, fieldName, parentElement) {
    var itemPrefix = 'item[' + itemIndex + ']';
    var selector = 'input[name="' + itemPrefix + '[' + fieldName + ']"]';
    return $(selector, parentElement);
  }

  attachModalSaveHandler() {
    var context = this;
   
    document.addEventListener('show.blacklight.blacklight-modal', function(e) {
      $('#save-cropping-selection').on('click', () => {
        context.saveCroppedRegion();
      });
    });
  }

  saveCroppedRegion() {
    //On hitting "save changes", we need to copy over the value
    //to the iiif thumbnail url input field as well as the image source itself
    var context = this;
    var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');

    if(dataCropperDiv) {
      var dataCropperKey = dataCropperDiv.data("cropper-key");
      var itemIndex = dataCropperDiv.data("index-id");
      // Get the element on the main edit page whose select image link opened up the modal
      var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
      // Get the hidden input field on the main edit page corresponding to this item
      var thumbnailSaveField = context.iiifInputField(itemIndex, 'thumbnail_image_url', itemElement);
      var fullimageSaveField = context.iiifInputField(itemIndex, 'full_image_url', itemElement);
      var iiifTilesource = context.iiifInputField(itemIndex, 'iiif_tilesource', itemElement).val();
      var regionValue = context.iiifInputField(itemIndex, 'iiif_region', itemElement).val();
      // Extract the region string to incorporate into the thumbnail URL
      var urlPrefix = iiifTilesource.substring(0, iiifTilesource.lastIndexOf('/info.json'));
      var thumbnailUrl = urlPrefix + '/' + regionValue + '/!400,400/0/default.jpg';
      // Set the hidden input value to the thumbnail URL
      // Also set the full image - which is used by widgets like carousel or slideshow
      thumbnailSaveField.val(thumbnailUrl);
      fullimageSaveField.val(urlPrefix + '/' + regionValue + '/!800,800/0/default.jpg');
      // Also change img url for thumbnail image
      var itemImage = $('img.img-thumbnail', itemElement);      
      itemImage.attr('src', thumbnailUrl);
    }
  }
}

class Croppable {
  connect() {
    // For exhibit masthead or thumbnail pages, where
    // the div exists on page load
    $('[data-behavior="iiif-cropper"]').each(function() {
      var cropElement = $(this);
      new Crop(cropElement).render();
    });

    // In the case of individual document thumbnails, selection
    // of the image is through a modal. Here we attach the event
    new CroppableModal().attachModalHandlers();
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

    if (document.getElementById('another-email')) {
      document.addEventListener('turbo:submit-end', this.contactToDeleteNotFoundHandler);
    }

    if ($.fn.tooltip) {
      $('.btn-with-tooltip').tooltip();
    }

    // Put focus in saved search title input when Save this search modal is shown
    $('#save-modal').on('shown.bs.modal', function () {
        $('#search_title').focus();
    });
  }

  contactToDeleteNotFoundHandler(e) {
    const contact = e.detail.formSubmission?.delegate?.element?.querySelector('.contact');
    if (contact && e.detail?.fetchResponse?.response?.status === 404) {
      const error = contact.querySelector('.contact-email-delete-error');
      error.style.display = 'block';
      error.querySelector('.error-msg').textContent = 'Not Found';
    }
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
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    
    fetch(el.dataset.lock, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken
      }
    });
    
    el.removeAttribute('data-lock');
  }

  connect() {
    document.querySelectorAll('[data-lock]').forEach(element => {
      element.addEventListener('click', (e) => {
        this.delete_lock(e.target);
      });
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

const docStore = new Map();

function highlight(value, query) {
  if (query.trim() === '') return value;
  const queryValue = query.trim();
  return queryValue ? value.replace(new RegExp(queryValue, 'gi'), '<strong>$&</strong>') : value;
}

function templateFunc(obj, query) {
  const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : '';
  const privateClass = obj.private ? ' blacklight-private' : '';
  const title = highlight(obj.title, query);
  const description = obj.description ? `<small>&nbsp;&nbsp;${highlight(obj.description, query)}</small>` : '';
  return `<div class="autocomplete-item${privateClass}">${thumbnail}
            <span class="autocomplete-title">${title}</span><br/>${description}
          </div>`;
}

function autoCompleteElementTemplate(obj, query) {
  return `<li role="option" data-autocomplete-value="${obj.id}">${templateFunc(obj, query)}</li>`;
}

function getAutoCompleteElementDataMap(autoCompleteElement) {
  if (!docStore.has(autoCompleteElement.id)) {
    docStore.set(autoCompleteElement.id, new Map());
  }
  return docStore.get(autoCompleteElement.id);
}

async function fetchResult(url) {
  const result = await fetchAutocompleteJSON(url);
  const docs = result.docs || [];
  const query = this.querySelector('input').value || '';
  const autoCompleteElementDataMap = getAutoCompleteElementDataMap(this);
  return docs.map(doc => {
    autoCompleteElementDataMap.set(doc.id, doc);
    return autoCompleteElementTemplate(doc, query);
  }).join('');
}

function addAutocompletetoFeaturedImage(){
  const autocompletePath = $('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path');
  const featuredImageTypeaheads = $('[data-featured-image-typeahead]');
  if (featuredImageTypeaheads.length === 0) return;

  $.each(featuredImageTypeaheads, function(index, autoCompleteInput) {
    const autoCompleteElement = autoCompleteInput.closest('auto-complete');

    autoCompleteElement.setAttribute('src', autocompletePath);
    autoCompleteElement.fetchResult = fetchResult;
    autoCompleteElement.addEventListener('auto-complete-change', e => {
      const data = getAutoCompleteElementDataMap(autoCompleteElement).get(e.relatedTarget.value);
      if (!data) return;

      const inputElement = $(e.relatedTarget);
      const panel = document.querySelector(e.relatedTarget.dataset.targetPanel);
      e.relatedTarget.value = data.title;
      addImageSelector(inputElement, $(panel), data.iiif_manifest, true);
      $(inputElement.data('id-field')).val(data['global_id']);
      inputElement.attr('type', 'text');
    });
  });
}

async function fetchAutocompleteJSON(url) {
  const res = await(fetch(url.toString()));
  if (!res.ok) {
    throw new Error(await res.text());
  }
  return await res.json();
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
  const nestableContainerSelector = '[data-behavior="nestable"]';
  const sortableOptions = {
    animation: 150,
    draggable: '.dd-item',
    handle: '.dd-handle',
    fallbackOnBody: true,
    swapThreshold: 0.65,
    emptyInsertThreshold: 15,
    onStart: onStartHandler,
    onEnd: onEndHandler,
    onMove: onMoveHandler,
  };
  const draggableClass = 'dd-item';
  const nestedSortableClass = 'dd-list';
  const nestedSortableSelector = '.dd-list';
  const nestedSortableNodeName = 'ol';
  const findNode = (id, container) => container.querySelector(`[data-id="${id}"]`);
  const setWeight = (node, weight) => weightField(node).value = weight;
  const setParent = (node, parentId) => parentPageField(node).value = parentId;
  const weightField = node => findProperty(node, "weight");
  const parentPageField = node => findProperty(node, "parent_page");
  const findProperty = (node, property) => node.querySelector(`input[data-property="${property}"]`);
  let nestedId = 0;

  return {
    init: function(nestedContainers) {
      if (nestedContainers === undefined) {
        nestedContainers = document.querySelectorAll(nestableContainerSelector);
      }

      // nestedContainers could be a jQuery selector result, normalize to an array.
      const containersToInit = Array.from(nestedContainers);
      containersToInit.forEach((container) => {
        // Sir Trevor listens for drag and drop events and will error on Sortable events.
        // Don't let them bubble past the Sortable wrapper.
        container.addEventListener('drop', stopPropagationHandler);
      
        const nestedSortables = [
          ...(container.matches(nestedSortableSelector) ? [container] : []),
          ...Array.from(container.querySelectorAll(nestedSortableSelector))
        ];
        const group = `nested-${nestedId++}`;
        
        nestedSortables.forEach(sortable => {
          new Sortable(sortable, { ...sortableOptions, group: group });
        });

        updateWeightsAndRelationships(container);
      });
    }
  };

  function stopPropagationHandler(evt) {
    evt.stopPropagation();
  }

  function onStartHandler(evt) {
    makeEmptyChildSortablesForEligibleParents(getNestableContainer(evt.item), getMaxNestingLevelSetting(evt.item));
  }

  function onEndHandler(evt) {
    const nestableContainer = getNestableContainer(evt.item);
    removeEmptySortables(nestableContainer);
    updateWeightsAndRelationships(nestableContainer);
  }

  function onMoveHandler(evt) {
    // The usage of data-max-depth is one off of the standard notion of depth (# edges to root)
    // E.g., data-max-depth=2 allows for one level of nesting.
    // evt.dragged is a draggable in a Sortable (e.g., a dd-item)
    // evt.to is the Sortable to insert into (e.g., a dd-list)
    const maxAllowedDepth = getMaxNestingLevelSetting(evt.to) - 1;
    const newDepth = getSortableDepth(evt.to) + getHeight(evt.dragged);

    // Be careful here. Returning true is different than returning nothing in SortableJS.
    if (newDepth > maxAllowedDepth) {
      return false;
    }
  }

  // Get the depth of the sortable element from the root container
  function getSortableDepth(sortableElement) {
    const originatingGroup = Sortable.get(sortableElement).options.group.name;
    let depth = 0;
    let parentSortableElement = sortableElement;

    while ((parentSortableElement = parentSortableElement.parentElement.closest(nestedSortableSelector))) {
      const parentSortable = Sortable.get(parentSortableElement);
      if (parentSortable?.options.group.name === originatingGroup) {
        depth++;
      }
    }

    return depth;
  }

  // Find the max child depth in the tree, starting from the draggableElement
  function findMaxDepth(draggableElement) {
    const childSortableElement = draggableElement.querySelector(nestedSortableSelector);
    if (!childSortableElement) {
      return 1;
    }

    const children = childSortableElement.querySelectorAll(`.${draggableClass}`);
    const childDepths = Array.from(children).map(findMaxDepth);
    return 1 + Math.max(0, ...childDepths);
  }

  function getHeight(draggableElement) {
    return findMaxDepth(draggableElement) - 1;
  }

  function getNestableContainer(element) {
    return element.closest(nestableContainerSelector);
  }

  function getMaxNestingLevelSetting(element) {
    return getNestableContainer(element).getAttribute('data-max-depth') || 1;
  }

  // Create empty child sortables for all potential parents as appropriate for the given nesting level
  function makeEmptyChildSortablesForEligibleParents(container, nestingLevel) {
    if (nestingLevel <= 1) {
      return;
    }

    const sortableElement = container.querySelector(nestedSortableSelector);
    const sortable = Sortable.get(sortableElement);
    if (!sortable) {
      return;
    }

    const group = sortable.options.group.name;
    const draggableElements = Array.from(sortableElement.children)
      .filter(child => child.classList.contains(draggableClass));

    draggableElements.forEach(draggableElement => {
      if (!draggableElement.querySelector(nestedSortableSelector)) {
        const emptySortableElement = document.createElement(nestedSortableNodeName);
        emptySortableElement.className = nestedSortableClass;
        draggableElement.appendChild(emptySortableElement);
        new Sortable(emptySortableElement, { ...sortableOptions, group: group });
      }
      makeEmptyChildSortablesForEligibleParents(draggableElement, nestingLevel - 1);
    });
  }

  // Remove any empty sortables within the container. They could be empty lists, which are invalid for accessibility.
  function removeEmptySortables(container) {
    const sortableElements = container.querySelectorAll(nestedSortableSelector);
    sortableElements.forEach(sortableElement => {
      if (sortableElement.innerHTML.trim() === '') {
        const sortable = Sortable.get(sortableElement);
        if (sortable) {
          sortable.destroy();
          sortableElement.remove();
        }
      }
    });
  }

  // Traverse all sortables within a container and update the weight and parent_page inputs
  function updateWeightsAndRelationships(container) {
    const sortableElement = container.matches(nestedSortableSelector) ? container : container.querySelector(nestedSortableSelector);
    const nestingLevelSetting = getMaxNestingLevelSetting(sortableElement);
    const sortable = Sortable.get(sortableElement);
    const stack = [{nodes: sortable.toArray(), parentId: ''}];
    let weight = 0;

    while (stack.length > 0) {
      const {nodes, parentId} = stack.pop();

      nodes.forEach((nodeId) => {
        const node = findNode(nodeId, container);
        setWeight(node, weight++);

        if (nestingLevelSetting > 1) {
          setParent(node, parentId);
          const children = node.querySelector(nestedSortableSelector);
          if (children) {
            const sortableElement = Sortable.get(children);
            stack.push({nodes: sortableElement.toArray(), parentId: nodeId});
          }
        }
      });
    }
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
  SirTrevor.BlockMixins.Autocompleteable = {
    mixinName: "Autocompleteable",
    preload: true,

    initializeAutocompleteable: function() {
      this.on("onRender", this.addAutocompletetoSirTrevorForm);

      if (this['autocomplete_url'] === undefined) {
        this.autocomplete_url = function() { return $('form[data-autocomplete-url]').data('autocomplete-url'); };
      }

      if (this['autocomplete_fetch'] === undefined) {
        this.autocomplete_fetch = this.fetchAutocompleteResults;
      }

      if (this['transform_autocomplete_results'] === undefined) {
        this.transform_autocomplete_results = (val) => val;
      }

      if (this['highlight'] === undefined) {
        this.highlight = function(value) {
          if (!value) return '';
          const queryValue = this.getQueryValue().trim();
          return queryValue ? value.replace(new RegExp(queryValue, 'gi'), '<strong>$&</strong>') : value;
        };
      }

      if (this['autocomplete_control'] === undefined) {
        this.autocomplete_control = function() {
          const autocompleteID = this.autocompleteID();
          return `
          <auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
            <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:autocompleteable:placeholder")}" data-default-typeahead>
            <ul id="${autocompleteID}-popup"></ul>
            <div id="${autocompleteID}-popup-feedback" class="sr-only visually-hidden"></div>
          </auto-complete>
        ` };
      }

      if (this['autocomplete_element_template'] === undefined) {
        this.autocomplete_element_template = function(item) {
          return `<li role="option" data-autocomplete-value="${item.id}">${this.autocomplete_template(item)}</li>`
        };
      }
    },

    queryTokenizer: function(query) {
      return query.trim().toLowerCase().split(/\s+/).filter(Boolean);
    },

    filterResults: function(data, query) {
      const queryStrings = this.queryTokenizer(query);
      return data.filter(item => {
        const lowerTitle = item.title.toLowerCase();
        return queryStrings.some(queryString => lowerTitle.includes(queryString));
      });
    },

    fetchAutocompleteResults: async function(url) {
      const result = await fetchAutocompleteJSON(url);
      const transformed = this.transform_autocomplete_results(result);
      this.fetchedData = {};
      transformed.map(item => this.fetchedData[item.id] = item);
      return transformed.map(item => this.autocomplete_element_template(item)).join('');
    },

    fetchOnceAndFilterLocalResults: async function(url) {
      if (this.fetchedData === undefined) {
        await this.fetchAutocompleteResults(url);
      }
      const query = url.searchParams.get('q');
      const data = Object.values(this.fetchedData);
      const filteredData = query ? this.filterResults(data, query) : data;
      return filteredData.map(item => this.autocomplete_element_template(item)).join('');
    },

    autocompleteID: function() {
      return this.blockID + '-autocomplete';
    },

    getQueryValue: function() {
      const completer = this.inner.querySelector("auto-complete > input");
      return completer.value;
    },

    addAutocompletetoSirTrevorForm: function() {
      const completer = this.inner.querySelector("auto-complete");
      completer.fetchResult = this.autocomplete_fetch.bind(this);
      completer.addEventListener('auto-complete-change', (e) => {
        const data = this.fetchedData[e.relatedTarget.value];
        if (e.relatedTarget.value && data) {
          e.value = e.relatedTarget.value = '';
          this.createItemPanel({ ...data, display: "true" });
        }
      });
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
    show_image_selection: true,
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
    _itemSelectImageLink: function(block_item_id, doc_id, index) {
      // If image selection is not possible for this block, then do not show
      // image selection link
      if (!this.show_image_selection) return ``;
      var url = $('form[data-exhibit-path]').data('exhibit-path') + '/select_image?';
      var markup = `
          <a name="selectimage" href="${url}block_item_id=${block_item_id}&index_id=${index}" data-blacklight-modal="trigger">Select image area</a>
        `;
      return markup;
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
      var block_item_id = this.formId("item_" + data.id);
      var markup = `
          <li class="field dd-item dd3-item" data-cropper="select_image_${block_item_id}" data-resource-id="${resource_id}" data-id="${index}" id="${block_item_id}" data-input-prefix="item[${index}]">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][title]" value="${data.title}" />
            ${this._itemPanelIiifFields(index, data)}
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="d-inline-block">
                      <div class="d-flex">
                        <div class="checkbox">
                          <input name="item[${index}][display]" type="hidden" value="false" />
                          <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                          <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                        </div>
                        <div class="pic">
                          <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                        </div>
                      </div>
                      <div class="d-inline-block">
                        ${this._itemSelectImageLink(block_item_id,data.id, index)}
                      </div>
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
     
    }
  });

})();

SirTrevor.Blocks.Browse = (function(){

  return Spotlight$1.Block.Resources.extend({
    type: "browse",

    icon_name: "browse",

    autocomplete_url: function() {
      return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-searches-path]').dataset.autocompleteExhibitSearchesPath;
    },

    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
    },

    autocomplete_template: function(obj) {
      const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : '';
      const description = obj.description ? `<small>&nbsp;&nbsp;${obj.description}</small>` : '';
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.full_title)}</span>${description}</div>`;
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
           <li class="field dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
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

    autocomplete_control: function() {
      const autocompleteID = this.blockID + '-autocomplete';
      return `<auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
        <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:browse_group_categories:autocomplete")}" data-default-typeahead>
        <ul id="${autocompleteID}-popup"></ul>
        <div id="${autocompleteID}-popup-feedback" class="sr-only visually-hidden"></div>
      </auto-complete>`
    },
    autocomplete_template: function(obj) {
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/></div>`
    },

    autocomplete_url: function() {
      return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-browse-groups-path]').dataset.autocompleteExhibitBrowseGroupsPath;
    },
    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
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
        <li class="field dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
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

    autocomplete_url: function() { return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-pages-path]').dataset.autocompleteExhibitPagesPath; },
    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
    },
    autocomplete_template: function(obj) {
      const description = obj.description ? `<small>&nbsp;&nbsp;${obj.description}</small>` : '';
      const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : '';
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/>${description}</div>`
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
    autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path') },
    autocomplete_template: function(obj) {
      const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : '';
      return `<div class="autocomplete-item${obj.private ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/><small>&nbsp;&nbsp;${this.highlight(obj.description)}</small></div>`
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
      var iiifFields = [
        '<input type="hidden" name="item[' + index + '][thumbnail_image_url]" value="' + (autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][full_image_url]" value="' + (autocomplete_data.full_image_url || autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_tilesource]" value="' + (autocomplete_data.iiif_tilesource) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_manifest_url]" value="' + (autocomplete_data.iiif_manifest_url) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_canvas_id]" value="' + (autocomplete_data.iiif_canvas_id) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_image_id]" value="' + (autocomplete_data.iiif_image_id) + '"/>',
      ];

      // The region input is required for widgets that enable image cropping but not otherwise
      if(this.show_image_selection) {
        iiifFields.push('<input type="hidden" name="item[' + index + '][iiif_region]" value="' + (autocomplete_data.iiif_region || "") + '"/>');
      }

      return iiifFields.join("\n");
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
    show_image_selection: false,

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
    show_image_selection: false,
    
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
          <li class="field dd-item dd3-item" data-id="${index}" id="${this.formId("item_" + dataId)}">
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

class AdminIndex {
  connect() {
    new AddAnother().connect();
    new AddNewButton().connect();
    new CopyEmailAddress().connect();
    new Croppable().connect();
    new EditInPlace().connect();
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

class TagSelectorController extends Controller {

  static targets = [
    'addNewTagWrapper',
    'dropdownContent',
    'initialTags',
    'newTag',
    'searchResultTags',
    'selectedTags',
    'tagControlWrapper',
    'tagSearch',
    'tagsField',
    'tagSearchDropdown',
    'tagSearchInputWrapper'
  ]

  static values = {
    tags: Array,
    translations: Object
  }

  tagDropdown (event) {
    this.dropdownContentTarget.classList.toggle('d-none');
  }

  clickOutside (event) {
    const isShown = !this.dropdownContentTarget.classList.contains('d-none');
    const inSelected = event.target.classList.contains('pill-close');
    const inContainer = this.tagControlWrapperTarget.contains(event.target);
    if (!inContainer && !inSelected && isShown) {
      this.tagDropdown(event);
    }
  }

  handleKeydown (event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      const hidden = this.dropdownContentTarget.classList.contains('d-none');
      if (hidden) return;

      const tagElementToAdd = this.dropdownContentTarget.querySelector('.active')?.firstElementChild;
      if (tagElementToAdd) tagElementToAdd.click();
    }

    if (event.key === ',') {
      event.preventDefault();
      if (this.tagSearchTarget.value.length === 0) return

      if (!this.addNewTagWrapperTarget.classList.contains('d-none')) {
        this.addNewTagWrapperTarget.click();
        this.tagSearchTarget.focus();
        return
      }

      const exactMatch = this.dropdownContentTarget.querySelector('.active')?.firstElementChild;
      if (exactMatch?.checked === false) {
        exactMatch.click();
        this.resetSearch();
      }
      this.tagSearchTarget.focus();
    }
  }

  addNewTag (event) {
    if (this.addNewTagWrapperTarget.classList.contains('d-none') || this.newTagTarget.dataset.tag.length === 0) {
      return
    }

    this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag]);
    this.resetSearch();
  }

  resetSearch() {
    this.tagSearchTarget.value = '';
    this.newTagTarget.innerHTML = '';
    this.newTagTarget.dataset.tag = '';
    this.newTagTarget.disabled = true;
    this.addNewTagWrapperTarget.classList.add('d-none');
    this.searchResultTagsTargets.forEach(target => this.showElement(target.parentElement));
  }

  tagUpdate (event) {
    const target = event.target ? event.target : event;
    if (target.checked) {
      this.tagsValue = this.tagsValue.concat([target.dataset.tag]);
    } else {
      this.tagsValue = this.tagsValue.filter(tag => tag !== target.dataset.tag);
    }
  }

  updateSearchResultsPlaceholder(event) {
    const placeholderElement = this.dropdownContentTarget.querySelector('.no-results');
    if (!placeholderElement) return

    const hasVisibleTags = this.dropdownContentTarget.querySelector('label:not(.d-none):not(.no-results)');
    placeholderElement.classList.toggle('d-none', hasVisibleTags);
  }

  tagCreate(event) {
    event.preventDefault();
    const newTagCheckbox = document.createElement('label');
    newTagCheckbox.innerHTML = `<input type="checkbox" checked data-action="click->${this.identifier}#tagUpdate" data-tag-selector-target="searchResultTags" data-tag="${this.newTagTarget.dataset.tag}"> ${this.newTagTarget.dataset.tag}`;
    const existingTags = Array.from(this.dropdownContentTarget.querySelectorAll('label:not(#add-new-tag-wrapper)'));
    const insertPosition = existingTags.findIndex(tag => tag.textContent.trim().localeCompare(this.newTagTarget.dataset.tag) > 0);
    if (insertPosition === -1) {
      this.addNewTagWrapperTarget.insertAdjacentElement('beforebegin', newTagCheckbox);
    } else {
      existingTags[insertPosition].insertAdjacentElement('beforebegin', newTagCheckbox);
    }

    this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag]);
    this.tagSearchTarget.value = '';
    this.tagSearchTarget.dispatchEvent(new Event('input'));
  }


  tagsValueChanged() {
    const isEmpty = this.tagsValue.length === 0;

    this.selectedTagsTarget.classList.toggle('d-none', isEmpty);
    this.tagSearchInputWrapperTarget.classList.toggle('rounded', isEmpty);
    this.tagSearchInputWrapperTarget.classList.toggle('rounded-bottom', !isEmpty);

    if (!isEmpty) {
      this.selectedTagsTarget.innerHTML = `<ul class="list-unstyled border rounded-top mb-0 p-1 px-2">${this.renderTagPills()}</ul>`;
    }

    const newValue = this.tagsValue.join(', ');
    if (this.tagsFieldTarget.value !== newValue) {
      this.tagsFieldTarget.value = newValue;
    }
  }

  normalizeTag (tag) {
    const normalizeRegex = /[^\w\s]/gi;
    return tag.replace(normalizeRegex, '').toLowerCase().trim()
  }

  showElement (element) {
    element.classList.add('d-block');
    element.classList.remove('d-none');
  }

  hideElement (element) {
    element.classList.remove('d-block');
    element.classList.add('d-none');
  }

  search(event) {
    const searchTerm = this.normalizeTag(event.target.value);
    this.dropdownContentTarget.classList.remove('d-none');

    const exactMatch = this.searchResultTagsTargets.some(target => {
      const compareTerm = this.normalizeTag(target.dataset.tag);
      const isMatch = compareTerm.includes(searchTerm);
      target.parentElement.classList.remove('active');
      this[isMatch ? 'showElement' : 'hideElement'](target.parentElement);
      return compareTerm === searchTerm
    });

    this[searchTerm.length > 0 && !exactMatch ? 'showElement' : 'hideElement'](this.addNewTagWrapperTarget);
    this.addNewTagWrapperTarget.classList.remove('active');
    this.dropdownContentTarget.querySelector('label:not(.d-none)')?.classList.add('active');
  }

  updateTagToAdd (event) {
    const tagAlreadyAdded = this.tagsValue.some(tag =>
      this.normalizeTag(tag) === this.normalizeTag(event.target.value)
    );
    this.newTagTarget.dataset.tag = event.target.value.trim();
    this.newTagTarget.nextSibling.textContent = ` ${this.translationsValue.add_new_tag}: ${event.target.value}`;
    this.newTagTarget.disabled = !this.newTagTarget.dataset.tag.length || tagAlreadyAdded;
  }

  deselect (event) {
    event.preventDefault();

    const clickedTag = event.target.closest('button').dataset.tag;
    const target = this.searchResultTagsTargets.find((tag) => tag.dataset.tag === clickedTag);
    target ? target.click() : this.tagsValue = this.tagsValue.filter(tag => tag !== clickedTag);
  }

  renderTagPills () {
    return this.tagsValue.map((tag) => {
      return `
        <li class="d-inline-flex gap-2 align-items-center my-2">
          <span class="bg-light badge rounded-pill border selected-item d-inline-flex align-items-center text-dark">
            <span class="selected-item-label d-inline-flex">${tag}</span>
            <button
              type="button"
              data-action="${this.identifier}#deselect"
              data-tag="${tag}"
              class="btn-close close ms-1 ml-1"
              aria-label="${this.translationsValue.remove} ${tag}"
            ><span aria-hidden="true" class="visually-hidden">&times;</span></button>
          </span>
        </li>
      `
    }).join('')
  }
}

class SpotlightControllers {
  connect() {
    if (typeof Stimulus === "undefined") return
    Stimulus.register('tag-selector', TagSelectorController);
  }
}

Spotlight$1.onLoad(() => {
  new SpotlightControllers().connect();
  new UserIndex().connect();
  new AdminIndex().connect();
});

export { Spotlight$1 as default };
//# sourceMappingURL=spotlight.esm.js.map
