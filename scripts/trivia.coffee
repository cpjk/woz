# Description:
#   start trivia round 
#
# Commands:
#   woz trivia
#   trivia help

module.exports = (robot) ->

  triviaOn = false
  hintInterval = null
  #url for questions and answers
  url = "http://jservice.io/api/random"
  currentSolution = ''

  triviaStart = (msg) ->
    triviaOn = true
    msg.http(url).get() (err, res, body) ->
      response = (JSON.parse body)[0]
      currentSolution = response.answer
      currentQuestion = response.question
      msg.send currentQuestion
      #creating string of (_) for a hint and filling them in until half of them
      #(or 1 less than half) are full, then time's up and a new question will be asked
      solutionHint = Array(currentSolution.length+1).join('_')
      #this is so that we don't have repeated letters coming up in the hint
      #i make an array of numbers (up to solution length) and splice off ones that i've used
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

  #function to turn off trivia
  #made this so i could reset every time a question is done
  triviaStop = (msg) ->
    clearInterval(hintInterval)
    hintInterval = null
    triviaOn = false
    
  #solve attempt matches anything after !, case insensitive
  #need to add some way to score points
  robot.respond /!(.+)$/i, (msg) ->
    solveAttempt = msg.match[1]
    if solveAttempt.toLowerCase() == currentSolution.toLowerCase()
      msg.reply "Ding Ding Ding, you are correct!"
      triviaStop(msg)
      triviaStart(msg)
    else
      msg.reply "Incorrect!"

  #command to turn off trivia
  robot.respond /trivia off/i, (msg) ->
    if triviaOn
      triviaStop(msg) 
      msg.send "Trivia is now off"
    else msg.send "Trivia is not in progress"

  robot.respond /trivia(\son)?$/i, (msg) ->
    if !triviaOn
      msg.send "Trivia started"
      triviaStart(msg)
    else msg.send "Trivia already in progress"

  robot.respond /leaderboard/i, (msg) ->
    msg.send "Currently there is no database set up to keep track of scores, feel free to contribute!"

  robot.hear /^trivia\s+help$/i, (msg) ->
    msg.send "Trivia commands:\nwoz trivia: start a round of trivia\nwoz trivia off: stop trivia\nwoz !____: attempt to solve current question\nwoz leaderboard:shows current leaderboard(in development)"
