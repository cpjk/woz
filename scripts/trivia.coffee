# Description:
#   start trivia round 
#
# Commands:
#   woz trivia
#   trivia help

module.exports = (robot) ->

    triviaOn = false;
    hintInterval = null
    solutions = ['ketchup','vinegar','gravy','cheese curds']
    currentSolution = ''
    currentQuestion = "What goes on fries?"

    triviaStart = (msg) ->
        triviaOn = true
        # will need to access array of q/a objects and get a random integer index
        # set current question to array[index].question
        # set current solution to array[index].solution
        msg.send currentQuestion
        currentSolution = solutions[Math.floor(Math.random()*solutions.length)]
        solutionHint = Array(currentSolution.length+1).join('_')
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
        , 5000

    triviaStop = (msg) ->
        clearInterval(hintInterval)
        hintInterval = null
        triviaOn = false
        
    robot.hear /solve\s+(.+)$/i, (msg) ->
        solveAttempt = msg.match[1]
        if solveAttempt == currentSolution
            msg.reply "Ding Ding Ding, you are correct!"
            triviaStop(msg)
        else
            msg.reply "Incorrect!"

    robot.hear /trivia off/, (msg) ->
        if triviaOn
            triviaStop(msg) 
            msg.send "Trivia is now off"
        else msg.send "Trivia is not in progress"
            

    robot.respond /trivia\s*/i, (msg) ->
        if !triviaOn
            msg.send "Trivia started"
            triviaStart(msg)
        else msg.send "Trivia already in progress"

    robot.hear /^trivia\s+help$/i, (msg) ->
        msg.send "Trivia commands:\nwoz trivia: start a round of trivia\ntrivia off: stop trivia\nsolve ____: attempt to solve current question\ntrivia leaderboard:shows current leaderboard"
