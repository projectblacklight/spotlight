//= require eventable
//= require sir-trevor
//= require nestable
//= require parameterize
//= require bootstrap-tagsinput
//= require jquery.serializejson
//= require clipboard
//= require leaflet
//= require leaflet-iiif
//= require Leaflet.Editable
//= require Path.Drag

//= require polyfill.min.js
//= require_tree .

Spotlight.onLoad(() => {
  new spotlightAdminAdd_another().connect()
  new spotlightAdminAdd_new_button().connect()
  new spotlightAdminAppearance().connect()
  new spotlightAdminCopy_email_addresses().connect()
  new spotlightAdminCroppable().connect()
  new spotlightAdminEdit_in_place().connect()
  new spotlightAdminExhibit_tag_autocomplete().connect()
  new spotlightAdminExhibits().connect()
  new spotlightAdminForm_observer().connect()
  new spotlightAdminLocks().connect()
  new spotlightAdminBlacklight_configuration().connect()
  new spotlightAdminPages().connect()
  new spotlightAdminProgress_monitor().connect()
  new spotlightAdminReadonly_checkbox().connect()
  new spotlightAdminSelect_related_input().connect()
  new spotlightAdminTabs().connect()
  new spotlightAdminTranslation_progress().connect()
  new spotlightAdminUsers().connect()
})
