# Description:
#   Facilitates alcoholism
#
# Commands:
#   woz felicitas lineup
#   woz felicitas shows

Cheerio = require("cheerio")

url = "http://www.felicitas.ca/upcoming-events/"

module.exports = (robot) ->
  robot.respond /felicitas\s+(events|shows)/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      $ = Cheerio.load(body)
      events = $("article").map () ->
        event = $(this).text().trim().replace /\s+/g, " "
        event.replace(
          /(\d{2})\.(\d{2})\.(\d{4})/,
          (match, day, month, year) =>
            (new Date(year, month-1, day)).toDateString() + ', ' 
        )
      response = "Felicitas Upcoming Events:\n\n" + events.get().join '\n'
      msg.send(response)
