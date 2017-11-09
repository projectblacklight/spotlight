//= require spotlight/blocks/browse_block

SirTrevor.Blocks.LinkToSearch = (function(){

  return SirTrevor.Blocks.Browse.extend({

    type: "link_to_search",

    icon_name: 'link_to_search',

    searches_key: "slug",
    view_key: "view",
    plustextable: false,

  });
})();
