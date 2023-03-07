import BrowseGroupCateogries from 'spotlight/user/browse_group_categories'
import Carousel from 'spotlight/user/carousel'
import ClearFormButton from 'spotlight/user/clear_form_button'
import ReportProblem from 'spotlight/user/report_a_problem'
import ZprLinks from 'spotlight/user/zpr_links'

export default class {
  connect() {
    new BrowseGroupCateogries().connect()
    new Carousel().connect()
    new ClearFormButton().connect()
    new ReportProblem().connect()
    new ZprLinks().connect()
  }
}
