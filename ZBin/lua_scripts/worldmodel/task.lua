module(..., package.seeall)


--- ///  /// --- /// /// --- /// /// --- /// /// --- /// /// ---

--			               HU-ROCOS-Challenge-2024   	     ---

--- ///  /// --- /// /// --- /// /// --- /// /// --- /// /// ---


function TurnToPoint(role, p, speed)
	-- 函数说明: 
		--使用前提：拿到球之后
		--功能：以球为中心旋转到目标点,需要在State层跳出
	--参数说明	
		-- role 	 使用这个函数的角色
		-- p	     指向坐标
		-- speed	 旋转速度 [1,10]
	local p1 = p
	if type(p) == 'function' then
		p1 = p()
	else
		p1 = p
	end
	if speed == nil then
		speed = param.rotVel
	end
	debugEngine:gui_debug_x(p1,6)
	local toballDir = (p1 - player.rawPos(role)):dir() * 57.3
	local playerDir = player.dir(role) * 57.3
	local subPlayerBallToTargetDir = toballDir - playerDir 
	-- local Subdir = math.abs(toballDir-playerDir)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,380),toballDir .. "                     " .. playerDir,4)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,220),math.abs(toballDir-playerDir) .. "                     " .. subPlayerBallToTargetDir,3)
	if math.abs(toballDir-playerDir) > 4 then
		if subPlayerBallToTargetDir < 0 then
			-- 顺时针旋转
			-- debugEngine:gui_debug_msg(CGeoPoint(1000, 1000), "顺时针")
			local ipos = CGeoPoint(param.rotPos:x(), param.rotPos:y() * -1)  --自身相对坐标 旋转
			local ivel = speed * -1
			local mexe, mpos = CircleRun {pos = ipos , vel = ivel}
			return { mexe, mpos }
		else
			-- 逆时针旋转
			-- debugEngine:gui_debug_msg(CGeoPoint(1000, 1000), "逆时针")
			local ipos = param.rotPos  --自身相对坐标 旋转
			local ivel = speed

			local mexe, mpos = CircleRun {pos = ipos , vel = ivel}
			return { mexe, mpos }
		end
	else
		local idir = (ball.pos() - player.pos(role)):dir()
		local pp = ball.pos() + Utils.Polar2Vector(50, idir)
		local mexe, mpos = GoCmuRush { pos = pp, dir = idir, acc = 50, flag = 0x00000100 + 0x04000000, rec = 1, vel = v }
		return { mexe, mpos }  
	end
end

function playerDirToPointDirSub(role, p) -- 返回 某座标点  球  playe 的角度偏差
	if type(p) == 'function' then
		p1 = p()
	else
		p1 = p
	end
	local playerDir = player.dir(role) * 57.3 + 180
	local playerPointDit = (p1 - player.pos(role)):dir() * 57.3 + 180
	local sub = math.abs(playerDir - playerPointDit)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(0, -3000),  "AngleError: ".. sub)
	return sub
end

function enemyDirToPointDirSub(role, p)
	if type(p) == 'function' then
		p1 = p()
	else
		p1 = p
	end
	local playerDir = enemy.dir(role) * 57.3 + 180
	local playerPointDit = (p1 - enemy.pos(role)):dir() * 57.3 + 180
	local sub = math.abs(playerDir - playerPointDit)
	debugEngine:gui_debug_msg(CGeoPoint:new_local(0, -3000),  "AngleError: ".. sub)
	return sub
end
function canPass(startPos,endPos,buffer)
	----------------------------------
	---返回两点之间是否可以传球
	-- startPos: 开始坐标
	-- endPos  : 结束坐标
	-- buffer  : 敌人半径
	local start = CGeoPoint(startPos:x(),startPos:y())
	local end_ = CGeoPoint(endPos:x(),endPos:y())
	return Utils.isValidPass(vision,start,end_,buffer)
end


function Shootdot(p, Kp, error_, flag)
	--- 功能：将球射向一个坐标点
	--- p：目标点
	--- Kp：力度比例
	--- error_: 精度误差值
	--- flag：击球的方式 [kick.flat(平射) \ kick.chip(挑球：不推荐使用、因为我们机器人不太能挑球)]
	return function()
		local p1
		if type(p) == 'function' then
			p1 = p()
		else
			p1 = p
		end

		local kp1
		if type(Kp) == 'function' then
			kp1 = Kp()
		else
			kp1 = Kp
		end
		local shootpos = function(runner)
			return ball.pos() + Utils.Polar2Vector(-50, (p1 - ball.pos()):dir())
		end
		local idir = function(runner)
			return (p1 - player.pos(runner)):dir()
		end
		local error__ = function()
			return error_ * math.pi / 180.0
		end

		local mexe, mpos = GoCmuRush { pos = shootpos, dir = idir, acc = a, flag = 0x00000100, rec = r, vel = v }
		return { mexe, mpos, flag, idir, error__, power(p, kp1), power(p, kp1), 0x00000000 }
	end
end


function getBall2024(role,targetPos)
	return function()
		local itargetPos
		if type(targetPos) == "function" then
			itargetPos = targetPos()
		else
			itargetPos = targetPos
		end
		local p
		local ballPos = ball.pos() + Utils.Polar2Vector(-80,(ball.pos() - player.pos(role)):dir())


		if player.infraredCount(role) < 20 then
			p = ballPos
			idir = player.toBallDir(role)
		else
			p = player.pos(role)
			idir = (itargetPos -player.pos(role) ):dir()

		end
		local ballLine = CGeoSegment(ball.pos(),ball.pos() + Utils.Polar2Vector(99999,ball.velDir()))
		local getInterPos = ballLine:projection(player.pos(role))

		if ball.velMod() > 500 and ballLine:IsPointOnLineOnSegment(getInterPos)then
			p = getInterPos
			idir = player.toBallDir(role)
		end
		local mexe, mpos = GetBall { pos = p, dir = idir, acc = a, flag = flag.dribbling, rec = r, vel = v, speed = s, force_manual = force_manual }
		return { mexe, mpos }
	end
