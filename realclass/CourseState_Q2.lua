local VideoWindow 		= require "game.realclass.VideoWindow"
local CourseState 		= require "game.realclass.base.CourseState"
local CourseSubstate    = require "game.realclass.base.CourseSubstate"
local ChangeSmokeEffect = require "game.universal.effects.ChangeSmokeEffect"
local OneBlock_Custom   = require "game.realclass.OneBlock_Custom"

local _mapShapeBlock = {
	["Circle"] = { "Circle_Red" },
	["Square"] = { "Square_Blue" },
	["Triangle"] = { "Triangle_Magenta", "Triangle_Yellow" },
	["Rectangle"] = { "Rectangle_DarkBlue", "Rectangle_Red" },
	["Semicircle"] = { "Semicircle_Green", "Semicircle_Orange" },
}

function _fadeIn(go, cb)
	go:SetActive(true)

	local spriteRenderer = go:GetComponent(typeof(USpriteRenderer))
	local col = spriteRenderer.color; col.a = 0
	spriteRenderer.color = col

	local ltDescr = LeanTween.alpha(go, 1, 0.3)
	ltDescr:setOnComplete(System.Action(cb))
end

function _fadeOut(go, cb)
	go:SetActive(true)

	local ltDescr = LeanTween.alpha(go, 0, 0.3)
	ltDescr:setOnComplete(System.Action(cb))
end


-- CourseSubstate_Circle
--------------------------------------------------------------------------------
local CourseSubstate_Circle = class(CourseSubstate, "CourseSubstate_Circle")

function CourseSubstate_Circle:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	self.videoManager = self.app:g_find("VideoManager")
end

function CourseSubstate_Circle:enter(parentState)
	self.parentState = parentState

	local humanClipName = "human_q2circle"
	local humanClip = self.videoManager:getVideoClip(humanClipName)
	parentState.videoWindow_Teacher:playVideo(humanClip)
	parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(15, self.timeReached_Teacher, self)
	parentState.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)
end

function CourseSubstate_Circle:exit()
	self.parentState.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)

	self.block:fadeOut()

	self:parallel({
		function(cb)
			self:_fadeOut(self.rootTr:Find("Clock").gameObject, cb)
		end,
		function(cb)
			self:_fadeOut(self.rootTr:Find("Dash").gameObject, cb)
		end,
	}, function()
		if self.rootGo then
			UObject.Destroy(self.rootGo)
		end
	end)
end

function CourseSubstate_Circle:loopPointReached_Teacher(options)
	local vPlayer = options.vPlayer
	local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
	local frameCount = tonumber(tostring(vPlayer.frameCount))
	if frame > frameCount * 0.9 then -- The frame count is larger than 1200
		self.stateMachine:stateTransition("CourseSubstate_Rectangle", self.parentState)
	end
end

function CourseSubstate_Circle:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))

	if time < 15 + 3 then
		self:fadeIn()
		self.parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(25, self.timeReached_Teacher, self)
	elseif time < 25 + 3 then
		local handClipName = "hand_q1circle"
		local handClip = self.videoManager:getVideoClip(handClipName)

		self.parentState.videoWindow_Board:setTimeReachedCallbackOnce(1.8, self.timeReached_Board, self)
		self.parentState.videoWindow_Board:playVideo(handClip)
	end
end

