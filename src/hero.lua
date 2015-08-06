

module(..., package.seeall)

function _M:create()
	local obj = {}
	setmetatable(obj, {__index = self})
	obj:init()
	return obj
end

function _M:init(  )
	--animation:getAnimation():play("walk")
end

function _M:

function _M:update()

end