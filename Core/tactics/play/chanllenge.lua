
-- 初始坐标
local firstPos = {
    CGeoPoint(1500,0),
    CGeoPoint(-750,1299),
    CGeoPoint(-750,-1299)
}


-- 某角色指向球的方向
local toBallDir = function(role)
    return function()
        return player.toBallDir(role)
    end
end

-- 某角色拿球的坐标
local toballPos = function(role)
    return function()
        return ball.pos() + Utils.Polar2Vector(-105,(ball.pos() - player.pos(role)):dir())
    end
end

-- 改变所有角色的匹配 ：
-- 原理： 改变 firstPos 的顺序然后利用角色匹配规则实现
function changeMatchAll()
    local firstElement = table.remove(firstPos, 1)
    table.insert(firstPos, firstElement)
end
-- 改变接球角色的匹配
function changeMatchGetball()
    local secondElement = table.remove(firstPos, 2)
    table.insert(firstPos, secondElement)
end
gPlayTable.CreatePlay{
firstState = "Init",


--- 初始状态，根据firstPos决定匹配结果
["Init"] = {
    switch = function()
        debugEngine:gui_debug_arc(firstPos[1],600,0,360,4)
        debugEngine:gui_debug_arc(firstPos[2],600,0,360,1)
        debugEngine:gui_debug_arc(firstPos[3],600,0,360,1)
        return "goFirstPos"
    end,
    Assister = task.goCmuRush(function() return firstPos[1] end, toBallDir("Assister")),
    Kicker = task.goCmuRush(function() return firstPos[2] end,toBallDir("Kicker")),
    Leader = task.goCmuRush(function() return firstPos[3] end,toBallDir("Leader")),
    match = "[AKL]"
},

-- 如果所有机器人都离自己的目标点很近就可以跳到拿球
["goFirstPos"] = {
    switch = function()
        debugEngine:gui_debug_arc(firstPos[1],600,0,360,4)
        debugEngine:gui_debug_arc(firstPos[2],600,0,360,1)
        debugEngine:gui_debug_arc(firstPos[3],600,0,360,1)
        
        if player.toTargetDist('Assister') < 100 and player.toTargetDist('Kicker') < 100 and player.toTargetDist('Leader') < 100 then
            return "getball"
        end
    end,
	Assister = task.goCmuRush(function() return firstPos[1] end, toBallDir("Assister")),
    Kicker = task.goCmuRush(function() return firstPos[2] end,toBallDir("Kicker")),
    Leader = task.goCmuRush(function() return firstPos[3] end,toBallDir("Leader")),
	match = "{AKL}"
},

-- 拿到球然后指向目标点
["getball"] = {
    switch = function()
        debugEngine:gui_debug_arc(firstPos[1],600,0,360,4)
        debugEngine:gui_debug_arc(firstPos[2],600,0,360,1)
        debugEngine:gui_debug_arc(firstPos[3],600,0,360,1)


        -- 如果机器人拿到球并且 与目标角度相差小于3度那么传球
        if task.playerDirToPointDirSub("Assister",player.pos("Kicker")) < 3 and player.infraredCount("Assister") > 5 then
            return "shoot"
        end
        -- 如果不能传球（传球路径有敌人，那么换一个机器人传球）
        if(not task.canPass(player.pos("Assister"),player.pos("Kicker"),130)) then
            -- 改变表顺序
            changeMatchGetball()
            return "Init"
        end
    end,
    Assister = task.getBall2024("Assister",function() return player.pos("Kicker")end),
    Kicker = task.goCmuRush(function() return firstPos[2] end,toBallDir("Kicker")),
    Leader = task.goCmuRush(function() return firstPos[3] end,toBallDir("Leader")),
    match = "{AKL}"
},

["shoot"] = {
    switch = function()
        debugEngine:gui_debug_arc(firstPos[1],600,0,360,4)
        debugEngine:gui_debug_arc(firstPos[2],600,0,360,4)
        debugEngine:gui_debug_arc(firstPos[3],600,0,360,4)
        if player.kickBall("Assister") then
            changeMatchAll()
            return "Init"
        end
    end,
    Assister = task.Shootdot(function() return player.pos("Kicker")end, 0.005, 8, kick.flat),
    Kicker = task.goCmuRush(function() return firstPos[2] end,toBallDir("Kicker")),
    Leader = task.goCmuRush(function() return firstPos[3] end,toBallDir("Leader")),
    match = "{AKL}"
},

name = 'chanllenge',
}