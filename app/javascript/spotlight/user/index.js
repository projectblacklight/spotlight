import Analytics from 'analytics'
import BrowseGroupCateogries from 'browse_group_categories'
import Carousel from 'carousel'
import ClearFormButton from 'clear_form_button'
import ReportProblem from 'report_a_problem'
import ZprLinks from 'zpr_links'

export default class {
  connect() {
    new Analytics().connect()
    new BrowseGroupCateogries().connect()
    new Carousel().connect()
    new ClearFormButton().connect()
    new ReportProblem().connect()
    new ZprLinks().connect()
  }
}