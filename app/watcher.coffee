request = require 'request'
coffeekup = require 'coffeekup'
CronJob = require('cron').CronJob

log = require './logger'
Notifier = require('./notifier')
Event = require './event'

module.exports = class Watcher
  #api: '(seconds minutes hour day-of-month month day-of-week)'
  #examples:
  # "*/5 * * * * *" => every 5 sec
  # "* * * * * 1-5" => monday to friday
  # "0 0 * * * *" => every hour
  constructor:(config)->
    @notifier = new Notifier(config)

    watch = ()=>
      @watch config, (data)=>
        event = Event.parse(data)
        event.changed @notify if event?

    @job = new CronJob config.schedule, watch, null, true, config.location

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
      events.forEach callback

  notify: (event, origin)->
    title = "Event Changed:: #{event.title}"

    template = ->
      h2 "Event: #{@event.title}"
      ul ->
        for attr in @event.attributes
          if @origin[attr] isnt @event[attr]
            li "#{attr}: #{@origin[attr]} => #{@event[attr]}"

    body = coffeekup.render(template, event: event, origin: origin)

    @notifier.send title, body, (err)->
      log.error("#{err}") if err

      log.info("notify mail sended for #{event.title}")
