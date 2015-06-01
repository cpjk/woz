# Description:
#   Facilitates alcoholism
#
# Commands:
#   !felicitas specials
#   !felicitas specials (day of the week)

Cheerio = require("cheerio")
Moment = require("moment")

urlPrefix = "http://www.felicitas.ca/menu-item/"
daysOfTheWeek = ["sunday","monday", "tuesday",
            "wednesday", "thursday", "friday", "saturday"]

module.exports = (robot) ->
  robot.respond /felicitas\s+-?specials\s*(\w+)?/i, (msg) ->
    # optionally provide a day after felicitas specials
    optionalDay = msg.match[1]
    chosenDay = (if optionalDay then optionalDay else Moment().format("dddd")).toLowerCase().trim()

    if chosenDay in daysOfTheWeek
      url = "#{urlPrefix}#{chosenDay}/"
      msg.http(url).get() (err, res, body) ->
        $ = Cheerio.load(body)
        response = $(".single-post-content.post-content").text().trim()
        #there wont be a response on the 404 page but if they decide to add sunday
        #or saturday specials, this will still work
        if response
          emoji = ":fork_and_knife::beers:"
          response = "#{emoji} felicitas specials for #{chosenDay.toUpperCase()} #{emoji}\n\n#{response}"
        else
          response = "no specials for #{chosenDay} :("
        msg.send(response)
    else
      response = "#{chosenDay} isnt a day of the week..."
      msg.send(response)
