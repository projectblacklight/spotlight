import BrowseGroupCateogries from 'spotlight/user/browse_group_categories'
import Carousel from 'spotlight/user/carousel'
import ClearFormButton from 'spotlight/user/clear_form_button'
import ZprLinks from 'spotlight/user/zpr_links'

export default class {
  connect() {
    new BrowseGroupCateogries().connect()
    new Carousel().connect()
    new ClearFormButton().connect()
    new ZprLinks().connect()
  }
}
