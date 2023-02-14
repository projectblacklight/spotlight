import UserIndex from 'user/index'
import AdminIndex from 'admin/index'
import Spotlight from 'spotlight'

Spotlight.onLoad(() => {
  new UserIndex().connect()
  new AdminIndex().connect()
})
