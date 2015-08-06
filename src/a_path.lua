--region a_path.lua
--Date
--此文件由[BabeLua]插件自动生成

local function mKey( pos )
    return pos.x ..":"..pos.y
end

local a_path = class( "a_path", function()
    return cc.LayerColor:create( cc.c4b( 35, 35, 35, 200 ) )
end )

function a_path:ctor()
    local s = cc.size( 1200, 900 )
    self:setContentSize( s )
    self:setPosition( (WinX - s.width)/2, (WinY - s.height)/2 )

    local array = {
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                    { 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1},
                    { 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                    };
    
    local sPos = posEx:create( cc.p( 2, 8 ) )
    local ePos = posEx:create( cc.p( 19, 8 ) )

    local nodeArr = {}
    local gSize = cc.size( 50, 50 )
    for r, row in ipairs(array) do
        local offsetY = s.height - ( (r + 1) * gSize.height + r * 2)
        for c, val in ipairs(row) do
            local offsetX = c * gSize.width + c * 2
            local node

            if 1 == val then
                node = cc.LayerColor:create(cc.c4b(100, 0, 0, 200))
            else
                if c == sPos.x and r == sPos.y then
                    node = cc.LayerColor:create(cc.c4b(200, 200, 200, 200))
                elseif c == ePos.x and r == ePos.y then
                    node = cc.LayerColor:create(cc.c4b(30, 30, 30, 200))
                else
                    node = cc.LayerColor:create(cc.c4b(0, 0, 100, 200))
                end
            end
            node:setContentSize( gSize )
            self:addChild(node)
            node:setPosition( offsetX, offsetY )

            node.lbl = ccui.Text:create( mKey(cc.p(c, r)), "", 22 )
            node.lbl:setPosition( gSize.width/2, gSize.height/2 )
            node:addChild( node.lbl )

            nodeArr[mKey(cc.p(c, r))] = node
        end
    end

    local findObj = require("path_find"):create()
    findObj:init( array )

    local btn = ccui.Button:create( "img_bg.jpg", "img_bg.jpg", "img_bg.jpg" )
    btn:addTouchEventListener( function( sender, eType )
        if ccui.TouchEventType.ended == eType then
            local path = findObj:findPath( sPos, ePos, false, function( p)
                local n = nodeArr[mKey(p)]
                if nil ~= n then
                    --n.lbl:setColor( cc.c3b( 0, 200, 0 ) )
                    n:setColor( cc.c3b( 0, 200, 0 ) )
                end
            end )

            if nil == path then return end
            local delay = 0.2
            for idx, pos in ipairs( path ) do
                local node = nodeArr[mKey(pos)]
                node:runAction( cc.Sequence:create( cc.DelayTime:create(delay), cc.CallFunc:create(function()
                    --node.lbl:setColor( cc.c3b(200, 0, 0) )
                    node:setColor( cc.c3b(100, 100, 200) )
                end)) )
                delay = delay + 0.2
            end

--            pPos = ePos
--            local showPath
--            showPath = function()
--                if nil ~= pPos then
--                    cclog( "path:  "..pPos.x ..":".. pPos.y )
--                    local node = nodeArr[mKey(pPos)]
--                    node:runAction( cc.Sequence:create( cc.DelayTime:create(0.3), cc.CallFunc:create(function()
--                        node.lbl:setColor( cc.c3b(200, 0, 0) )
--                        pPos = pPos.parentPos
--                        showPath()
--                    end)) )
--                end
--            end
--            showPath()
        end
    end )
    btn:setPosition( 30, 30 )
    self:addChild( btn )
end

return a_path

--endregion
