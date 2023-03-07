import UserIndex from 'spotlight/user/index'
import AdminIndex from 'spotlight/admin/index'
import Spotlight from 'spotlight/spotlight'

Spotlight.onLoad(() => {
  new UserIndex().connect()
  new AdminIndex().connect()
})

export default Spotlight
