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
    sender = msg.message.user.name
    responses = [
      "No problem, chief.",
      "Tips are always appreciated...",
      "You don't have to thank me, #{sender}. I'm your loyal servant.",
      "Anytime, #{sender}.",
      "En Taro Adun!"
    ]
    msg.send responses[ Math.floor(Math.random() * responses.length) ]
