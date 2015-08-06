--region extend_obj.lua
--Date
--此文件由[BabeLua]插件自动生成

-- ===========函数============
function makeKey( pos )
	return pos.x .. ":" .. pos.y
end

-- ===========对象============

posEx = {}
function posEx:create( pos )
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.x 	    = pos.x
    obj.y       = pos.y

	obj.G 		= pos.G or 0
	obj.H 		= pos.H or 0
	obj.F 		= pos.F or 0

    obj.pG      = pos.pG or 0
    obj.parentPos = pos.parentPos

	return obj
end

function posEx:calcF()
	self.F = self.G + self.H
end

function posEx:getF()
    return self.F
end

mapEx = {}
function mapEx:create()
	local obj = {}
	setmetatable( obj, { __index = self } )
	obj.map 	= {}
    obj.list    = {}
	return obj
end

function mapEx:add( pos )
    pos = posEx:create(pos)
    
    table.insert( self.list, pos )
    local key = makeKey(pos)
	self.map[key] = pos
end

function mapEx:del( idx )
    self.map[makeKey(self.list[idx])] = nil
    table.remove( self.list, idx )
end

local function cmp( pos1, pos2 )
    return pos1.F < pos2.F
end

function mapEx:min()
	table.sort( self.list, cmp )
    return self.list[1]
end

function mapEx:get( pos )
    return self.map[makeKey(pos)]
end

function mapEx:size()
	return #self.list
end

function mapEx:isExists( pos )
    local key = makeKey( pos )
	return nil ~= self.map[key]
end

--endregion
