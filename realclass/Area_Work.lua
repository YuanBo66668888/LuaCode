-- Area_Work
--------------------------------------------------------------------------------
local Area_Work = class(BaseBehaviour, "Area_Work")

function Area_Work:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	self.centerTr = self.transform
end

function Area_Work:getCenterPoint()
	return self.centerTr.position
end

function Area_Work:getPrefab(prefabName)
	return self.luaParameter:getGameObject(prefabName)
end

return Area_Work