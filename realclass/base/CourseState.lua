local CourseStateMachine = require "game.realclass.base.CourseStateMachine"

local CourseState = class(BaseBehaviour, "CourseState")

CourseState.INIT = 0

function CourseState:init(stateMachine)
	BaseBehaviour.init(self)
	self.stateMachine = stateMachine
	self.internalState = CourseState.INIT
end

function CourseState:enter()
	self.substateMachine = BehaviourUtil.AddBehaviour(self.gameObject, CourseStateMachine)
end

function CourseState:exit()
	self.substateMachine:destroySelf()
end

function CourseState:onSelected(block)
	self:waterfall({
		function(cb) block:shrink(cb) end,
	}, function()
		self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity)
	end)
end

return CourseState