local Area_Board   		 = require "game.realclass.Area_Board"
local Area_Teacher 		 = require "game.realclass.Area_Teacher"
local Area_Work			 = require "game.realclass.Area_Work"
local CourseStateMachine = require "game.realclass.base.CourseStateMachine"
local CourseState_Intro  = require "game.realclass.CourseState_Intro"
local CourseState_Q1     = require "game.realclass.CourseState_Q1"
local CourseState_Q2     = require "game.realclass.CourseState_Q2"
local CourseState_Q3     = require "game.realclass.CourseState_Q3"
local CourseState_Final  = require "game.realclass.CourseState_Final"
local VideoManager		 = require "game.realclass.VideoManager"
local OneBlockService    = require "game.service.OneBlockService"
local LabelTable		 = require "game.conf.LabelTable"
local Btn_Back			 = require "game.realclass.Btn_Back"
local LabelManager 	  = require "game.universal.LabelManager"

local RealclassScene = class(BaseScene, "RealclassScene")

RealclassScene.sceneBundleName = "scene_realclass"

function RealclassScene:enter(callback)
	self.app:playMusic(UCamera.main.gameObject, "backmusic_miaokid_class_low", {volume = 0.2})

	BehaviourUtil.AddBehaviour(UGameObject.Find("UI/Btn_Back"), Btn_Back)
	self:set("Area_Board", BehaviourUtil.AddBehaviour(UGameObject.Find("Area_Board"), Area_Board))
	self:set("Area_Teacher", BehaviourUtil.AddBehaviour(UGameObject.Find("Area_Teacher"), Area_Teacher))
	self:set("Area_Work", BehaviourUtil.AddBehaviour(UGameObject.Find("Area_Work"), Area_Work))
	self:set("VideoManager", BehaviourUtil.AddBehaviour(UGameObject.Find("VideoManager"), VideoManager))

	local courseStateMachine = BehaviourUtil.AddBehaviour(UGameObject.Find("CourseStateMachine"), CourseStateMachine)
	courseStateMachine:addState(CourseState_Intro)
	courseStateMachine:addState(CourseState_Q1)
	courseStateMachine:addState(CourseState_Q2)
	courseStateMachine:addState(CourseState_Q3)
	courseStateMachine:addState(CourseState_Final)
	self:set("CourseStateMachine", courseStateMachine)

	async.waterfall({
        function(cb)
            self:addService(OneBlockService()):loadAsync(nil, cb)
        end,
    }, function()
    	self.app:addListener(EventConsts.Main_OnInput, self.onInput, self)
		self.app:addListener(EventConsts.Block_OnSelected, self.onSelected, self)
		BehaviourUtil.AddBehaviour(UGameObject("LabelManager"), LabelManager)
    	BaseScene.enter(self, callback)
	end)
end

function RealclassScene:exit(callback)
	self.app:removeListener(EventConsts.Main_OnInput, self.onInput, self)
	self.app:removeListener(EventConsts.Block_OnSelected, self.onSelected, self)
	IOSToUnity.openIdentify()
	BaseScene.exit(self, callback)
end

function RealclassScene:afterEnter()
	self:get("CourseStateMachine"):stateTransition("CourseState_Intro")
	IOSToUnity.closeIdentify()
    AnimateTween.delayCall(0.5, function() 
        IOSToUnity.openIdentify()
    end)
end

function RealclassScene:onInput(labels)
	for _, blockName in pairs(labels) do
		local options = nil
		if LabelTable.getBlockType(blockName) == "Number" then
			local blockNumber = tonumber(blockName)
			if blockNumber >= 1 and blockNumber <= 9 then
				options = { priority = true }
			end
		end
		self.app:applyFunc("OneBlock", "inputBlock", blockName, options)
	end
end

function RealclassScene:onSelected(block)
	local currentState = self:get("CourseStateMachine").currentState
	if currentState then
		currentState:onSelected(block)
	else
		async.waterfall({
			function(cb) block:shrink(cb) end,
		}, function()
			self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity)
		end)
	end
end

return RealclassScene