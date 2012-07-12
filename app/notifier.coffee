config = require '../config'
Mail = require('mail').Mail

module.exports = class Notifier
  constructor: (@config)->
    @mailer = Mail
      host: @config.host
      username: @config.username
      password: @config.password

  send: (title, body, callback)->
    @mailer.message
      from: @config.username
      to: @config.to
      subject: title
      'content-type': 'text/html'
      charset: 'utf-8'
    .body(body).send callback
