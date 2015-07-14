# Description:
#  Responds when spoken to in normal conversation
#  <...> woz <animate or other> [[for]me] <input>
#  ie: 	hey woz, animate for me a cat with a toy
#				woz image cow
#				man man woz, can I have a picture of a dolphin?
#
#
#

module.exports = (robot) ->
	##---- MAIN REDIRECTION ----##
	getMsg = (msg,type,toGet) ->
		images = ["image","picture","pic","pix","img"]
		animations = ["animate","animation","gif"]
		if type in images
			getImage(msg,toGet)
		else if type in animations
			getAnimation(msg,toGet)

	##---- REDIRECT HELPERS ----##
	#### Query Google ####
	queryGoogle = (msg,input,type,cb) ->
		cb = animated if typeof animated == 'function'
		googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
		if googleCseId #using current API

			googleApiKey = process.env.HUBOT_GOOGLE_CSE_KEY
			if !googleApiKey
				msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
				msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
				return
			q = 
				q: input,
				searchType:'image',
				safe:'high',
				fields:'items(link)',
				cx: googleCseId,
				key: googleApiKey
			if type == 1
				q.fileType = 'gif'
				q.hq = 'animated'
			# if typeof faces is 'boolean' and faces is true
			# 	q.imgType = 'face'
			url = 'https://www.googleapis.com/customsearch/v1'
			msg.http(url)
				.query(q)
				.get() (err,res,body) ->
				if err
					msg.send "ERROR: #{err}"
					return
				if res.statusCode isnt 200
					msg.send "BAD HTTP REQUEST! #{res.statusCode}"
					return
				response = JSON.parse(body)
				if response?.items
					image = msg.random response.items
					cbensureImageExtension image.link
				else
				msg.send "Oops. I had trouble searching '#{input}'. Try later."
				((error) ->
					msg.robot.logger.error error.message
					msg.robot.logger
					.error "(see #{error.extendedHelp})" if error.extendedHelp
				) error for error in response.error.errors if response.error?.errors
		else
			# Using deprecated Google image search API
			q = v: '1.0', rsz: '8', q: input, safe: 'active'
			q.imgtype = 'animated' if type == 1
			# q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
			msg.http('https://ajax.googleapis.com/ajax/services/search/images')
				.query(q)
				.get() (err, res, body) ->
					if err
						msg.send "Encountered an error :( #{err}"
						return
					if res.statusCode isnt 200
						msg.send "Bad HTTP response :( #{res.statusCode}"
						return
					images = JSON.parse(body)
					images = images.responseData?.results
					if images?.length > 0
						image = msg.random images
						cb ensureImageExtension image.unescapedUrl
	ensureImageExtension = (url) ->
		ext = url.split('.').pop()
		if /(png|jpe?g|gif)/i.test(ext)
			url
		else
			"#{url}#.png"

	#### IMAGE GET ####
	getImage = (msg,imag) ->
		queryGoogle msg,imag,0, (url) ->
			msg.send url

	#### ANIMATION GET ####
	getAnimation = (msg,anim) ->
		queryGoogle msg,anim,1, (url) ->
			msg.send url


	##---- PARSERS ----##

	#### google-image IN CONVERSATION ####
	## ASSERTION
	robot.hear /.*woz.*(animate|animation|gif|image|picture|pic|pix|img)(?:(?: for)? me| of)?(?: a)? (.*)(?!\?)/i, (msg) ->
		if msg.match[2].match /[^\?]$/i
			type  = msg.match[1]
			toGet = msg.match[2]
			getMsg(msg,type,toGet)
	## QUESTION
	robot.hear /.*woz.*(?:can I).*(animate|animation|gif|image|picture|pic|pix|img)(?: of)?(?: a)? (.*)(?:\?)/i, (msg) ->
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
