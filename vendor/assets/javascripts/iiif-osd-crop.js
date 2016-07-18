/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	// The main wrapper attaches the tool to
	// OpenSeadragon as a constructor. If the
	// programmer wants to initialise it, they
	// call it from the OpenSeadragon instance,
	// or "viewer", similar to a jQuery plugin.

	'use strict';

	var IiifCrop = __webpack_require__(1);

	// We attach the iiifCrop Object to the
	// prototype of the viewer. This makes the
	// method available on each _instance_ of
	// the OpenSeadragon viewer, not the library
	// as a whole.
	//
	// Note that iiifCrop is a factory, not a
	// constructor, so "this" is still accessible
	// as the instance of osd that is called.
	OpenSeadragon.Viewer.prototype.iiifCrop = IiifCrop;


/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var ee =                   __webpack_require__(2),
	    SelectionDOMRenderer = __webpack_require__(17),
	    TransformSelection =   __webpack_require__(22),
	    Selection =            __webpack_require__(24) 

	// This is a factory, not a constructor.
	// The API is designed so that it is only
	// callable from the OSD Viewer instance,
	// so that this will always be that instance.
	var IiifCrop = function(options) {
	  if (!options) { var options = { enabled: true,
	                                  left: 50,
	                                  top: 44,
	                                  right: 250,
	                                  bottom: 144
	                                };
	  }
	  options.osd = this;

	  // options: {
	  // region: [] || {} // Gives selection in image coordinates
	  // animate: true || false // Tells whether to smoothly animate the region when it is forcibly set
	  // enabled: true || false // Should the cropper tool be visible
	  // aspectRatioLocked: true || false // Prevents the region from changing shape
	  // scaleWithCanvas: true || false // false by default, determines how the user selects region
	  //}

	  var dispatcher = ee();

	  var actionConstants = {
	    enable: 'enable',
	    disable: 'disable',
	    expandUp: 'expandUp',
	    expandRight: 'expandRight',
	    expandDown: 'expandDown',
	    expandLeft: 'expandLeft',
	    expandUpAndRight: 'expandUpAndRight',
	    expandDownAndRight: 'expandDownAndRight',
	    expandDownAndLeft: 'expandDownAndLeft',
	    expandUpAndLeft: 'expandUpAndLeft',
	    setRegion: 'setRegion',
	    lockAspectRatio: 'lockAspectRatio',
	    unlockAspectRatio: 'lockAspectRatio',
	    enableAnimation: 'enableAnimation',
	    disableAnimation: 'disableAnimation',
	    enableScaling: 'enableScaling',
	    disableScaling: 'disableScaling'
	  };

	  var settingsStore = {
	    enabled: options.enabled || true,
	    aspectRatioLocked: options.aspectRatioLocked || false,
	    animationEnabled: options.animationEnabled || true
	  };

	  var regionStore = new Selection(options, dispatcher);

	  var renderer = new SelectionDOMRenderer(options, regionStore, settingsStore, dispatcher);
	  renderer.update();

	  this.cropper = {
	    enable: function() {},
	    disable: function() { dispatcher.emit('disable') },

	    // Maps the selected area into an IiifRegion
	    getIiifSelection: function() {
	      return this.getTransformer().toImageRegion(regionStore);
	    },

	    getTransformer: function() {
	      return new TransformSelection(options.osd)
	    },
	    getRegion: function() {},

	    // Given image coordinates, put the crop region in the correct location.
	    setRegion: function(x, y, width, height) {
	      var rect =  { x: x, y: y, height: height, width: width };
	      var region = this.getTransformer().fromImageRegion(rect);
	      regionStore.update(region);
	      renderer.update();
	    },

	    lockAspectRatio: function() {
	      settingsStore.aspectRatioLocked = true;
	    },
	    unlockAspectRatio: function(){
	      settingsStore.aspectRatioLocked = false;
	    },
	    enableAnimation:function() {},
	    disableAnimation: function() {},
	    enableScaling: function() {},
	    disableScaling: function() {},
	    dispatcher: dispatcher
	  };
	};

	module.exports = IiifCrop;


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var d        = __webpack_require__(3)
	  , callable = __webpack_require__(16)

	  , apply = Function.prototype.apply, call = Function.prototype.call
	  , create = Object.create, defineProperty = Object.defineProperty
	  , defineProperties = Object.defineProperties
	  , hasOwnProperty = Object.prototype.hasOwnProperty
	  , descriptor = { configurable: true, enumerable: false, writable: true }

	  , on, once, off, emit, methods, descriptors, base;

	on = function (type, listener) {
		var data;

		callable(listener);

		if (!hasOwnProperty.call(this, '__ee__')) {
			data = descriptor.value = create(null);
			defineProperty(this, '__ee__', descriptor);
			descriptor.value = null;
		} else {
			data = this.__ee__;
		}
		if (!data[type]) data[type] = listener;
		else if (typeof data[type] === 'object') data[type].push(listener);
		else data[type] = [data[type], listener];

		return this;
	};

	once = function (type, listener) {
		var once, self;

		callable(listener);
		self = this;
		on.call(this, type, once = function () {
			off.call(self, type, once);
			apply.call(listener, this, arguments);
		});

		once.__eeOnceListener__ = listener;
		return this;
	};

	off = function (type, listener) {
		var data, listeners, candidate, i;

		callable(listener);

		if (!hasOwnProperty.call(this, '__ee__')) return this;
		data = this.__ee__;
		if (!data[type]) return this;
		listeners = data[type];

		if (typeof listeners === 'object') {
			for (i = 0; (candidate = listeners[i]); ++i) {
				if ((candidate === listener) ||
						(candidate.__eeOnceListener__ === listener)) {
					if (listeners.length === 2) data[type] = listeners[i ? 0 : 1];
					else listeners.splice(i, 1);
				}
			}
		} else {
			if ((listeners === listener) ||
					(listeners.__eeOnceListener__ === listener)) {
				delete data[type];
			}
		}

		return this;
	};

	emit = function (type) {
		var i, l, listener, listeners, args;

		if (!hasOwnProperty.call(this, '__ee__')) return;
		listeners = this.__ee__[type];
		if (!listeners) return;

		if (typeof listeners === 'object') {
			l = arguments.length;
			args = new Array(l - 1);
			for (i = 1; i < l; ++i) args[i - 1] = arguments[i];

			listeners = listeners.slice();
			for (i = 0; (listener = listeners[i]); ++i) {
				apply.call(listener, this, args);
			}
		} else {
			switch (arguments.length) {
			case 1:
				call.call(listeners, this);
				break;
			case 2:
				call.call(listeners, this, arguments[1]);
				break;
			case 3:
				call.call(listeners, this, arguments[1], arguments[2]);
				break;
			default:
				l = arguments.length;
				args = new Array(l - 1);
				for (i = 1; i < l; ++i) {
					args[i - 1] = arguments[i];
				}
				apply.call(listeners, this, args);
			}
		}
	};

	methods = {
		on: on,
		once: once,
		off: off,
		emit: emit
	};

	descriptors = {
		on: d(on),
		once: d(once),
		off: d(off),
		emit: d(emit)
	};

	base = defineProperties({}, descriptors);

	module.exports = exports = function (o) {
		return (o == null) ? create(base) : defineProperties(Object(o), descriptors);
	};
	exports.methods = methods;


