local VideoWindow 		= require "game.realclass.VideoWindow"
local CourseState 		= require "game.realclass.base.CourseState"
local ChangeSmokeEffect = require "game.universal.effects.ChangeSmokeEffect"
local OneBlock_Custom   = require "game.realclass.OneBlock_Custom"

-- Cock
--------------------------------------------------------------------------------
local Cock = class(BaseBehaviour, "Cock")

function Cock:leave(callback)
	local outsidePt = self.transform.position
	outsidePt.x = self.app.cameraExtents.x + 1.0
	local ltDescr = LeanTween.move(self.gameObject, outsidePt, 1.0)
	ltDescr:setSpeed(3.5)
	ltDescr:setOnComplete(System.Action(callback))
end


-- CourseState_Q1
--------------------------------------------------------------------------------
local CourseState_Q1 = class(CourseState, "CourseState_Q1")

CourseState_Q1.PHASE = {
	START = 1,
	WAIT_PREPARED = 2,
	FINAL = 3,
}

function CourseState_Q1:Start()
	self.videoManager = self.app:g_find("VideoManager")
	self.area_Teacher = self.app:g_find("Area_Teacher")
	self.area_Board   = self.app:g_find("Area_Board")
	self.area_Work    = self.app:g_find("Area_Work")

	self.videoWindow_Teacher = self.area_Teacher.videoWindow
	self.videoWindow_Teacher.emitter:on(VideoWindow.PREPARE_COMPLETED, self.prepareCompleted_Teacher, self)
	self.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)

	self.videoWindow_Board = self.area_Board.videoWindow
	self.videoWindow_Board.emitter:on(VideoWindow.PREPARE_COMPLETED, self.prepareCompleted_Board, self)
	self.videoWindow_Board.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Board, self)

	self.phaseSequence = {
		"Circle",
		"Square",
		"Triangle",
		"Rectangle",
		"Semicircle",
	}
	self.phase = 1
	self.phaseState = CourseState_Q1.PHASE.START
	self.phaseWaitCounter = 0

	self.mapShapeBlock = {
		["Circle"] = { "Circle_Red" },
		["Square"] = { "Square_Blue" },
		["Triangle"] = { "Triangle_Magenta", "Triangle_Yellow" },
		["Rectangle"] = { "Rectangle_DarkBlue", "Rectangle_Red" },
		["Semicircle"] = { "Semicircle_Green", "Semicircle_Orange" },
	}

	self.keyPoints_Teacher = {
		["Circle"] = 9,
		["Square"] = 2,
		["Triangle"] = 3,
		["Rectangle"] = 4,
		["Semicircle"] = 3.5,
	}

	self.animals_Teacher = {
		["Circle"] = "Cock",
		["Square"] = "Bird",
		["Triangle"] = "Hermitcrab",
		["Rectangle"] = "Dog",
		["Semicircle"] = "Fish",
	}
end

function CourseState_Q1:Update()
	if self.phaseState == CourseState_Q1.PHASE.START then
		self.phaseState = CourseState_Q1.PHASE.WAIT_PREPARED

		local shapeName = self.phaseSequence[self.phase]
		local humanClipName = string.format("human_q1%s", string.lower(shapeName))
		local humanClip = self.videoManager:getVideoClip(humanClipName)
		self.videoWindow_Teacher:setTimeReachedCallbackOnce(self.keyPoints_Teacher[shapeName], self.timeReached_Teacher, self)
		self.videoWindow_Teacher:playVideo(humanClip)

	elseif self.phaseState == CourseState_Q1.PHASE.WAIT_PREPARED then

	end
end

function CourseState_Q1:prepareCompleted_Teacher()
	self.area_Teacher:openCurtain()
end

function CourseState_Q1:loopPointReached_Teacher(options)

end

function CourseState_Q1:timeReached_Teacher(options)
	local handClipName = string.format("hand_q1%s", string.lower(self.phaseSequence[self.phase]))
	local handClip = self.videoManager:getVideoClip(handClipName)

	self.videoWindow_Board:setTimeReachedCallbackOnce(1.8, self.timeReached_Board, self)
	self.videoWindow_Board:playVideo(handClip)
end

function CourseState_Q1:prepareCompleted_Board()
	self.area_Board:openCurtain()
end

function CourseState_Q1:loopPointReached_Board(options)

end

function CourseState_Q1:timeReached_Board(options)
	local shapeName = self.phaseSequence[self.phase]
	local blockNames = self.mapShapeBlock[shapeName]
	local blockName = blockNames[MathUtil.randomInt(1,#blockNames)]
	local blockPrefab = self.app:applyFunc("OneBlock", "getBlockPrefab", blockName)

	local go = UObject.Instantiate(blockPrefab)
	go.transform:SetParent(self.transform, false)
	go.transform.position = self.area_Work:getCenterPoint()

	local block = BehaviourUtil.AddBehaviour(go, OneBlock_Custom)
	block:fadeIn(function()
		local changeSmokeEffect = ChangeSmokeEffect()
		changeSmokeEffect.emitter:on(ChangeSmokeEffect.ON_CHANGE, function()
			block:fadeOut(function()
				block:destroy(2.0)
			end)

			local cockPrefab = self.area_Work:getPrefab(self.animals_Teacher[shapeName])
			local cockGo = UObject.Instantiate(cockPrefab)
			cockGo.transform:SetParent(self.transform, false)
			cockGo.transform.position = block.transform.position

			local cock = BehaviourUtil.AddBehaviour(cockGo, Cock)
			cock:delayedCall(2.0, function()
				cock:leave(function()
					cock:destroy(2.0)

					self.phase = self.phase + 1
					if self.phase > #self.phaseSequence then
						self.phaseState = CourseState_Q1.PHASE.FINAL
						self:parallel({
							function(cb) self.area_Teacher:closeCurtain(cb) end,
							function(cb) self.area_Board:closeCurtain(cb) end,
						}, function()
							self.app:g_find("CourseStateMachine"):stateTransition("CourseState_Q2")
						end)
					else
						self.phaseState = CourseState_Q1.PHASE.START
					end
				end)
			end)
			
		end)
		changeSmokeEffect:loadAsync({
			position = block.transform.position
		})
	end)
end

function CourseState_Q1:exit()
	CourseState.exit(self)
	
	self.videoWindow_Teacher.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)

	self.videoWindow_Board.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Board.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

return CourseState_Q1