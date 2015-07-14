# Description:
#  Responds when spoken to in normal conversation
#  <...> woz <animate or other> [[for]me] <input>
#  ie: hey woz, animate for me a cat with a toy
#
#
#
#
#

module.exports = (robot) ->
	##---- MAIN REDIRECTION ----##
	getMsg = (msg,type,toGet) ->
		images = ["image","pic","pix","img"]
		animations = ["animate","gif"]


		if type in images
			getImage(msg,toGet)
		else if type in animations
			getAnimation(msg,toGet)



	##---- REDIRECT HELPERS ----##
	#### IMAGE GET ####
	getImage = (msg,imag) ->
		image = require("../node_modules/hubot-google-images/src/google-images.coffee")
		image.imageMe(msg,"image") (url) ->
			msg.send url
		# msg.send "image: #{image.imageMe(msg,"image")}"
	#### ANIMATION GET ####
	getAnimation = (msg,anim) ->
		msg.send "animation: #{anim}"



	##---- PARSERS ----##

	#### google-image IN CONVERSATION ####
	robot.hear /.*woz.* .+(animate|gif|image|pic|pix|img)(?:(?: for)? me|of)? (.*)/i, (msg) ->
		type  = msg.match[1]
		toGet = msg.match[2]
		getMsg(msg,type,toGet)

	#### RICK ASTLEY ####
	robot.hear /never gonna give you up/i, (msg) ->
		rick = 1
		msg.send "Never gonna let you down"
		robot.hear /never gonna run around and desert you/i, (msg) ->
			if rick == 1
				rick = 2
				msg.send "Never gonna make you cry"
			robot.hear /never gonna say goodbye/i, (msg) ->
				if rick == 2
					rick = 3
					msg.send "Never gonna tell a lie and hurt you!"
