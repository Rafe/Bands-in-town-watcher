Watcher = require '../app/watcher'
CronJob = require('cron').CronJob
Event = require '../app/event'
assert = require 'assert'

describe "Watcher", ->
  watcher = ""
  config =
    app_id: "carnivalmadness"
    artist: "Carnival of Madness"
    schedule: "* * * * * *"
    location: "America/New_York"
    api_version: '2.0'
  beforeEach ->
    watcher = new Watcher(config)

  it "create CronJob", ->
    watcher.job.should.be.an.instanceof(CronJob)

  it "watch bands in town api", (done)->
    count = 0
    watcher.watch config, (event)->
      event.should.have.property('id')
      done() if count++ is 5

  it "send back changed value", (done)->
    event = new Event(123, 'test title', 'test', 'test', 'test')
    event2 = new Event(123, 'test title', 'test2', 'test', 'test')

    watcher.notifier =
      send: (title, body)->
        assert.ok /test title/.test(body)
        assert.ok /artists/.test(body)
        done()

    watcher.notify(event, event2)

  it "notify send email with event", ->
    event = new Event(123, 'test title', 'test', 'test', 'test')
    event2 = new Event(123, 'test title', 'test2', 'test', 'test')

    watcher.notify(event, event2)