function CourseSubstate_Circle:timeReached_Board(options)
	local quesTr = self.rootTr:Find("Question")

	local changeSmokeEffect = ChangeSmokeEffect()
	changeSmokeEffect.emitter:on(ChangeSmokeEffect.ON_CHANGE, function()
		self:_fadeOut(quesTr.gameObject)

		local shapeName = "Circle"
		local blockNames = _mapShapeBlock[shapeName]
		local blockName = blockNames[MathUtil.randomInt(1,#blockNames)]
		local blockPrefab = self.app:applyFunc("OneBlock", "getBlockPrefab", blockName)

		local go = UObject.Instantiate(blockPrefab)
		go.transform:SetParent(self.rootTr, false)
		go.transform.localScale = go.transform.localScale * 0.6
		go.transform.position = quesTr.position

		self.block = BehaviourUtil.AddBehaviour(go, OneBlock_Custom)
		self.block:fadeIn()
	end)
	changeSmokeEffect:loadAsync({
		position = quesTr.position
	})
end

function CourseSubstate_Circle:fadeIn(callback)
	local fadeIn_ = function(go, cb)
		go:SetActive(true)

		local spriteRenderer = go:GetComponent(typeof(USpriteRenderer))
		local col = spriteRenderer.color; col.a = 0
		spriteRenderer.color = col

		local ltDescr = LeanTween.alpha(go, 1, 0.3)
		ltDescr:setOnComplete(System.Action(cb))
	end

	self:parallel({
		function(cb)
			fadeIn_(self.rootTr:Find("Clock").gameObject, cb)
		end,
		function(cb)
			fadeIn_(self.rootTr:Find("Dash").gameObject, cb)
		end,
		function(cb)
			fadeIn_(self.rootTr:Find("Question").gameObject, cb)
		end,
	}, function()
		if callback then callback() end
	end)
end

function CourseSubstate_Circle:_fadeIn(go, cb)
	go:SetActive(true)

	local spriteRenderer = go:GetComponent(typeof(USpriteRenderer))
	local col = spriteRenderer.color; col.a = 0
	spriteRenderer.color = col

	local ltDescr = LeanTween.alpha(go, 1, 0.3)
	ltDescr:setOnComplete(System.Action(cb))
end

function CourseSubstate_Circle:_fadeOut(go, cb)
	go:SetActive(true)

	local ltDescr = LeanTween.alpha(go, 0, 0.3)
	ltDescr:setOnComplete(System.Action(cb))
end


-- CourseSubstate_Rectangle
--------------------------------------------------------------------------------
local CourseSubstate_Rectangle = class(CourseSubstate, "CourseSubstate_Rectangle")

CourseSubstate_Rectangle.INIT = 0
CourseSubstate_Rectangle.WAIT = 1

function CourseSubstate_Rectangle:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	self.videoManager = self.app:g_find("VideoManager")

	self.localState = CourseSubstate_Rectangle.INIT
end

function CourseSubstate_Rectangle:enter(parentState)
	self.parentState = parentState

	self.humanClipName = "human_q2rectangle"
	local humanClipName = "human_q2rectangle"
	local humanClip = self.videoManager:getVideoClip(humanClipName)
	parentState.videoWindow_Teacher:playVideo(humanClip)
	parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(3.5, self.timeReached_Teacher, self)
	parentState.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)
end

function CourseSubstate_Rectangle:exit()
	if self.block then
		self.block:fadeOut()
	end

	self:parallel({
		function(cb)
			_fadeOut(self.rootTr:Find("Bus").gameObject, cb)
		end,
		function(cb)
			_fadeOut(self.rootTr:Find("Dash").gameObject, cb)
		end,
	}, function()
		
	end)

	self.parentState.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseSubstate_Rectangle:loopPointReached_Teacher(options)
	local vPlayer = options.vPlayer
	local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
	local frameCount = tonumber(tostring(vPlayer.frameCount))
	if frame > frameCount * 0.9 then -- The frame count is larger than 1200

		if self.humanClipName == "human_q2rectangle" then
			self.localState = CourseSubstate_Rectangle.WAIT
		elseif self.humanClipName == "human_q2rectangleright" then
			self.stateMachine:stateTransition("CourseSubstate_Triangle", self.parentState)
		end
	end
end

function CourseSubstate_Rectangle:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))

	if time < 3.5 + 3 then
		self:fadeIn()
	end
end

function CourseSubstate_Rectangle:onSelected(block)
	if self.localState == CourseSubstate_Rectangle.WAIT then
		local blockName = block.blockName

		if string.sub(blockName, 1, 9) == "Rectangle" then
			self.humanClipName = "human_q2rectangleright"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)

			local quesTr = self.rootTr:Find("Question")
			_fadeOut(quesTr.gameObject)

			self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity, true)
			self.block = block

			self:parallel({
				function(cb)
					local ltDescr = LeanTween.move(block.gameObject, quesTr.position, 0.5)
					ltDescr:setEase(LeanTweenType.easeOutQuad)
					ltDescr:setOnComplete(System.Action(cb))
				end,
				function(cb)
					local ltDescr = LeanTween.scale(block.gameObject, Vector3.one * 0.6, 0.5)
					ltDescr:setOnComplete(System.Action(cb))
				end,
			}, function()

			end)
		else
			CourseSubstate.onSelected(self, block)

			self.humanClipName = "human_q2rectanglewrong"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)
		end
	else
		CourseSubstate.onSelected(self, block)
	end
