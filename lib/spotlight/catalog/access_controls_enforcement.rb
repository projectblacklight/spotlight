module Spotlight::Catalog::AccessControlsEnforcement
  extend ActiveSupport::Concern

  included do
    self.solr_search_params_logic += [:apply_permissive_visibility_filter]
  end

  protected

  def apply_permissive_visibility_filter solr_params, user_params
    return unless current_exhibit

    unless respond_to? :can? and can? :curate, current_exhibit
      solr_params.append_filter_query "-#{Spotlight::SolrDocument.visibility_field(current_exhibit)}:false"
    end

    if Spotlight::Engine.config.filter_resources_by_exhibit
      add_facet_fq_to_solr solr_params, f: current_exhibit.solr_data
    end
  end
end
