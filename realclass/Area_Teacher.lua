local Curtain 	  = require "game.realclass.Curtain"
local VideoWindow = require "game.realclass.VideoWindow"

-- Area_Teacher
--------------------------------------------------------------------------------
local Area_Teacher = class(BaseBehaviour, "Area_Teacher")

function Area_Teacher:Awake()
	self.curtain = BehaviourUtil.AddBehaviour(self.transform:Find("Curtain").gameObject, Curtain)
	self.videoWindow = BehaviourUtil.AddBehaviour(self.transform:Find("VideoWindow").gameObject, VideoWindow)
end

function Area_Teacher:openCurtain(callback)
	self.curtain:open(callback)
end

function Area_Teacher:closeCurtain(callback)
	self.curtain:close(callback)
end

return Area_Teacher