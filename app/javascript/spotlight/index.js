import UserIndex from 'spotlight/user'
import AdminIndex from 'spotlight/admin'
import Core from 'spotlight/core'
import { Application } from '@hotwired/stimulus'
import TagSelectorController from './tag_selector_controller'

const application = Application.start()
application.register('tag-selector', TagSelectorController)

Core.onLoad(() => {
  new UserIndex().connect()
  new AdminIndex().connect()
})

export default Core