end

function CourseSubstate_Rectangle:fadeIn(callback)
	self:parallel({
		function(cb)
			_fadeIn(self.rootTr:Find("Bus").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Dash").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Question").gameObject, cb)
		end,
	}, function()
		if callback then callback() end
	end)
end


-- CourseSubstate_Triangle
--------------------------------------------------------------------------------
local CourseSubstate_Triangle = class(CourseSubstate, "CourseSubstate_Triangle")

CourseSubstate_Triangle.INIT = 0
CourseSubstate_Triangle.WAIT = 1

function CourseSubstate_Triangle:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	self.videoManager = self.app:g_find("VideoManager")

	self.localState = CourseSubstate_Triangle.INIT
end

function CourseSubstate_Triangle:enter(parentState)
	self.parentState = parentState

	self.humanClipName = "human_q2triangle"
	local humanClipName = "human_q2triangle"
	local humanClip = self.videoManager:getVideoClip(humanClipName)
	parentState.videoWindow_Teacher:playVideo(humanClip)
	parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(3.5, self.timeReached_Teacher, self)
	parentState.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)
end

function CourseSubstate_Triangle:exit()
	if self.block then
		self.block:fadeOut()
	end

	self:parallel({
		function(cb)
			_fadeOut(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeOut(self.rootTr:Find("Dash").gameObject, cb)
		end,
	}, function()
		
	end)

	self.parentState.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseSubstate_Triangle:loopPointReached_Teacher(options)
	local vPlayer = options.vPlayer
	local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
	local frameCount = tonumber(tostring(vPlayer.frameCount))
	if frame > frameCount * 0.9 then -- The frame count is larger than 1200

		if self.humanClipName == "human_q2triangle" then
			self.localState = CourseSubstate_Triangle.WAIT
		elseif self.humanClipName == "human_q2triangleright" then
			self.stateMachine:stateTransition("CourseSubstate_Square", self.parentState)
		end
	end
end

function CourseSubstate_Triangle:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))

	if time < 3.5 + 3 then
		self:fadeIn()
	end
end

function CourseSubstate_Triangle:onSelected(block)
	if self.localState == CourseSubstate_Triangle.WAIT then
		local blockName = block.blockName

		if string.sub(blockName, 1, 8) == "Triangle" then
			self.humanClipName = "human_q2triangleright"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)

			local quesTr = self.rootTr:Find("Question")
			_fadeOut(quesTr.gameObject)

			self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity, true)
			self.block = block

			self:parallel({
				function(cb)
					local ltDescr = LeanTween.move(block.gameObject, quesTr.position, 0.5)
					ltDescr:setEase(LeanTweenType.easeOutQuad)
					ltDescr:setOnComplete(System.Action(cb))
				end,
				function(cb)
					local ltDescr = LeanTween.scale(block.gameObject, Vector3.one * 0.6, 0.5)
					ltDescr:setOnComplete(System.Action(cb))
				end,
			}, function()

			end)
		else
			CourseSubstate.onSelected(self, block)

			self.humanClipName = "human_q2trianglewrong"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)
		end
	else
		CourseSubstate.onSelected(self, block)
	end
end

function CourseSubstate_Triangle:fadeIn(callback)
	self:parallel({
		function(cb)
			_fadeIn(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Dash").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Question").gameObject, cb)
		end,
	}, function()
		if callback then callback() end
	end)
end


-- CourseSubstate_Square
--------------------------------------------------------------------------------
local CourseSubstate_Square = class(CourseSubstate, "CourseSubstate_Square")

CourseSubstate_Square.INIT = 0
CourseSubstate_Square.WAIT = 1

function CourseSubstate_Square:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	self.videoManager = self.app:g_find("VideoManager")

	self.localState = CourseSubstate_Square.INIT
end

function CourseSubstate_Square:enter(parentState)
	self.parentState = parentState

	self.humanClipName = "human_q2square"
	local humanClipName = "human_q2square"
	local humanClip = self.videoManager:getVideoClip(humanClipName)
	parentState.videoWindow_Teacher:playVideo(humanClip)
	parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(3.5, self.timeReached_Teacher, self)
	parentState.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)