/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var assign        = __webpack_require__(4)
	  , normalizeOpts = __webpack_require__(11)
	  , isCallable    = __webpack_require__(12)
	  , contains      = __webpack_require__(13)

	  , d;

	d = module.exports = function (dscr, value/*, options*/) {
		var c, e, w, options, desc;
		if ((arguments.length < 2) || (typeof dscr !== 'string')) {
			options = value;
			value = dscr;
			dscr = null;
		} else {
			options = arguments[2];
		}
		if (dscr == null) {
			c = w = true;
			e = false;
		} else {
			c = contains.call(dscr, 'c');
			e = contains.call(dscr, 'e');
			w = contains.call(dscr, 'w');
		}

		desc = { value: value, configurable: c, enumerable: e, writable: w };
		return !options ? desc : assign(normalizeOpts(options), desc);
	};

	d.gs = function (dscr, get, set/*, options*/) {
		var c, e, options, desc;
		if (typeof dscr !== 'string') {
			options = set;
			set = get;
			get = dscr;
			dscr = null;
		} else {
			options = arguments[3];
		}
		if (get == null) {
			get = undefined;
		} else if (!isCallable(get)) {
			options = get;
			get = set = undefined;
		} else if (set == null) {
			set = undefined;
		} else if (!isCallable(set)) {
			options = set;
			set = undefined;
		}
		if (dscr == null) {
			c = true;
			e = false;
		} else {
			c = contains.call(dscr, 'c');
			e = contains.call(dscr, 'e');
		}

		desc = { get: get, set: set, configurable: c, enumerable: e };
		return !options ? desc : assign(normalizeOpts(options), desc);
	};


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	module.exports = __webpack_require__(5)()
		? Object.assign
		: __webpack_require__(6);


