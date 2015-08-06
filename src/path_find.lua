module(..., package.seeall)

---------------- local function

local function calcG( tPos, pos )
	local G
	if 2 == math.abs( pos.x - tPos.x ) + math.abs( pos.y - tPos.y ) then
		G = 14
	else
		G = 10
	end
	local pG
    if nil ~= pos.parentPos then
        pG = pos.parentPos.G
    else
        pG = 0
    end

	return G + pG
end

local function calcH( ePos, pos )
	local step = math.abs( pos.x - ePos.x ) + math.abs( pos.y - ePos.y )
	return step * 10
end

function _M:foundPos( tPos, pos )
	local G = calcG( tPos, pos )
	if G < pos.G then
		pos.parentPos = tPos
		pos.G = G
		pos:calcF()
	end
end

function _M:notFoundPos( tPos, ePos, pos )
    pos.parentPos = tPos
    pos.G = calcG( tPos, pos )
    pos.H = calcH( ePos, pos )
    pos:calcF()
    self._openList:add( pos )
end

--获取某点周围可以到达的点
function _M:getAroundPos( pos, isIgnoreCorner )
	local posArr = {}
	for x = pos.x - 1, pos.x + 1 do
		for y = pos.y - 1, pos.y + 1 do
			if self:canReach( pos, x, y, isIgnoreCorner ) then
				table.insert( posArr, posEx:create( cc.p( x, y ) ) )
			end
		end
	end
	return posArr
end

----------------

function _M:create()
	local obj = {}
	setmetatable( obj, { __index = self } )
	return obj
end

function _M:init( mapArr )
	self._mapArr    = mapArr
	self._openList 	= mapEx:create()
	self._closeList	= mapEx:create()
end

--判断是否阻碍
function _M:canReach( pos, x, y, isIgnoreCorner )
	if nil == isIgnoreCorner then
		isIgnoreCorner = true
	end

	local function isCan( pos )
		--return 0 == self._mapArr[pos.y][pos.x]
        return 0 == self._mapArr[pos.x][pos.y]
	end
	
	local rst = true
	if not isCan( cc.p( x, y ) ) or self._closeList:isExists( cc.p( x, y ) ) then
		rst = false
	end

	if rst and not isIgnoreCorner then
		if math.abs( x - pos.x ) + math.abs( y - pos.y ) == 1 then
			--上下左右
			return true
		else
			--斜方向
			if isCan( cc.p( math.abs( x - 1 ), y ) ) and isCan( cc.p( x, math.abs(y) ) ) then
				return true
			else
				return isIgnoreCorner
			end
		end
	end

	return rst
end

local function getPath( ePos )
    local path = {}
    while nil ~= ePos do
        table.insert(path, 1, ePos)
        ePos = ePos.parentPos
    end
    return path
end

function _M:findPath( sPos, ePos, isIgnoreCorner , callback )
    sPos = posEx:create( sPos )
    ePos = posEx:create( ePos )
	self._openList:add( sPos )
	while 0 ~= self._openList:size() do
		local tPos = self._openList:min()

        if nil ~= callback then
            callback( tPos )
        end
        --cclog( "find ::   "..tPos.x ..":"..tPos.y )

        self._openList:del( 1 ) --打开列表移除
		self._closeList:add( tPos ) --添加到关闭列表
		local sPosArr = self:getAroundPos( tPos, isIgnoreCorner )
		for idx, pos in ipairs( sPosArr ) do
			if self._openList:isExists( pos ) then
				self:foundPos( tPos, pos )
			else
				self:notFoundPos( tPos, ePos, pos )
			end
		end

		if self._openList:isExists( ePos ) then
            return getPath( self._openList:get( ePos ) )
        end
	end
	if self._openList:isExists( ePos ) then
        return getPath( self._openList:get( ePos ) )
    end
end