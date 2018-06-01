-- CourseSubstate
--------------------------------------------------------------------------------
local CourseSubstate = class(BaseBehaviour, "CourseSubstate")

function CourseSubstate:init(stateMachine)
	BaseBehaviour.init(self)
	self.stateMachine = stateMachine
end

function CourseSubstate:enter()

end

function CourseSubstate:exit()

end

function CourseSubstate:onSelected(block)
	self:waterfall({
		function(cb) block:shrink(cb) end,
	}, function()
		self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity)
	end)
end

return CourseSubstate