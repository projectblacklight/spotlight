import '../../../../vendor/assets/javascripts/parameterize'
import '../../../../vendor/assets/javascripts/jquery.serializejson'
import '../../../../vendor/assets/javascripts/leaflet-iiif'
import '../../../../vendor/assets/javascripts/Leaflet.Editable'
import '../../../../vendor/assets/javascripts/Path.Drag'

import AddAnother from 'add_another'
import AddNewButton from 'add_new_button'
import Appearance from 'appearance'
import BlacklightConfiguration from 'blacklight_configuration'
import CopyEmailAddress from 'copy_email_addresses'
import Croppable from 'croppable'
import EditInPlace from 'edit_in_place'
import ExhibitTagAutocomplete from 'exhibit_tag_autocomplete'
import Exhibits from 'exhibits'
import FormObserver from 'form_observer'
import Locks from 'locks'
import 'multi_image_selector'
import Pages from 'pages'
import ProgressMonitor from 'progress_monitor'
import ReadonlyCheckbox from 'readonly_checkbox'
import { addAutocompletetoFeaturedImage } from 'search_typeahead'
import SelectRelatedInput from 'select_related_input'
import SpotlightNestable from 'spotlight_nestable'
import Tabs from 'tabs'
import TranslationProgress from 'translation_progress'
import 'visibility_toggle'
import Users from 'users'

import 'block_mixins/autocompleteable'
import 'block_mixins/formable'
import 'block_mixins/plustextable'

import 'blocks/block'
import 'blocks/resources_block' // This is a base class of several other blocks, so must come first
import 'blocks/browse_block'
import 'blocks/browse_group_categories_block'
import 'blocks/iframe_block'
import 'blocks/link_to_search_block'
import 'blocks/oembed_block'
import 'blocks/pages_block'
import 'blocks/rule_block'
import 'blocks/search_result_block'
import 'blocks/solr_documents_base_block'
import 'blocks/solr_documents_block'
import 'blocks/solr_documents_carousel_block'
import 'blocks/solr_documents_embed_block'
import 'blocks/solr_documents_features_block'
import 'blocks/solr_documents_grid_block'
import 'blocks/uploaded_items_block'

import 'sir-trevor/block_controls'
import 'sir-trevor/block_limits'
import 'sir-trevor/locales'


export default class {
  connect() {
    new AddAnother().connect()
    new AddNewButton().connect()
    new Appearance().connect()
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