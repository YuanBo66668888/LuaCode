local Btn_Back = class(BaseBehaviour, "Btn_Back")

function Btn_Back:Awake()
	self.luaNotifier = self.gameObject:GetComponent(typeof(LuaNotifier))
	self.luaNotifier:AddListener(LuaNotifier.KEY_ONCLICK, self.onClick, self)
end

function Btn_Back:onClick(args)
	self.app:playClipAtPoint("mainpage/ui_butten_click", Vector3.zero)
	
	self.app:runScene("SelectRealclassScene", {
		transition = "FadeTransition"
	})
end

return Btn_Back