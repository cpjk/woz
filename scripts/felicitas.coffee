# Description:
#   Facilitates alcoholism
#
# Commands:
#   !felicitas - beers

Cheerio = require("cheerio")

url = "http://www.felicitas.ca/menu/on-tap/"

module.exports = (robot) ->
  robot.respond /felicitas\s+-?beers?/i, (msg) ->
    msg.http(url).get() (err, res, body) ->
      $ = Cheerio.load(body)
      beers = $("article").map () ->
        return $(this).text().trim().replace(/\s+/g, " ")

      response = "Felicitas beer prices :beers:\n\n" + beers.get().join('\n')
      msg.send(response)
