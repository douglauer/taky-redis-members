# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require 'lodash'

etime = require 'english-time'
cache = require 'memory-cache'
crypto = require 'crypto'

module.exports = class Members

  constructor: (opts={}) ->

    opts.redis ?= new (require 'ioredis')(6379,'localhost')
    opts.prefix ?= 'members'
    opts.trim_values ?= yes
    opts.hash_group_names ?= no

    opts.cache_time ?= '10 minutes'
    opts.cache_time = (@_secs opts.cache_time) * 1000

    @opts = opts
    @redis = @opts.redis
    @prefix = @opts.prefix

  add: (group_name,member,cb) ->
    key = [@prefix]

    if @opts.hash_group_names
      key.push @_md5 group_name
    else
      key.push group_name

    if @_type(member) !in ['string','array']
      try member = member.toString()

    if @_type(member) is 'string'
      if @opts.trim_values then member = member.trim()

      cache_key = key.join(':') + member

      if !cache.get(cache_key)
        await @redis.sadd key.join(':'), member, defer e,r
        cache.put cache_key, yes, @opts.cache_time

      return cb e,r if cb

    # add multiple
    else if @_type(member) is 'array'
      m = @redis.multi()

      for x in member
        try x = x.toString()
        if @opts.trim_values then x = x.trim()

        cache_key = key.join(':') + x

        if !cache.get(cache_key)
          m.sadd key.join(':'), x
          cache.put cache_key, yes, @opts.cache_time

      await m.exec defer e,r

      return cb e,r if cb

  list: (group_name,cb) ->
    key = [@prefix]

    if @opts.hash_group_names
      key.push @_md5 group_name
    else
      key.push group_name

    @redis.smembers key.join(':'), cb

  _secs: (str) -> Math.round(etime(str)/1000)

  _md5: (str) ->
    c = crypto.createHash 'md5'
    c.update x 
    c.digest 'hex'

  _type: (obj) ->                                                    
    return no if obj in [undefined,'undefined',null]
    Object::toString.call(obj).slice(8,-1).toLowerCase()

##
if process.env.TAKY_DEV and !module.parent
  log = (x) -> try console.log x

  m = new Members

  m.add 'friends', ['Doug','Chris','Cody'], ->
    m.add 'friends', 'John', ->
      m.list 'friends', (e,friends) ->
        log /friends/
        log friends

        process.exit 1

