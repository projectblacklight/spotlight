import UserIndex from 'spotlight/user'
import AdminIndex from 'spotlight/admin'
import Spotlight from 'spotlight/spotlight'

Spotlight.onLoad(() => {
  new UserIndex().connect()
  new AdminIndex().connect()
})

export default Spotlight
