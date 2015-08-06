
local main_scene = class("main_scene", function()
	return cc.Layer:create()
end)

function main_scene:ctor()
	local bg = ccui.ImageView:create()
	bg:loadTexture("bg/choose_bg.jpg")
	self:addChild(bg)
	bg:setPosition(WinX/2, WinY/2)

	local hero = require("role").new()
	hero:setPosition(-200, WinY/2 )
	self:addChild(hero)
	--hero:move( cc.p(500, 500) )
	hero:setDesPos(cc.p(200, WinY/2))


    local function onTouchBegan(touch, event)
    	return true
    end

    local function onTouchMoved(bouch, event)
        
    end

    local function onTouchEnded(touch, event)
    	local pos = touch:getLocation()
    	hero:setDesPos(pos)
    end

    self.listener = cc.EventListenerTouchOneByOne:create()
    self.listener:setSwallowTouches(false)
    self.listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCHES_MOVED)
    self.listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener, self)
end

return main_scene