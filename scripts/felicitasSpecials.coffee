# Description:
#   Facilitates alcoholism
#
# Commands:
#   woz felicitas specials
#   woz felicitas specials (day of the week)

Cheerio = require("cheerio")
Moment = require("moment")

urlPrefix = "http://www.felicitas.ca/menu-item/"
daysOfTheWeek = ["sunday","monday", "tuesday",
            "wednesday", "thursday", "friday", "saturday"]

module.exports = (robot) ->
  robot.respond /felicitas\s+-?specials\s*(\w+)?/i, (msg) ->
    response = ''
    # optionally provide a day after felicitas specials
    optionalDay = msg.match[1]
    today = (if optionalDay then optionalDay else Moment().format("dddd")).toLowerCase().trim()

    if today in daysOfTheWeek
      url = "#{urlPrefix}#{today}/"
      msg.http(url).get() (err, res, body) ->
        $ = Cheerio.load(body)
        response = $(".single-post-content.post-content").text().trim()
        #there wont be a response on the 404 page but if they decide to add sunday
        #or saturday specials this will still work
        if response
            emoji = ":fork_and_knife::beers:"
            response = "#{emoji} felicitas specials for #{today.toUpperCase()} #{emoji}\n\n#{response}"
        else
          response = "no specials for #{today} :("
        msg.send(response)
    else
      response = "#{today} isnt a day of the week..."
      msg.send(response)
