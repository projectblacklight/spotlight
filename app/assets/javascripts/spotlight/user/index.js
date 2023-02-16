//= require spotlight/spotlight
//= require bootstrap/util
//= require bootstrap/tab
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require bootstrap/carousel
//= require tiny-slider
//= require_tree .

Spotlight.onLoad(() => {
  new spotlightUserAnalytics().connect()
  new spotlightUserBrowse_group_categories().connect()
  new spotlightUserCarousel().connect()
  new spotlightUserClear_form_button().connect()
  new spotlightUserReport_a_problem().connect()
  new spotlightUserZpr_links().connect()
})