import UserIndex from 'spotlight/user'
import AdminIndex from 'spotlight/admin'
import Core from 'spotlight/core'
import SpotlightControllers from 'spotlight/controllers'

Core.onLoad(() => {
  new SpotlightControllers().connect()
  new UserIndex().connect()
  new AdminIndex().connect()
})

export default Core
