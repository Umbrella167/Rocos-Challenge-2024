local firstPos = {
    CGeoPoint(-1500,0),
    CGeoPoint(750,-1299),
    CGeoPoint(750,1299)
}
local toBallDir = function(role)
    return function()
        return player.toBallDir(role)
    end
end
local getTheirDribblingPlayer = function()
    local minDist = 99999
    local minPlayer = -1
    for i=0,param.maxPlayer do
        if enemy.valid(i)then 
            local dist = (enemy.pos(i) - ball.pos()):mod()
            if dist < minDist then
                minDist = dist
                minPlayer = i
            end
        end
    end
    return minPlayer
end
local interPos = function(enemyNum)
        local num 
        if type(enemyNum) == "function" then
            num = enemyNum()
        else
            num = enemyNum
        end
        local p = enemy.pos(num) + Utils.Polar2Vector(1200,(ball.pos()-enemy.pos(num)):dir())

        for i,v in pairs(firstPos) do
            if player.toPointDist("Assister",v) < 700 then
                p = CGeoPoint(0,0)
                break
            end
        end
        local angleDiff = task.enemyDirToPointDirSub(num,CGeoPoint(0,0))
        if angleDiff > 45 then 
            p = player.pos("Assister")
        end
        return p
end
gPlayTable.CreatePlay{
firstState = "Init",

["Init"] = {
    switch = function()
        return "Run"

    end,
    Assister = task.stop(),
    match = "[A]"
},

["Run"] = {
    switch = function()

    end,
    Assister = task.goCmuRush(function()return interPos(function() return getTheirDribblingPlayer() end)end, toBallDir("Assister"),_,_,Utils.Polar2Vector(700,(interPos(function() return getTheirDribblingPlayer() end) - player.pos("Assister")):dir())),
    match = "[A]"
},


name = 'BOSS',
}