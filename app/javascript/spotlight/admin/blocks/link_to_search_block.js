import SirTrevor from 'sir-trevor'

SirTrevor.Blocks.LinkToSearch = (function(){

  return SirTrevor.Blocks.Browse.extend({

    type: "link_to_search",

    icon_name: 'search_results',

    searches_key: "slug",
    view_key: "view",
    plustextable: false,

  });
})();