end

function CourseSubstate_Square:exit()
	if self.block then
		self.block:fadeOut()
	end

	self:parallel({
		function(cb)
			_fadeOut(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeOut(self.rootTr:Find("Dash").gameObject, cb)
		end,
	}, function()
		
	end)

	self.parentState.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseSubstate_Square:loopPointReached_Teacher(options)
	local vPlayer = options.vPlayer
	local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
	local frameCount = tonumber(tostring(vPlayer.frameCount))
	if frame > frameCount * 0.9 then -- The frame count is larger than 1200

		if self.humanClipName == "human_q2square" then
			self.localState = CourseSubstate_Square.WAIT
		elseif self.humanClipName == "human_q2squareright" then
			self.stateMachine:stateTransition("CourseSubstate_Semicircle", self.parentState)
		end
	end
end

function CourseSubstate_Square:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))

	if time < 3.5 + 3 then
		self:fadeIn()
	end
end

function CourseSubstate_Square:onSelected(block)
	if self.localState == CourseSubstate_Square.WAIT then
		local blockName = block.blockName

		if string.sub(blockName, 1, 6) == "Square" then
			self.humanClipName = "human_q2squareright"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)

			local quesTr = self.rootTr:Find("Question")
			_fadeOut(quesTr.gameObject)

			self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity, true)
			self.block = block

			self:parallel({
				function(cb)
					local ltDescr = LeanTween.move(block.gameObject, quesTr.position, 0.5)
					ltDescr:setEase(LeanTweenType.easeOutQuad)
					ltDescr:setOnComplete(System.Action(cb))
				end,
				function(cb)
					local ltDescr = LeanTween.scale(block.gameObject, Vector3.one * 0.6, 0.5)
					ltDescr:setOnComplete(System.Action(cb))
				end,
			}, function()

			end)
		else
			CourseSubstate.onSelected(self, block)

			self.humanClipName = "human_q2squarewrong"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)
		end
	else
		CourseSubstate.onSelected(self, block)
	end
end

function CourseSubstate_Square:fadeIn(callback)
	self:parallel({
		function(cb)
			_fadeIn(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Dash").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Question").gameObject, cb)
		end,
	}, function()
		if callback then callback() end
	end)
end


-- CourseSubstate_Semicircle
--------------------------------------------------------------------------------
local CourseSubstate_Semicircle = class(CourseSubstate, "CourseSubstate_Semicircle")

CourseSubstate_Semicircle.INIT = 0
CourseSubstate_Semicircle.WAIT = 1

function CourseSubstate_Semicircle:Awake()
	self.luaParameter = self.gameObject:GetComponent(typeof(LuaParameter))
	
	local rootPrefab = self.luaParameter:getGameObject(self.__name__)
	self.rootGo = UObject.Instantiate(rootPrefab)
	self.rootGo.transform:SetParent(self.transform, false)
	self.rootTr = self.rootGo.transform

	self.videoManager = self.app:g_find("VideoManager")

	self.localState = CourseSubstate_Semicircle.INIT
end

function CourseSubstate_Semicircle:enter(parentState)
	self.parentState = parentState

	self.humanClipName = "human_q2semicircle"
	local humanClipName = "human_q2semicircle"
	local humanClip = self.videoManager:getVideoClip(humanClipName)
	parentState.videoWindow_Teacher:playVideo(humanClip)
	parentState.videoWindow_Teacher:setTimeReachedCallbackOnce(3.5, self.timeReached_Teacher, self)
	parentState.videoWindow_Teacher.emitter:on(VideoWindow.LOOP_POINT_REACHED, self.loopPointReached_Teacher, self)
end

