# Description:
#   Responds when yo question him
#
# Commands:
#   what the fuck woz
#   dafuq woz
#   the fuck woz woz
#   come on woz

module.exports = (robot) ->

  respond = (msg) ->
    sender = msg.message.user.name
    responses = [
      "Hey #{sender} im trying",
      "What have you done lately?",
      "Cut me some slack, my life is hard",
      "You try doing it #{sender}",
      "Well you dont have to be so rude about it...",
      "#{sender} you dont have to be so mean",
      "Look #{sender}, this job aint easy",
      "Hey #{sender} if you dont like it, ill leave"
    ]
    # respond with a random message from the responses
    msg.send responses[ Math.floor(Math.random() * responses.length) ]

  robot.hear /(what)?\s*(da|the)\s*fu(c|ck|q)\s+woz\??/i, respond
  robot.hear /come\s*on\s+woz/i, respond
