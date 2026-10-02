import Carousel from "spotlight/user/carousel"
import ClearFormButton from "spotlight/user/clear_form_button"
import ZprLinks from "spotlight/user/zpr_links"

export default class {
  connect() {
    new Carousel().connect()
    new ClearFormButton().connect()
    new ZprLinks().connect()
  }
}
