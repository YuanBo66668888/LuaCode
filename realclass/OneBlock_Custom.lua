-- OneBlock_Custom
--------------------------------------------------------------------------------
local OneBlock_Custom = class(BaseBehaviour, "OneBlock_Custom")

function OneBlock_Custom:Awake()
	self.modelGo = self.transform:Find("Model").gameObject
	self.modelSpriteRenderer = self.modelGo:GetComponent(typeof(USpriteRenderer))
	local modelCol = self.modelSpriteRenderer.color; modelCol.a = 0
	self.modelSpriteRenderer.color = modelCol

	self.boardGo = self.transform:Find("Board").gameObject
	self.boardSpineUtil = GetOrAddComponent(typeof(SpineUtil), self.boardGo)
	self.boardSpineUtil.Alpha = 0
end

function OneBlock_Custom:fadeIn(callback)
	self:parallel({
		function(cb)
			local ltDescr = LeanTween.alpha(self.modelGo, 1, 0.3)
			ltDescr:setOnComplete(System.Action(cb))
		end,
		function(cb)
			local ltDescr = LeanTween.value(self.boardGo, 0, 1, 0.3)
			LeanTweenUtil.SetOnUpdate(ltDescr, function(value)
				self.boardSpineUtil.Alpha = value
			end)
			ltDescr:setOnComplete(System.Action(cb))
		end,
	}, function()
		if callback then callback() end
	end)
end

function OneBlock_Custom:fadeOut(callback)
	self:parallel({
		function(cb)
			local ltDescr = LeanTween.alpha(self.modelGo, 0, 0.3)
			ltDescr:setOnComplete(System.Action(cb))
		end,
		function(cb)
			local ltDescr = LeanTween.value(self.boardGo, 1, 0, 0.3)
			LeanTweenUtil.SetOnUpdate(ltDescr, function(value)
				self.boardSpineUtil.Alpha = value
			end)
			ltDescr:setOnComplete(System.Action(cb))
		end,
	}, function()
		if callback then callback() end
	end)
end

return OneBlock_Custom