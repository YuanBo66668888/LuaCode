local Curtain     = require "game.realclass.Curtain"
local VideoWindow = require "game.realclass.VideoWindow"

local Area_Board = class(BaseBehaviour, "Area_Board")

function Area_Board:Awake()
    self.curtain = BehaviourUtil.AddBehaviour(self.transform:Find("Curtain").gameObject, Curtain)
    self.videoWindow = BehaviourUtil.AddBehaviour(self.transform:Find("VideoWindow").gameObject, VideoWindow)
end

function Area_Board:openCurtain(callback)
    self.curtain:open(callback)
end

function Area_Board:closeCurtain(callback)
    self.curtain:close(callback)
end

return Area_Board