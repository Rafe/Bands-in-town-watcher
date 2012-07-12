Event = require '../app/event'
redis = require('redis').createClient()
assert = require 'assert'

describe 'Event', ->
  event = ""

  beforeEach ->
    event = new Event(123, "Test @ Test center", "artists", "Test center", "2012-3-4")

  it "parse should parse json to event", ->
    event = Event.parse
      id: 456
      title: "Test"
      artists: [
        name: "coldplay"
      ]
      venue:
        name: "Test center"
      datetime: "2012-3-4"

    event.id.should.equal 456
    event.title.should.equal "Test"
    event.venue.should.equal "Test center"
    event.datetime.should.equal "2012-3-4"

  it "save should save attributes", (done)->
    event.save (event)->
      redis.hgetall event.id, (err, reply)->
        reply.venue.should.equal 'Test center'
        reply.datetime.should.equal '2012-3-4'
        done()

  it "isNew should check existing id in redis and run callback", (done)->
    event.isNew ->
      done()

  it "changed should check attributes changed and run callback", (done)->
    redis.hset event.id, 'title', 'test', (err, reply)->
      event.changed (event, origin)->
        done()

  afterEach (done)->
    redis.del(event.id, done)
