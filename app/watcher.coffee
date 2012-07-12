request = require 'request'
Event = require './event'
log = require './logger'
Notifier = require('./notifier')
config = require '../config'
ck = require 'coffeekup'

CronJob = require('cron').CronJob

class Watcher
  #api: '(seconds minutes hour day-of-month month day-of-week)'
  #examples:
  # "*/5 * * * * *" => every 5 sec
  # "* * * * * 1-5" => monday to friday
  # "0 0 * * * *" => every hour
  constructor:(config)->
    watch = ()=>
      @watch config, @checkChange
    @job = new CronJob config.schedule, watch, null, true, config.location
    @notifier = new Notifier(config)

  start: ->
    @job.start()

  watch:(config, callback)=>
    artist = encodeURIComponent(config.artist)
    url = "http://api.bandsintown.com/artists/#{artist}/events.json"
    params =
      'format': 'json'
      'api_version': config.api_version
      'app_id': config.app_id

    log.info "checking bands in town events: #{url}"

    request.get url, qs: params, (err, res, body)->
      log.error "#{err}" if err

      events = JSON.parse(body)
      for event in events
        callback(event)

  checkChange:(raw_event)->
    event = Event.parse(raw_event)

    return unless event?

    event.isNew ()->
      event.save (event)->
        log.info "saved #{event.id}"

    event.changed (event, original)=>
      log.debug "event changed: #{event.id}"
      event.save()
      @notify(event, original)

  notify: (event, original)->
    title = "Event Changed:: #{event.title}"

    template = ->
      h2 "Event: #{@event.title}"
      ul ->
        for attr in @event.attributes
          if @original[attr] isnt @event[attr]
            li "#{attr}: #{@original[attr]} => #{@event[attr]}"

    body = ck.render(template, event: event, original: original)

    @notifier.send title, body, (err)->
      log.error("#{err}") if err

      log.info("notify mail sended for #{event.title}")

module.exports = Watcher
