config = require '../config'
mail = require('mail').Mail
  host: config.host
  username: config.username
  password: config.password

exports.send = (title, body, callback)->
  mail.message
    from: config.username
    to: config.to
    subject: title
    'content-type': 'text/html'
    charset: 'utf-8'
  .body(body).send callback
