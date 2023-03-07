import UserIndex from 'spotlight/user'
import AdminIndex from 'spotlight/admin'
import Core from 'spotlight/core'

Core.onLoad(() => {
  new UserIndex().connect()
  new AdminIndex().connect()
})

export default Core
