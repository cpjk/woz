# Description:
#   Facilitates alcoholism
#
# Commands:
#   woz felicitas specials

Cheerio = require("cheerio")
Moment = require("moment")

url_prefix = "http://www.felicitas.ca/menu-item/"

today = Moment().format("dddd").toLowerCase()

module.exports = (robot) ->
  robot.respond /felicitas\s+-?specials/i, (msg) ->

    if today in ["monday", "tuesday", "wednesday", "thursday", "friday"]
      url = url_prefix + today + "/"
      msg.http(url).get() (err, res, body) ->
        $ = Cheerio.load(body)
        response = $(".single-post-content.post-content").text().trim()
        response = ":beers: FELICITAS SPECIALS FOR " + today.toUpperCase() + " :beers:" + "\n\n" + response
        msg.send(response)
    else
      response = "No specials for today :("
      msg.send(response)

