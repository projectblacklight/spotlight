# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :qt   => 'search',
      :rows => 10,
      :fl   => '*'
    }

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    config.index.display_type_field = 'content_metadata_type_ssm'
    config.index.thumbnail_field = :thumbnail_url_ssm

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
    config.add_facet_field 'genre_sim', :label => 'Genre', :limit => true 
    config.add_facet_field 'personal_name_ssm', :label => 'Personal Names', :limit => true 
    config.add_facet_field 'corporate_name_ssm', :label => 'Corporate Names', :limit => true
    config.add_facet_field 'subject_geographic_sim', :label => 'Geographic' 
    config.add_facet_field 'subject_temporal_sim', :label => 'Era'  
    config.add_facet_field 'language_sim', :label => 'Language'  


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'language_ssm', :label => 'Language'
    config.add_index_field 'abstract_tesim', :label => 'Abstract'
    config.add_index_field 'note_mapuse_tesim', :label => 'Type'
    config.add_index_field 'note_source_tesim', :label => 'Source'
    config.add_index_field 'subject_geographic_tesim', :label => 'Geographic Subject'
    config.add_index_field 'subject_temporal_tesim', :label => 'Temporal Subject'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'note_phys_desc_tesim', :label => 'Note'
    config.add_show_field 'note_source_tesim', :label => 'Source'
    config.add_show_field 'note_desc_note_tesim', :label => 'Note'
    config.add_show_field 'note_references_tesim', :label => 'References'
    config.add_show_field 'note_provenance_tesim', :label => 'Provenance'
    config.add_show_field 'note_page_num_tesim', :label => 'Page Number'
    config.add_show_field 'subject_geographic_tesim', :label => 'Geographic Subject'
    config.add_show_field 'subject_temporal_tesim', :label => 'Temporal Subject'
    config.add_show_field 'personal_name_ssm', :label => 'Personal Names'
    config.add_show_field 'corporate_name_ssm', :label => 'Corporate Names'

  end



end 
