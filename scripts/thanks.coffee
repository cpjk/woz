# Description:
#   Says thanks
#
# Commands:
#   thanks woz
#   thanks, woz
#   thank you woz
#   thank you, woz

module.exports = (robot) ->
  robot.hear /thank(s,?|\s+you,?)\s+woz/i, (msg) ->
    msg.send "No problem, chief."