/***/ },
/* 5 */
/***/ function(module, exports) {

	'use strict';

	module.exports = function () {
		var assign = Object.assign, obj;
		if (typeof assign !== 'function') return false;
		obj = { foo: 'raz' };
		assign(obj, { bar: 'dwa' }, { trzy: 'trzy' });
		return (obj.foo + obj.bar + obj.trzy) === 'razdwatrzy';
	};


/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var keys  = __webpack_require__(7)
	  , value = __webpack_require__(10)

	  , max = Math.max;

	module.exports = function (dest, src/*, …srcn*/) {
		var error, i, l = max(arguments.length, 2), assign;
		dest = Object(value(dest));
		assign = function (key) {
			try { dest[key] = src[key]; } catch (e) {
				if (!error) error = e;
			}
		};
		for (i = 1; i < l; ++i) {
			src = arguments[i];
			keys(src).forEach(assign);
		}
		if (error !== undefined) throw error;
		return dest;
	};


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	module.exports = __webpack_require__(8)()
		? Object.keys
		: __webpack_require__(9);


/***/ },
/* 8 */
/***/ function(module, exports) {

	'use strict';

	module.exports = function () {
		try {
			Object.keys('primitive');
			return true;
		} catch (e) { return false; }
	};


/***/ },
/* 9 */
/***/ function(module, exports) {

	'use strict';

	var keys = Object.keys;

	module.exports = function (object) {
		return keys(object == null ? object : Object(object));
	};


/***/ },
/* 10 */
/***/ function(module, exports) {

	'use strict';

	module.exports = function (value) {
		if (value == null) throw new TypeError("Cannot use null or undefined");
		return value;
	};


/***/ },
/* 11 */
/***/ function(module, exports) {

	'use strict';

	var forEach = Array.prototype.forEach, create = Object.create;

	var process = function (src, obj) {
		var key;
		for (key in src) obj[key] = src[key];
	};

	module.exports = function (options/*, …options*/) {
		var result = create(null);
		forEach.call(arguments, function (options) {
			if (options == null) return;
			process(Object(options), result);
		});
		return result;
	};


/***/ },
/* 12 */
/***/ function(module, exports) {

	// Deprecated

	'use strict';

	module.exports = function (obj) { return typeof obj === 'function'; };


/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	module.exports = __webpack_require__(14)()
		? String.prototype.contains
		: __webpack_require__(15);


/***/ },
/* 14 */
/***/ function(module, exports) {

	'use strict';

	var str = 'razdwatrzy';

	module.exports = function () {
		if (typeof str.contains !== 'function') return false;
		return ((str.contains('dwa') === true) && (str.contains('foo') === false));
	};


/***/ },
/* 15 */
/***/ function(module, exports) {

	'use strict';

	var indexOf = String.prototype.indexOf;

	module.exports = function (searchString/*, position*/) {
		return indexOf.call(this, searchString, arguments[1]) > -1;
	};


/***/ },
/* 16 */
/***/ function(module, exports) {

	'use strict';

	module.exports = function (fn) {
		if (typeof fn !== 'function') throw new TypeError(fn + " is not a function");
		return fn;
	};


/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var hasClass = __webpack_require__(18);
	var Move = __webpack_require__(19);
	var Resize = __webpack_require__(20);
	var InteractionEvent = __webpack_require__(21);

	var SelectionDOMRenderer = function(options, state, settings) {
	  var selectionBox,
	      interaction,
	      listener;

	  var canvas = options.osd.canvas;

	  function render(state) {
	    if (!selectionBox) {
	      selectionBox = buildSelectionBox();
	      canvas.appendChild(selectionBox);
	      bindSelectionEvents(selectionBox);
	      update(selectionBox, state);
	    } else {
	      update(selectionBox, state);
	    }
	  }

	  function update(selectionBox, state) {
	    selectionBox.style.left = state.left + 'px';
	    selectionBox.style.top = state.top + 'px';
	    selectionBox.style.width = state.getWidth() + 'px';
	    selectionBox.style.height = state.getHeight() + 'px';
	  }

	  function buildSelectionBox() {
	    var selectionDOM = document.createElement('div');
	      selectionDOM.classList.add('iiif-crop-selection');

	    var handleList = [
	      'iiif-crop-top-drag-handle',
	      'iiif-crop-bottom-drag-handle',
	      'iiif-crop-left-drag-handle',
	      'iiif-crop-right-drag-handle',
	    ];

	    var dragNodeList = [
	      'iiif-crop-top-left-drag-node',
	      'iiif-crop-top-right-drag-node',
	      'iiif-crop-bottom-left-drag-node',
	      'iiif-crop-bottom-right-drag-node'
	    ];

	    handleList.forEach(function(handleName) {
	      var handle = document.createElement('div');
	      handle.classList.add(handleName);
	      handle.classList.add('iiif-crop-dragHandle');
	      selectionDOM.appendChild(handle);
	    });

	    dragNodeList.forEach(function(nodeName) {
	      var dragNode = document.createElement('div');
	      dragNode.classList.add(nodeName);
	      dragNode.classList.add('iiif-crop-dragNode');
	      selectionDOM.appendChild(dragNode);
	    });

	    return selectionDOM;
	  }

	  function bindSelectionEvents(selectionBox) {
	    // Below, stopPropagation() must be
	    // used on the mousedown, mouseup, and
	    // click events to prevent OSD from
	    // receiving them. The "click-to-zoom"
	    // function in OSD is constructed from
	    // the mouseup and mousedown events.
	    selectionBox.addEventListener('click', function(e) {
	      e.stopPropagation();
	      e.preventDefault();
	    });

	    selectionBox.addEventListener('mousedown', handleDragStart);
	    canvas.addEventListener('mouseup', handleDragStop);
	  }

	  function handleDragStop(e) {
	    e.stopPropagation();
	    e.preventDefault();

	    listener = undefined;
	    interaction = undefined;
	    canvas.removeEventListener('mousemove', mouseMoved);
	  }

	  function handleDragStart(event) {
	    event.stopPropagation();
	    event.preventDefault();

	    var currentDragHandle = event.target;
	    if (hasClass(currentDragHandle, 'iiif-crop-selection')) {
	      listener = new Move(state);
	    } else {
	      listener = new Resize(state, currentDragHandle, settings);
	    }
	    canvas.addEventListener('mousemove', mouseMoved);
	  }

	  function mouseMoved(event) {
	    event.stopPropagation();
	    event.preventDefault();

	    interaction = new InteractionEvent(event, canvas, interaction);
	    listener.move(interaction);
	    render(state);
	  }

	  return { update: function() { render(state); }};
	};

	module.exports = SelectionDOMRenderer;


/***/ },
/* 18 */
/***/ function(module, exports) {

	'use strict';

	var hasClass = function(element, selector) {
	    var className = " " + selector + " ";
	    return (" " + element.className + " ").replace(/[\n\t]/g, " ").indexOf(selector) > -1;
	};

	module.exports = hasClass;


/***/ },
/* 19 */
/***/ function(module, exports) {

	'use strict';
	var Move = function(state) {
	  this.state = state;
	}

	Move.prototype = {
	  move: function(interactionEvent) {
	    if (interactionEvent.hasMoved()) {
	      var newState = {
	        left: this.state.left - interactionEvent.dx,
	        top: this.state.top - interactionEvent.dy,
	        right: this.state.right - interactionEvent.dx,
	        bottom: this.state.bottom - interactionEvent.dy
	      };
	      this.state.update(newState);
	    }
	  }
	}

	module.exports = Move;


/***/ },
/* 20 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var hasClass = __webpack_require__(18);

	var Resize = function(state, currentDragHandle, settings) {
	  function getActiveEdges(handle) {
	    var edges = { top: false, left: false, bottom: false, right: false }
	    if (hasClass(handle, 'iiif-crop-top-drag-handle')) {
	      edges.top = true
	    } else if (hasClass(handle, 'iiif-crop-right-drag-handle')) {
	      edges.right = true
	    } else if (hasClass(handle, 'iiif-crop-bottom-drag-handle')) {
	      edges.bottom = true
	    } else if (hasClass(handle, 'iiif-crop-left-drag-handle')) {
	      edges.left = true
	    } else if (hasClass(handle, 'iiif-crop-top-left-drag-node')) {
	      edges.left = true
	      edges.top = true
	    } else if (hasClass(handle, 'iiif-crop-top-right-drag-node')) {
	      edges.right = true
	      edges.top = true
	    } else if (hasClass(handle, 'iiif-crop-bottom-right-drag-node')) {
	      edges.right = true
	      edges.bottom = true
	    } else if (hasClass(handle, 'iiif-crop-bottom-left-drag-node')) {
	      edges.left = true
	      edges.bottom = true
	    }
	    return edges
	  }

	  this.originalEdges = getActiveEdges(currentDragHandle)
	  this.startAspectRatio = state.getWidth() / state.getHeight()
	  this.aspectRatioLocked = settings.aspectRatioLocked
	  this.state = state
	}

	Resize.prototype = {
	  move: function(interactionEvent) {
	    var newState = {}

	    var dy = interactionEvent.dy
	    var dx = interactionEvent.dx
	    var activeEdges = { top: this.originalEdges.top,
	                        right: this.originalEdges.right,
	                        left: this.originalEdges.left,
	                        bottom: this.originalEdges.bottom };

	    if (this.aspectRatioLocked) {
	      if (this.originalEdges.left && this.originalEdges.top) {
	        dx = dy * this.startAspectRatio;
	      } else if (this.originalEdges.right && this.originalEdges.top) {
	        dx = -dy * this.startAspectRatio;
	      } else if (this.originalEdges.left) {
	        activeEdges.bottom = true
	        dy = -dx / this.startAspectRatio;
	      } else if (this.originalEdges.right) {
	        activeEdges.bottom = true
	        dy = dx / this.startAspectRatio;
	      } else if (this.originalEdges.top) {
	        activeEdges.right = true
	        dx = -dy * this.startAspectRatio;
	      } else if (this.originalEdges.bottom) {
	        activeEdges.right = true
	        dx = dy * this.startAspectRatio;
	      }
	    }

	    if (activeEdges.top)
	      newState.top = this.state.top - dy
	    if (activeEdges.right)
	      newState.right = this.state.right - dx
	    if (activeEdges.left)
	      newState.left = this.state.left - dx
	    if (activeEdges.bottom)
	      newState.bottom = this.state.bottom - dy

	    this.state.update(newState)
	  }
	}

	module.exports = Resize;


/***/ },
/* 21 */
/***/ function(module, exports) {

	'use strict';

	var InteractionEvent = function(event, canvas, prevInteraction) {
	  this.mousePosition = {
	    x: event.clientX - canvas.getBoundingClientRect().left,
	    y: event.clientY - canvas.getBoundingClientRect().top
	  };

	  if (typeof(prevInteraction) !== 'undefined') {
	    // copying prevInteraction.mousePosition here so that we don't hold a
	    // reference to prevInteraction which could lead to a memory leak
	    this.dx = prevInteraction.mousePosition.x - this.mousePosition.x;
	    this.dy = prevInteraction.mousePosition.y - this.mousePosition.y;
	  }
	};

	InteractionEvent.prototype = {
	  hasMoved: function() {
	    return typeof(this.dx) !== 'undefined';
	  }
	};

	module.exports = InteractionEvent;


/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var IiifRegion = __webpack_require__(23)

	var TransformSelection = function(osdCanvas) {
	  this.osdCanvas = osdCanvas;
	}

	TransformSelection.prototype = {
	  // Transform a web coordinate into an image coordinate
	  coordinateForPixel: function(x, y) {
	    var pixel = new OpenSeadragon.Point(x, y);
	    var view_point = this.osdCanvas.viewport.pointFromPixel(pixel);
	    var image_point = this.osdCanvas.viewport.viewportToImageCoordinates(view_point)
	    // For some reason these points are floats. Convert to ints:
	    return { x: Math.round(image_point.x), y: Math.round(image_point.y) }
	  },

	  // Map a rectangle defined in web coordinates to image coordinates
	  toImageRegion: function(selection) {
	    var x = Math.round(selection.left);
	    var y = Math.round(selection.top);
	    var top_left = this.coordinateForPixel(x, y);
	    var bottom_right = this.coordinateForPixel(selection.right, selection.bottom);

	    return new IiifRegion({ x:           top_left.x,
	                            y:           top_left.y,
	                            height:      bottom_right.y - top_left.y,
	                            width:       bottom_right.x - top_left.x,
	                            serviceBase: this.osdCanvas.source['@id']
	                           });
	  },

	  pixelForCoordinate: function(x, y) {
	    var view_coord = this.osdCanvas.viewport.imageToViewportCoordinates(x, y);
	    return this.osdCanvas.viewport.pixelFromPoint(view_coord);
	  },

	  // Map a rectangle defined in image coordinates to web coordinates
	  // TODO Should this return a Selection instance?
	  fromImageRegion: function(image_region) {
	    var x1 = image_region.x;
	    var y1 = image_region.y;
	    var x2 = image_region.x + image_region.width;
	    var y2 = image_region.y + image_region.height;
	    var top_left = this.pixelForCoordinate(x1, y1)
	    var bottom_right = this.pixelForCoordinate(x2, y2)
	    return { left:      top_left.x,
	             top:      top_left.y,
	             bottom: bottom_right.y,
	             right:  bottom_right.x,
	           };
	  }
	}

	module.exports = TransformSelection;


/***/ },
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var ee = __webpack_require__(2);

	var IiifRegion = function(options, dispatcher) {
	  this.serviceBase = options.serviceBase;
	  this.x = 0 || options.x;
	  this.y = 0 || options.y;
	  this.width = 0 || options.width;
	  this.height = 0 || options.height;
	};

	// The purpose of this component is to
	// extract a IIIF url for a cropped
	// region of an image, from an OpenSeadragon
	// instance.

	// So the core data structure is just the region
	// selected. The region must be able to be
	// be retrieved as a url with a specified
	// size, rotation, etc.

	// When the region is updated, the dom
	// element representing the selection
	// must be updated.

	// There are 8 ways to transform the selection
	// through the UI, and 9 ways to transform
	// the selection total (sizing).

	// The programmer must be able to listen for
	// changes in the dimensions, the creation
	// of the region, and the cancelation of
	// the region.

	IiifRegion.prototype = {
	  x: function() {}, // getter/setter
	  y: function() {}, // getter/setter
	  width: function() {}, // getter/setter
	  height: function() {},

	  getRegion: function() {
	    return [this.x, this.y, this.width, this.height];
	  },

	  getUrl: function(opts) {
	    opts = opts || {};
	    var rotation = opts.rotation || 0;
	    var scale = opts.scale || 'full';
	    var quality = opts.quality || 'default';
	    var format = opts.format || 'jpg';
	    return this.serviceBase + '/' + this.getRegion() + '/' + scale + '/' + rotation + '/' + quality + '.' + format;
	  }
	};

	module.exports = IiifRegion;


/***/ },
/* 24 */
/***/ function(module, exports) {

	'use strict';

	var Selection = function(options, dispatcher) {
	  this.top = 0 || options.top;
	  this.left = 0 || options.left;
	  this.right = 0 || options.right;
	  this.bottom = 0 || options.bottom;
	};

	// This models the selected region.

	// When the region is updated, the dom
	// element representing the selection
	// must be updated.

	// There are 8 ways to transform the selection
	// through the UI, and 9 ways to transform
	// the selection total (sizing).

	// The programmer must be able to listen for
	// changes in the dimensions, the creation
	// of the region, and the cancelation of
	// the region.

	Selection.prototype = {
	  top: function() {}, // getter/setter
	  left: function() {}, // getter/setter
	  right: function() {}, // getter/setter
	  bottom: function() {},
	  update: function(options) {
	    if (options.left)
	      this.left = options.left;
	    if (options.top)
	      this.top = options.top;
	    if (options.right)
	      this.right = options.right;
	    if (options.bottom)
	      this.bottom = options.bottom;
	  },
	  getWidth: function () {
	    return this.right - this.left;
	  },
	  getHeight: function () {
	    return this.bottom - this.top;
	  }
	};

	module.exports = Selection;


/***/ }
/******/ ]);