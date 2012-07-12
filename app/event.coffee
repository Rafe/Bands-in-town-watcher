
log = require './logger'

if process.env.REDISTOGO_URL
  rtg = require('url').parse(process.env.REDISTOGO_URL)
  redis = require('redis').createClient(rtg.port, rtg.hostname)
  redis.auth(rtg.auth.split(":")[1])
else
  redis = require('redis').createClient()

class Event
  key: 'id'
  attributes: ['title', 'artists', 'venue', 'datetime']

  constructor:(@id, @title, @artists, @venue, @datetime)->

  save:(callback)->
    for attr in @attributes
      redis.hset @id, attr, @[attr], (err, replies)->
        log.error "#{err}" if err
    callback(@) if callback

  isNew: (callback)->
    redis.exists @id, (err, reply)=>
      log.error "#{err}" if err

      if reply is 0
        callback(@) if callback

  # check the event value is same or not, if not, send email to
  # notify users
  changed: (callback)->
    redis.hgetall @id, (err, reply)=>
      log.error "#{err}" if err
      for attr in @attributes
        if @[attr] isnt reply[attr]
          log.info "event #{@id} changed"
          return callback(@, reply)

Event.parse = (json)->
  new Event(json.id, json.title, JSON.stringify(json.artists), json.venue.name, json.datetime)

module.exports = Event
