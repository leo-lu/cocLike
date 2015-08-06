local xOffset = -55
local yOffset = 55
local speed = 3

local STATE = {
	STAND 		= 1,
	WALK 		= 2,
}

local role = class("role", function() 
	--return cc.Node:create()
	return cc.LayerColor:create(cc.c4b(200, 200, 0, 200))
end)

function role:ctor()
	self:setContentSize(5, 5)

	self.state = STATE.STAND
	self:setLeft(true)

	self.animation = createAnimation("Hero_Gunner")
	self:addChild(self.animation)
	self.animation:setPosition(xOffset, yOffset)

	local scheduler = cc.Director:getInstance():getScheduler()
    self._schedulerEntry = scheduler:scheduleScriptFunc(function()
    	self:update_pos()
	end,
	0.016,
	false)
    self:registerScriptHandler(function(event)
        if event == "enter" then

        elseif event == "cleanup" then
		    scheduler:unscheduleScriptEntry( self._schedulerEntry )
        end
    end)
end

function role:setLeft( left )
	local scale = 1
	if left  then
		scale = -1
	end
	self:setScaleX( scale )
	self.isLeft = left
end

function role:setDesPos( pos )
	self.desPos = pos
end

function role:stand()
	if STATE.STAND ~= self.state then
		self.state = STATE.STAND
		self.animation:getAnimation():play("stand")
	end
end

function role:move( pos )
	if STATE.WALK ~= self.state then
		self.state = STATE.WALK
		self.animation:getAnimation():play("walk")
	end
end

function role:update_pos()
	local curX, curY = self:getPosition()
	if curX < self.desPos.x and not self.isLeft then
		self:setLeft(true)
	elseif curX > self.desPos.x and self.isLeft then
		self:setLeft(false)
	end

	if not cc.rectContainsPoint(cc.rect(self.desPos.x - speed/2, self.desPos.y - speed/2, speed, speed), cc.p(curX, curY)) then
		self:move()
		local d = cc.pGetDistance(cc.p(curX, curY), self.desPos)
		local t = d/speed
		local speedX = (self.desPos.x - curX)/t
		local speedY = (self.desPos.y - curY)/t
		self:setPosition(cc.p(curX + speedX, curY + speedY))
	else
		self:stand()
	end
end

function role:update_trace()

end

return role