function CourseSubstate_Semicircle:exit()
	if self.block then
		self.block:fadeOut()
	end

	self:parallel({
		function(cb)
			_fadeOut(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeOut(self.rootTr:Find("Dash").gameObject, cb)
		end,
	}, function()
		
	end)

	self.parentState.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseSubstate_Semicircle:loopPointReached_Teacher(options)
	local vPlayer = options.vPlayer
	local frame = tonumber(tostring(vPlayer.frame)) -- @NOTE: frame is type of long
	local frameCount = tonumber(tostring(vPlayer.frameCount))
	if frame > frameCount * 0.9 then -- The frame count is larger than 1200

		if self.humanClipName == "human_q2semicircle" then
			self.localState = CourseSubstate_Semicircle.WAIT
		elseif self.humanClipName == "human_q2semicircleright" then
			self.stateMachine:stateTransition("CourseSubstate_Final", self.parentState)
		end
	end
end

function CourseSubstate_Semicircle:timeReached_Teacher(options)
	local vPlayer = options.vPlayer
	local time = tonumber(tostring(vPlayer.time))

	if time < 3.5 + 3 then
		self:fadeIn()
	end
end

function CourseSubstate_Semicircle:onSelected(block)
	if self.localState == CourseSubstate_Semicircle.WAIT then
		local blockName = block.blockName

		if string.sub(blockName, 1, 10) == "Semicircle" then
			self.humanClipName = "human_q2semicircleright"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)

			local quesTr = self.rootTr:Find("Question")
			_fadeOut(quesTr.gameObject)

			self.app:applyFunc("OneBlock", "removeBlock", block.blockIdentity, true)
			self.block = block

			self:parallel({
				function(cb)
					local ltDescr = LeanTween.move(block.gameObject, quesTr.position, 0.5)
					ltDescr:setEase(LeanTweenType.easeOutQuad)
					ltDescr:setOnComplete(System.Action(cb))
				end,
				function(cb)
					local ltDescr = LeanTween.scale(block.gameObject, Vector3.one * 0.6, 0.5)
					ltDescr:setOnComplete(System.Action(cb))
				end,
			}, function()

			end)
		else
			CourseSubstate.onSelected(self, block)

			self.humanClipName = "human_q2semicirclewrong"
			local humanClip = self.videoManager:getVideoClip(self.humanClipName)
			self.parentState.videoWindow_Teacher:playVideo(humanClip)
		end
	else
		CourseSubstate.onSelected(self, block)
	end
end

function CourseSubstate_Semicircle:fadeIn(callback)
	self:parallel({
		function(cb)
			_fadeIn(self.rootTr:Find("Cake").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Dash").gameObject, cb)
		end,
		function(cb)
			_fadeIn(self.rootTr:Find("Question").gameObject, cb)
		end,
	}, function()
		if callback then callback() end
	end)
end

-- CourseSubstate_Final
--------------------------------------------------------------------------------
local CourseSubstate_Final = class(CourseSubstate, "CourseSubstate_Final")

function CourseSubstate_Final:Start()
	self.app:g_find("CourseStateMachine"):stateTransition("CourseState_Final")
end


-- CourseState_Q2
--------------------------------------------------------------------------------
local CourseState_Q2 = class(CourseState, "CourseState_Q2")

function CourseState_Q2:Awake()
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

function CourseState_Q2:prepareCompleted_Teacher()
	self.area_Teacher:openCurtain()
end

function CourseState_Q2:prepareCompleted_Board()
	self.area_Board:openCurtain()
end

function CourseState_Q2:loopPointReached_Board(options)

end

function CourseState_Q2:enter()
	CourseState.enter(self)
	self:delayedCall(0.2, function()
		self.area_Teacher:openCurtain()
	end)

	self.substateMachine:addState(CourseSubstate_Circle)
	self.substateMachine:addState(CourseSubstate_Rectangle)
	self.substateMachine:addState(CourseSubstate_Triangle)
	self.substateMachine:addState(CourseSubstate_Square)
	self.substateMachine:addState(CourseSubstate_Semicircle)
	self.substateMachine:addState(CourseSubstate_Final)
	self.substateMachine:stateTransition("CourseSubstate_Circle", self)
end

function CourseState_Q2:exit()
	CourseState.exit(self)

	self.videoWindow_Teacher.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Teacher.emitter:off(VideoWindow.LOOP_POINT_REACHED)

	self.videoWindow_Board.emitter:off(VideoWindow.PREPARE_COMPLETED)
	self.videoWindow_Board.emitter:off(VideoWindow.LOOP_POINT_REACHED)
end

function CourseState_Q2:onSelected(block)
	local currentSubstate = self.substateMachine.currentState
	if currentSubstate then
		currentSubstate:onSelected(block)
	else
		CourseState.onSelected(self, block)
	end
end

return CourseState_Q2