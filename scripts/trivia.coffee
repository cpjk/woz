# Description:
#   start trivia round 
#
# Commands:
#   trivia help

points = {}

module.exports = (robot) ->

  #don't try to access the brain until it is loaded
  robot.brain.on 'loaded', ->

    #points are stored as private object in redis
    #get point object
    points = robot.brain.get('pointlist') or {}

  #default values
  triviaOn = false
  hintInterval = null
  currentSolution = ''

  #url for questions and answers
  url = "http://jservice.io/api/random"


  #----------------Current Question----------------#
  triviaStart = (msg) ->
    triviaOn = true
    msg.send "Type !trivia help for all trivia commands"
    msg.send "Searching for a question..."

    #get request to api
    msg.http(url).get() (err, res, body) ->
      response = (JSON.parse body)[0]
      currentSolution = response.answer

      #quick fixes for 2 most common errors in solutions
      #<i>....</i> and
      #"....."
      #could create a more general algorithm for error checking
      if currentSolution[0] == "<"
        currentSolution = currentSolution.substr(3,currentSolution.length-7)
      if currentSolution[0] == "\""
        currentSolution = currentSolution.substr(1,currentSolution.length-2)

      currentQuestion = response.question
      msg.send currentQuestion

      #creating string of (_) for a hint and filling them in up to half
      solutionHint = Array(currentSolution.length+1).join('_')

      #array holding indexes of positions that have not been used for the hint, splice off indexes that have been used
      solutionArray = [0..currentSolution.length-1]

      hintInterval = setInterval () ->
        if Math.ceil(currentSolution.length/2) == solutionArray.length
          msg.send "Time's up! The correct answer was " + currentSolution
          triviaStop msg
          triviaStart msg
        else  
          index = Math.floor(Math.random()*solutionArray.length)
          solutionHint = solutionHint.substr(0,solutionArray[index]) + currentSolution[solutionArray[index]] + solutionHint.substr(solutionArray[index]+1)
          solutionArray.splice(index,1)
          msg.send solutionHint
      , 15000

  #-------------Solve Attempt-----------------#
  #solve attempt matches anything after ?  
  robot.hear /\?\s*(.+)$/i, (msg) ->
    if triviaOn
      solveAttempt = msg.match[1].trim()
      if solveAttempt.toLowerCase().replace(/\s/g, "") == currentSolution.toLowerCase().replace(/\s/g, "")
        msg.reply "Ding Ding Ding, you are correct!"
      
        #get user and add 1 point to their score
        username = msg.message.user.name
        points[username] ?= 0
        points[username] += 1

        #update points object in db
        robot.brain.set 'pointlist', points

        msg.reply "You currently have " + points[username] + " points"

        triviaStop(msg)
        triviaStart(msg)
      else
        msg.reply "Incorrect!"
  
  #---------------Trivia Toggling---------------#
  #used for setting new question and turning off trivia
  triviaStop = (msg) ->
    clearInterval(hintInterval)
    hintInterval = null
    triviaOn = false
  
  #turn off trivia
  robot.respond /(trivia\s)?off/i, (msg) ->
    if triviaOn
      triviaStop(msg) 
      msg.send "Trivia is now off"
    else msg.send "Trivia is not in progress"

  #turn on trivia
  robot.respond /trivia(\son)?$/i, (msg) ->
    if !triviaOn
      msg.send "Trivia started"
      triviaStart(msg)
    else msg.send "Trivia already in progress"

  #----------------Leaderboard----------------#
  #show top 10 on leaderboard + their points
  robot.respond /leaderboard/i, (msg) ->
    msg.send "Top 10 scores:"
    sortable = []
    for user,pts of points
      sortable.push([user,pts])
    sorted = sortable.sort (a,b) ->
      b[1]-a[1]
    for user in sorted.slice(0,10)
      msg.send user[0] + ": " + user[1]

  #show user's points
  robot.respond /trivia points/i, (msg) ->
    username = msg.message.user.name
    msg.reply "You currently have " + (points[username] or 0) + " points"

  #-----------------Debugging-----------------#
  #Skip current question
  ###
  robot.respond /trivia skip/i, (msg) ->
    msg.send "Solution: " + currentSolution
    msg.send "Skipping..."
    triviaStop(msg)
    triviaStart(msg)
  ###

  robot.respond /trivia\s+help$/i, (msg) ->
    msg.send "Trivia commands:\n!trivia: start a round of trivia\n!trivia off: stop trivia\n?____: attempt to solve current question\n!leaderboard: shows current leaderboard\n!trivia points: show your current points"
