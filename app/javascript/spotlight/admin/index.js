// These scripts are in the vendor directory
import 'nestable'
import 'bootstrap-tagsinput'
import 'typeahead.bundle.min'
import 'leaflet-iiif'
import 'Leaflet.Editable'
import 'Path.Drag'

import AddAnother from 'spotlight/admin/add_another'
import AddNewButton from 'spotlight/admin/add_new_button'
import BlacklightConfiguration from 'spotlight/admin/blacklight_configuration'
import CopyEmailAddress from 'spotlight/admin/copy_email_addresses'
import Croppable from 'spotlight/admin/croppable'
import EditInPlace from 'spotlight/admin/edit_in_place'
import ExhibitTagAutocomplete from 'spotlight/admin/exhibit_tag_autocomplete'
import Exhibits from 'spotlight/admin/exhibits'
import FormObserver from 'spotlight/admin/form_observer'
import Locks from 'spotlight/admin/locks'
import 'spotlight/admin/multi_image_selector'
import Pages from 'spotlight/admin/pages'
import ProgressMonitor from 'spotlight/admin/progress_monitor'
import ReadonlyCheckbox from 'spotlight/admin/readonly_checkbox'
import { addAutocompletetoFeaturedImage } from 'spotlight/admin/search_typeahead'
import SelectRelatedInput from 'spotlight/admin/select_related_input'
import SpotlightNestable from 'spotlight/admin/spotlight_nestable'
import Tabs from 'spotlight/admin/tabs'
import TranslationProgress from 'spotlight/admin/translation_progress'
import 'spotlight/admin/visibility_toggle'
import Users from 'spotlight/admin/users'

import 'spotlight/admin/block_mixins/autocompleteable'
import 'spotlight/admin/block_mixins/formable'
import 'spotlight/admin/block_mixins/plustextable'

import 'spotlight/admin/blocks/block'
import 'spotlight/admin/blocks/resources_block' // This is a base class of several other blocks, so must come first
import 'spotlight/admin/blocks/browse_block'
import 'spotlight/admin/blocks/browse_group_categories_block'
import 'spotlight/admin/blocks/iframe_block'
import 'spotlight/admin/blocks/link_to_search_block'
import 'spotlight/admin/blocks/oembed_block'
import 'spotlight/admin/blocks/pages_block'
import 'spotlight/admin/blocks/rule_block'
import 'spotlight/admin/blocks/search_result_block'
import 'spotlight/admin/blocks/solr_documents_base_block'
import 'spotlight/admin/blocks/solr_documents_block'
import 'spotlight/admin/blocks/solr_documents_carousel_block'
import 'spotlight/admin/blocks/solr_documents_embed_block'
import 'spotlight/admin/blocks/solr_documents_features_block'
import 'spotlight/admin/blocks/solr_documents_grid_block'
import 'spotlight/admin/blocks/uploaded_items_block'

import 'spotlight/admin/sir-trevor/block_controls'
import 'spotlight/admin/sir-trevor/block_limits'
import 'spotlight/admin/sir-trevor/locales'


export default class {
  connect() {
    new AddAnother().connect()
    new AddNewButton().connect()
    new CopyEmailAddress().connect()
    new Croppable().connect()
    new EditInPlace().connect()
    new ExhibitTagAutocomplete().connect()
    new Exhibits().connect()
    new FormObserver().connect()
    new Locks().connect()
    new BlacklightConfiguration().connect()
    new Pages().connect()
    new ProgressMonitor().connect()
    new ReadonlyCheckbox().connect()
    new SelectRelatedInput().connect()
    new Tabs().connect()
    new TranslationProgress().connect()
    new Users().connect()
    addAutocompletetoFeaturedImage()
    SpotlightNestable.init();
  }
}