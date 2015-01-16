# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  
  
  helper Openseadragon::OpenseadragonHelper
  
  include Blacklight::Catalog
  
  before_filter only: :admin do
    blacklight_config.view.admin_table.thumbnail_field = :thumbnail_square_url_ssm
  end
  configure_blacklight do |config|
    
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      qt: 'search',
      fl: '*'
    }
    
    config.default_autocomplete_solr_params = {qf: 'id^1000 title_245_unstem_search^200 title_245_search^100 id_ng^50 full_title_ng^50 all_search'}
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]
    
    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!raw f=id v=$id}' 
    #}
    
    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'display_type'
    config.index.thumbnail_field = :thumbnail_url_ssm
    config.index.square_image_field = :thumbnail_square_url_ssm
    config.index.full_image_field = Spotlight::Engine.config.full_image_field

    config.show.title_field = 'title_full_display'
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]
    config.view.maps.type = "placename_coord"
    config.view.maps.placename_coord_field = 'placename_coords_ssim'

    
    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'
    
    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'format_main_ssim', label: 'Resource type'
    config.add_facet_field 'pub_date', label: 'Date'  
    config.add_facet_field 'language', label: 'Language'
    config.add_facet_field 'author_person_facet', label: 'Author', limit: true
    config.add_facet_field 'topic_facet', label: 'Topic', limit: true
    config.add_facet_field 'geographic_facet', label: 'Region', limit: true
    config.add_facet_field 'era_facet', label: 'Era'  
    config.add_facet_field 'author_other_facet', label: 'Organization (as author)', limit: true
    
    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_index_field "title_variant_display", :label => "Alternate Title"
    config.add_index_field "author_person_full_display", :label => "Author/Creator"
    config.add_index_field "author_corp_display", :label => "Corporate Author"
    config.add_index_field "author_meeting_display", :label => "Meeting Author"
    config.add_index_field "medium", :label => "Medium"
    config.add_index_field "summary_display", :label => "Description"
    config.add_index_field "topic_display", :label => "Topic"
    config.add_index_field "subject_other_display", :label => "Subject"
    config.add_index_field "language", :label => "Language"
    config.add_index_field "physical", :label => "Physical Description"
    config.add_index_field "pub_display", :label => "Publication Info"
    config.add_index_field "pub_date", :label => "Date"
    config.add_index_field "imprint_display", :label => "Imprint"
    
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year (new to old)'
    config.add_sort_field 'pub_date_sort asc, title_sort asc', :label => 'year (old to new)'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'
    
  end
  
end 