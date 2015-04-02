module.exports = (robot) ->
  robot.hear /[Tt]hanks(,){0,1} [Ww]oz/i, (msg) ->
    msg.send "No problem, chief."
