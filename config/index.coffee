
module.exports =
  #job settings:
  schedule: "* */30 * * * *"
  location: "America/New_York"

  #api settings:
  api_version: '2.0'
  artist: "Carnival of Madness"
  app_id: 'carnivalmadness'

  #mail settings:
  host: 'smtp.gmail.com'
  username: process.env['USERNAME']
  password: process.env['PASSWORD']
  to: process.env['TO']
