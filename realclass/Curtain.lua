local Curtain = class(BaseBehaviour, "Curtain")

function Curtain:Awake()
	local openPt = self.transform.position
	openPt.y = openPt.y + 3.0

	self.cache = {
		closePt = self.transform.position,
		openPt = openPt,
	}
end

function Curtain:open(callback)
	local ltDescr = LeanTween.move(self.gameObject, self.cache.openPt, 0.3)
	ltDescr:setEase(LeanTweenType.easeOutQuad)
	ltDescr:setOnComplete(System.Action(callback))
end

function Curtain:close(callback)
	local ltDescr = LeanTween.move(self.gameObject, self.cache.closePt, 0.3)
	ltDescr:setEase(LeanTweenType.easeOutQuad)
	ltDescr:setOnComplete(System.Action(callback))
end

return Curtain