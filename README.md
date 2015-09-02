# taky-redis-members

# install

using [npm](https://npmjs.org)

```
npm i taky-redis-members --save
```

# example

``` coffeescript
Members = require 'taky-redis-members'

m = new Members {
  redis: redis_instance
  prefix: 'memberships'
  cache_time: '10 mins'
}

# add multi
m.add 'friends', ['Doug','Chris','Cody'], ->

  # add one
  m.add 'friends', 'John', ->

    # get list
    m.list 'friends', (e,friends) ->
      console.log /friends/
      console.log friends

      #/friends/
      #[ 'Cody', 'Doug', 'Chris', 'John' ]
```


