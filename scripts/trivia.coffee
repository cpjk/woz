# Description:
#   start trivia round 
#
# Commands:
#   woz trivia

module.exports = (robot) ->

    triviaOn = false;
    hintInterval = null
    solution = 'ketchup'
    question = "What is red and goes on fries?"
    
    triviaStart = (msg) ->
        triviaOn = true
        msg.send "Trivia started"
        msg.send question
        solutionHint = Array(solution.length+1).join('_')
        hintInterval = setInterval () ->
            index = Math.floor(Math.random()*solution.length)
            solutionHint = solutionHint.substr(0,index) + solution[index] + solutionHint.substr(index+1)
            msg.send solutionHint
        , 3000

    robot.hear /solve\s+(.+)$/i, (msg) ->
        solveAttempt = msg.match[1]
        if solveAttempt == solution
            msg.reply "Ding Ding Ding, you are correct!"
            clearInterval(hintInterval)
            hintInterval = null
            triviaOn = false
            msg.send "Trivia is now off"

    robot.hear /trivia off/, (msg) ->
        if triviaOn
            clearInterval(hintInterval)
            hintInterval = null
            triviaOn = false
            msg.send "Trivia is now off"
        else 
            msg.send "Trivia is not in progress"
            return

    robot.respond /trivia\s*/i, (msg) ->
        if !triviaOn then triviaStart(msg) else msg.send "Trivia already in progress"
