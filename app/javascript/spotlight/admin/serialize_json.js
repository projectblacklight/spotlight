// Vanilla JavaScript port of the default behavior of jquery.serializeJSON (v3.2.1).
// Serializes form elements with bracket-notation names (e.g. "item[0][title]")
// into a nested JavaScript object. Accepts a NodeList/array of elements.

var rsubmitterTypes = /^(?:submit|button|image|reset|file)$/i;
var rcheckableType = /^(?:checkbox|radio)$/i;

function splitInputNameIntoKeysArray(name) {
  var keys = name.split("[");
  keys = keys.map(function (key) { return key.replace(/\]/g, ""); });
  if (keys[0] === "") { keys.shift(); }
  return keys;
}

function deepGet(o, keys) {
  if (o === undefined || keys === undefined || keys.length === 0 || typeof o !== "object") {
    return o;
  }
  var key = keys[0];
  if (key === "") return undefined;
  if (keys.length === 1) return o[key];
  return deepGet(o[key], keys.slice(1));
}

function deepSet(o, keys, value) {
  if (keys.length === 0) return;

  var key = keys[0];

  if (keys.length === 1) {
    if (key === "") {
      o.push(value);
    } else {
      o[key] = value;
    }
    return;
  }

  var nextKey = keys[1];
  var tailKeys = keys.slice(1);

  if (key === "") {
    var lastIdx = o.length - 1;
    var lastVal = o[lastIdx];

    if (typeof lastVal === "object" && lastVal !== null && deepGet(lastVal, tailKeys) === undefined) {
      key = lastIdx;
    } else {
      key = lastIdx + 1;
    }
  }

  if (nextKey === "") {
    if (o[key] === undefined || !Array.isArray(o[key])) {
      o[key] = [];
    }
  } else {
    if (o[key] === undefined || typeof o[key] !== "object" || o[key] === null) {
      o[key] = {};
    }
  }

  deepSet(o[key], tailKeys, value);
}

function elementValue(el) {
  var nodeName = el.nodeName.toLowerCase();
  if (nodeName === "select" && el.multiple) {
    var values = [];
    Array.prototype.forEach.call(el.options, function (opt) {
      if (opt.selected) values.push(opt.value);
    });
    return values;
  }
  return el.value;
}

export default function serializeJSON(elements) {
  var data = {};

  Array.prototype.forEach.call(elements, function (el) {
    if (!el.name) return;
    if (el.disabled) return;

    var type = el.type || "";
    var nodeName = el.nodeName.toLowerCase();

    if (nodeName === "input" && rsubmitterTypes.test(type)) return;
    if (rcheckableType.test(type) && !el.checked) return;

    var val = elementValue(el);
    if (val == null) return;

    var assign = function (v) {
      var value = String(v).replace(/\r?\n/g, "\r\n");
      deepSet(data, splitInputNameIntoKeysArray(el.name), value);
    };

    if (Array.isArray(val)) {
      val.forEach(assign);
    } else {
      assign(val);
    }
  });

  return data;
}