end




function power(p, Kp) --根据目标点与球之间的距离求出合适的 击球力度 kp系数需要调节   By Umbrella 2022 06
	return function()
		local p1
		if type(p) == 'function' then
			p1 = p()
		else
			p1 = p
		end
		local dist = (p1 - ball.pos()):mod()
		local res = Kp * dist

		-- if res > 310 then
		-- 	res = 310
		-- end
		-- if res < 230 then
		-- 	res = 230
		-- end

		if res > 6000 then
			res = 6000
		end
		if res < 4000 then
			res = 4000
		end

		debugEngine:gui_debug_msg(CGeoPoint:new_local(0,3200),"Power" .. res .. "    toTargetDist: " .. dist,3)
		return res
	end
end


-------------------------------------------------------------------
-- by Umbrella 2024 04 12 									      |
-------------------------------------------------------------------





--~		Play中统一处理的参数（主要是开射门）
--~		1 ---> task, 2 ---> matchpos, 3---->kick, 4 ---->dir,
--~		5 ---->pre,  6 ---->kp,       7---->cp,   8 ---->flag
------------------------------------- 射门相关的skill ---------------------------------------
-- TODO
------------------------------------ 跑位相关的skill ---------------------------------------
--~ p为要走的点,d默认为射门朝向
function goalie()
	local mexe, mpos = Goalie()
	return {mexe, mpos}
end
function touch()
	local ipos = pos.ourGoal()
	local mexe, mpos = Touch{pos = ipos}
	return {mexe, mpos}
end
function touchKick(p,ifInter,power,mode)
	local ipos = p or pos.theirGoal()
	local idir = function(runner)
		return (_c(ipos) - player.pos(runner)):dir()
	end
	local mexe, mpos = Touch{pos = ipos, useInter = ifInter}
	local ipower = function()
		return power or 127
	end
	return {mexe, mpos, mode and kick.flat or kick.chip, idir, pre.low, ipower, cp.full, flag.nothing}
end
function goSpeciPos(p, d, f, a) -- 2014-03-26 增加a(加速度参数)
	local idir
	local iflag
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end

	if f ~= nil then
		iflag = f
	else
		iflag = 0
	end
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, acc = a, flag = iflag}
	return {mexe, mpos}
end

function goSimplePos(p, d, f)
	local idir
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end

	if f ~= nil then
		iflag = f
	else
		iflag = 0
	end

	local mexe, mpos = SimpleGoto{pos = p, dir = idir, flag = iflag}
	return {mexe, mpos}
end

function runMultiPos(p, c, d, idir, a, f)
	if c == nil then
		c = false
	end

	if d == nil then
		d = 20
	end

	if idir == nil then
		idir = dir.shoot()
	end

	local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = f, dist = d, acc = a}
	return {mexe, mpos}
end

function staticGetBall(target_pos, dist)
	local idist = dist or 140
	local p = function()
		local target = _c(target_pos) or pos.theirGoal()
		return ball.pos() + Utils.Polar2Vector(idist,(ball.pos()-target):dir())
	end
	local idir = function()
		local target = _c(target_pos) or pos.theirGoal()
		return (target - ball.pos()):dir()
	end
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, flag = flag.dodge_ball}
	return {mexe, mpos}
end

function goCmuRush(p, d, a, f, r, v, s, force_manual)
	-- p : CGeoPoint, pos
	-- d : double, dir
	-- a : double, max_acc
	-- f : int, flag
	-- v : CVector, target_vel
	-- s : double, max_speed
	-- force_manual : bool, force_manual
	local idir
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, acc = a, flag = f,rec = r,vel = v, speed = s, force_manual = force_manual}
	return {mexe, mpos}
end

function forcekick(p,d,chip,power)
	local ikick = chip and kick.chip or kick.flat
	local ipower = power and power or 8000
	local idir = d and d or dir.shoot()
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, kp.specified(ipower), cp.full, flag.forcekick}
end

function shoot(p,d,chip,power)
	local ikick = chip and kick.chip or kick.flat
	local ipower = power and power or 8000
	local idir = d and d or dir.shoot()
	local mexe, mpos = GoCmuRush{pos = p, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, kp.specified(ipower), cp.full, flag.nothing}
end
------------------------------------ 防守相关的skill ---------------------------------------
-- TODO
----------------------------------------- 其他动作 --------------------------------------------

-- p为朝向，如果p传的是pos的话，不需要根据ball.antiY()进行反算
function goBackBall(p, d)
	local mexe, mpos = GoCmuRush{ pos = ball.backPos(p, d, 0), dir = ball.backDir(p), flag = flag.dodge_ball}
	return {mexe, mpos}
end

-- 带避车和避球
function goBackBallV2(p, d)
	local mexe, mpos = GoCmuRush{ pos = ball.backPos(p, d, 0), dir = ball.backDir(p), flag = bit:_or(flag.allow_dss,flag.dodge_ball)}
	return {mexe, mpos}
end

function stop()
	local mexe, mpos = Stop{}
	return {mexe, mpos}
end

function continue()
	return {["name"] = "continue"}
end

------------------------------------ 测试相关的skill ---------------------------------------

function openSpeed(vx, vy, vw, iflag)
	local mexe, mpos = OpenSpeed{speedX = vx, speedY = vy, speedW = vw, flag = iflag}
	return {mexe, mpos}
end