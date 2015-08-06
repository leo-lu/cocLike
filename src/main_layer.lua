local MAX_MAP_WIDTH			= 30
local MAX_MAP_HEIGHT		= 30

local main_layer = class("main_layer", function()
	return cc.Layer:create()
end)

--转成格子坐标
--pos 点击地图的像素坐标
local function posForGrid(map, pos)
    local mapSize = map:getMapSize()
    local tileSize = map:getTileSize()

	local halfMapWidth = mapSize.width / 2
	local mapHeight = mapSize.height
	local tileWidth = tileSize.width
	local tileHeight = tileSize.height

--    cclog("mapSize: " .. mapSize.width .. "  " .. mapSize.height)
--    cclog("tileSize: " .. tileSize.width .. "  " .. tileSize.height)

	
	local tilePosDiv = cc.p(pos.x / tileWidth, pos.y / tileHeight)
	local inverseTileY = mapHeight - tilePosDiv.y


	--将得到的计算结果转换成 int，以确保得到的是整数
	local posX = math.floor(inverseTileY + tilePosDiv.x - halfMapWidth)
	local posY = math.floor(inverseTileY - tilePosDiv.x + halfMapWidth)
	--确保坐标在地图的边界之内
	posX = math.max(0, posX)
	posX = math.min(mapSize.width - 1, posX)
	posY = math.max(0, posY)
	posY = math.min(mapSize.height - 1, posY)

	return cc.p(posX, posY)
end

local function gridForPos(map, pos) --(1, 1)  (128, 64)
	local mapSize = map:getMapSize()
    local tileSize = map:getTileSize()

	local val1 = (pos.x + mapSize.width / 2 - mapSize.height) * tileSize.width * tileSize.height
	local val2 = (-pos.y + mapSize.width /2 + mapSize.height) * tileSize.width * tileSize.height

	local x = (val1 + val2) / 2 / tileSize.height
	local y = (val2 - val1) / 2 / tileSize.width - tileSize.height / 2

--    cclog("grid pos === "..pos.x.."  "..pos.y)
--    cclog("pos === " .. x .. "  " .. y)
    return cc.p(x,y)
end

function main_layer:ctor()
	local map_layer = cc.LayerColor:create(cc.c4b(78,127,41,0))
	local map = ccexp.TMXTiledMap:create("map/map_1.tmx");
	map_layer:setContentSize(map:getContentSize())
	map_layer:addChild(map)

    --local img_frame = ccui.ImageView:create("1.png")
	--img_frame:setScale(2)
	--img_frame:setAnchorPoint(0, 0)
	--map_layer:addChild(img_frame)

	self:addChild(map_layer)

    local mapSize = map:getMapSize()
    local tileSize = map:getTileSize()

	local road = map:getLayer("road")
    local roadMap = {}
    for x = 0, mapSize.width - 1 do
        local col = {}
        for y = 0, mapSize.height - 1 do
            local gid = road:getTileGIDAt(cc.p( x, y ))
            local uData = map:getPropertiesForGID( gid )
            if uData and "table" == type(uData) then
                cclog(uData["tree"])
                --col[y] = road:getTileAt(cc.p( x, y ))
                col[y] = tonumber(uData["tree"])
                
                local g = road:getTileAt(cc.p( x, y ))

                local lbl = ccui.Text:create( makeKey(cc.p(x, y)), "", 25 )
                lbl:setPosition( tileSize.width/2, tileSize.height/2 )
                g:addChild( lbl )
            else
                col[y] = nil
            end
        end
        roadMap[x] = col
    end

    self.pathObj = require( "path_find" ):create()
    self.pathObj:init( roadMap )

	local mapMove = true
	local btn = ccui.Button:create("ui/add1.png", "ui/add.png", "")
	btn:setPosition(50, 50)		
	self:addChild(btn)
	btn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			mapMove = not mapMove
		end
	end)

    local item = cc.Sprite:create("item/Item1.png")
    item:setPosition(gridForPos(map, cc.p( 2, 26 )))
    map_layer:addChild(item)

	local isMove = false
    local function onTouchBegan(touchs, event)
--    	print("began...")

        local touch = touchs[1]
        local pos = touch:getLocation()
        pos = map_layer:convertToNodeSpace( pos )

        --cclog( "touch   "..pos.x..":"..pos.y )
    	return true
    end

    local function onTouchMoved(touchs, event)
--        print("moved...")

        print(#touchs)

        local touch  = touchs[1]
        if nil == touch then return end

		local diff = touch:getDelta()

		local curPosX, curPosY = map_layer:getPosition()
		local pos = cc.p(curPosX + diff.x, curPosY + diff.y)

		local bgSize = cc.size(map_layer:getBoundingBox().width, map_layer:getBoundingBox().height)

		for k, v in pairs(map_layer:getBoundingBox()) do
			print(k .. "  <>  " .. v)
		end

		if math.abs(pos.x) > bgSize.width - WinX then
			pos.x = -bgSize.width + WinX
		elseif pos.x > 0 then
			pos.x = 0
		end
		
		if math.abs(pos.y) > bgSize.height - WinY then
			pos.y = -bgSize.height + WinY
		elseif pos.y > 0 then
			pos.y = 0
		end

		map_layer:setPosition(pos)

		isMove = true
    end

    local function onTouchEnded(touchs, event)
--		print("end...")
		
		local touch  = touchs[1]
        if nil == touch then return end
		local pos = touch:getLocation()
--
		--local mapSize = map_layer:getContentSize()
		--local mapPos = map_layer:convertToNodeSpace(pos)
		--cclog(mapPos.x .. "  ".. mapPos.y)
		--local ap = cc.p(mapPos.x/mapSize.width, mapPos.y/ mapSize.height)
--
		--if not isMove then
		--	map_layer:setAnchorPoint(ap)
		--	map_layer:setScale(map_layer:getScale()/2)
		--	map_layer:setAnchorPoint(0, 0)
		--end
		--isMove = false

		pos = map:convertToNodeSpace(pos)
        local p = posForGrid( map, pos )

        local itemX, itemY = item:getPosition()
        local sPos = posForGrid(map, cc.p(itemX, itemY))
		cclog(sPos.x .. " : " .. sPos.y)

        local path = self.pathObj:findPath( sPos, p, false )
        if nil == path then return end

        item:stopAllActions()
        if nil ~= next(path) then
            table.remove( path, 1 )

            local function showPath()
                local pos = path[1]
                if nil == pos then return end

                local nPos = gridForPos(map, pos)
                item:runAction( cc.Sequence:create( cc.MoveTo:create(0.3, nPos), cc.CallFunc:create(function()
                    table.remove( path, 1)
                    showPath()
                end)) )
            end
            showPath()
        else
            cclog("no  path .")
        end

--		--获取图块精灵
--		local sprite = road:getTileAt(p)
--		sprite:runAction(cc.Blink:create(1, 5))

--		local gid = road:getTileGIDAt(p)
--		cclog("GID:" .. gid)


		if not mapMove then
			p = gridForPos(map, p)
			item:runAction(cc.MoveTo:create(1, p))
		end
	end

    self.listener = cc.EventListenerTouchAllAtOnce:create()
    self.listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCHES_BEGAN)
    self.listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    self.listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCHES_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.listener, self)
end

return main_layer