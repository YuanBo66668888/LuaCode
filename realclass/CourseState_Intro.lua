local VideoWindow = require "game.realclass.VideoWindow"
local CourseState = require "game.realclass.base.CourseState"
local OneBlock_Custom   = require "game.realclass.OneBlock_Custom"

local CourseState_Intro = class(CourseState, "CourseState_Intro")

CourseState_Intro.phaseSequence = {
	"Circle",
	"Square",
	"Triangle",
	"Rectangle",
	"Semicircle",
}

CourseState_Intro.keyPoints = {
	["Circle"] = 7,
	["Square"] = 17,
	["Triangle"] = 23,
	["Rectangle"] = 33,
	["Semicircle"] = 43,
}

local _mapShapeBlock = {
	["Circle"] = { "Circle_Red" },
	["Square"] = { "Square_Blue" },
	["Triangle"] = { "Triangle_Magenta", "Triangle_Yellow" },
	["Rectangle"] = { "Rectangle_DarkBlue", "Rectangle_Red" },
	["Semicircle"] = { "Semicircle_Green", "Semicircle_Orange" },
}

function CourseState_Intro:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
end

function CourseState_Intro:Start()
	self.videoManager = self.app:g_find("VideoManager")
	self.area_Teacher = self.app:g_find("Area_Teacher")
	self.area_Board   = self.app:g_find("Area_Board")

	local clip_Opening = self.videoManager:getVideoClip("human_opening")
	self.videoWindow_Teacher = self.area_Teacher.videoWindow
	self.videoWindow_Teacher.emitter:on(VideoWindow.PREPARE_COMPLETED, function()
		self.videoWindow_Teacher.emitter:off(VideoWindow.PREPARE_COMPLETED)
		self.area_Teacher:openCurtain()
	end)
	self.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, function(options)
		self.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)

		local vPlayer = options.vPlayer
		local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
		local frameCount = tonumber(tostring(vPlayer.frameCount))
		if frame > frameCount * 0.9 then -- The frame count is larger than 1200
			self.area_Teacher:closeCurtain(function()
				self.app:g_find("CourseStateMachine"):stateTransition("CourseState_Q1")
			end)
		end
	end)
	self.videoWindow_Teacher:playVideo(clip_Opening)

	self.phase = 1
	local shapeName = CourseState_Intro.phaseSequence[self.phase]
	self.videoWindow_Teacher:setTimeReachedCallbackOnce(CourseState_Intro.keyPoints[shapeName], self.timeReached_Teacher, self)

	self.blocks = {}
end

function CourseState_Intro:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))
	
	local shapeName = CourseState_Intro.phaseSequence[self.phase]
	if time < CourseState_Intro.keyPoints[shapeName] + 1.0 then
		local blockNames = _mapShapeBlock[shapeName]
		local blockName = blockNames[MathUtil.randomInt(1,#blockNames)]
		local blockPrefab = self.app:applyFunc("OneBlock", "getBlockPrefab", blockName)

		local go = UObject.Instantiate(blockPrefab)
		go.transform:SetParent(self.rootTr, false)
		go.transform.position = self.rootTr:Find(shapeName).position
		go.transform.localScale = self.rootTr:Find(shapeName).localScale
		
		local block = BehaviourUtil.AddBehaviour(go, OneBlock_Custom)
		table.insert(self.blocks, block)

		block:fadeIn()

		self.phase = self.phase + 1
		if self.phase <= #CourseState_Intro.phaseSequence then
			shapeName = CourseState_Intro.phaseSequence[self.phase]
			self.videoWindow_Teacher:setTimeReachedCallbackOnce(CourseState_Intro.keyPoints[shapeName], self.timeReached_Teacher, self)
		end
	end
end

function CourseState_Intro:enter()
	print("CourseState_Intro > enter")
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	CourseState.enter(self)
end

function CourseState_Intro:exit()
	self:forEach(self.blocks, function(block, cb)
		block:fadeOut(cb)
	end, function()
		if self.rootGo then
			UObject.Destroy(self.rootGo)
		end
	end)
end

return CourseState_Intro