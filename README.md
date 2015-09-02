# taky-redis-members

### Example:

`
Members = require 'taky-redis-members'

m = new Members {
  redis: redis_instance
  prefix: 'memberships'
  cache_time: '10 mins'
}

# add each
m.add 'friends', ['Doug','Chris','Cody'], ->

  # add single member
  m.add 'friends', 'John', ->

    m.list 'friends', (e,friends) ->
      console.log /friends/
      console.log friends

      #/friends/
      #[ 'Cody', 'Doug', 'Chris', 'John' ]
`

