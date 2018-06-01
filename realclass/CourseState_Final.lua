local VideoWindow = require "game.realclass.VideoWindow"
local CourseState = require "game.realclass.base.CourseState"

local CourseState_Final = class(CourseState, "CourseState_Final")

function CourseState_Final:Start()
	self.videoManager = self.app:g_find("VideoManager")
	self.area_Teacher = self.app:g_find("Area_Teacher")
	self.area_Board   = self.app:g_find("Area_Board")

	local clip_end = self.videoManager:getVideoClip("human_end")
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
				self.app:runScene("SelectRealclassScene", {
					transition = "FadeTransition"
				})
			end)
		end
	end)
	self.videoWindow_Teacher:playVideo(clip_end)
end

return CourseState_Final