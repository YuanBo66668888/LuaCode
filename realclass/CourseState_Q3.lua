local VideoWindow 		= require "game.realclass.VideoWindow"
local CourseState 		= require "game.realclass.base.CourseState"
local CourseSubstate    = require "game.realclass.base.CourseSubstate"
local ChangeSmokeEffect = require "game.universal.effects.ChangeSmokeEffect"
local OneBlock_Custom   = require "game.realclass.OneBlock_Custom"


-- CourseState_Q3
--------------------------------------------------------------------------------
local CourseState_Q3 = class(CourseState, "CourseState_Q3")

function CourseState_Q3:Awake()
	self.videoManager = self.app:g_find("VideoManager")
	self.area_Teacher = self.app:g_find("Area_Teacher")
	self.area_Board   = self.app:g_find("Area_Board")
	self.area_Work    = self.app:g_find("Area_Work")

	self.videoWindow_Teacher = self.area_Teacher.videoWindow
	self.videoWindow_Teacher.emitter:on(VideoWindow.PREPARE_COMPLETED, self.prepareCompleted_Teacher, self)

	self.videoWindow_Board = self.area_Board.videoWindow
	self.videoWindow_Board.emitter:on(VideoWindow.PREPARE_COMPLETED, self.prepareCompleted_Board, self)
	self.videoWindow_Board.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Board, self)
end

function CourseState_Q3:prepareCompleted_Teacher()
	self.area_Teacher:openCurtain()
end

function CourseState_Q3:prepareCompleted_Board()
	self.area_Board:openCurtain()
end

function CourseState_Q3:loopPointReached_Board(options)

end

function CourseState_Q3:enter()
	CourseState.enter(self)
	-- self.substateMachine:addState(CourseSubstate_Circle)
	-- self.substateMachine:addState(CourseSubstate_Rectangle)
	-- self.substateMachine:addState(CourseSubstate_Triangle)
	-- self.substateMachine:addState(CourseSubstate_Square)
	-- self.substateMachine:addState(CourseSubstate_Semicircle)
	-- self.substateMachine:addState(CourseSubstate_Final)
	-- self.substateMachine:stateTransition("CourseSubstate_Semicircle", self)
end

function CourseState_Q3:exit()
	CourseState.exit(self)

	self.videoWindow_Teacher.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)

	self.videoWindow_Board.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Board.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseState_Q3:onSelected(block)
	local currentSubstate = self.substateMachine.currentState
	if currentSubstate then
		currentSubstate:onSelected(block)
	else
		CourseState.onSelected(self, block)
	end
end

return CourseState_Q3