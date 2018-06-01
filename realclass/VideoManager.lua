local VideoManager = class(BaseBehaviour, "VideoManager")

function VideoManager:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
end

function VideoManager:getVideoClip(clipName)
	return self.luaParameter:getVideoClip(clipName)
end

return VideoManager