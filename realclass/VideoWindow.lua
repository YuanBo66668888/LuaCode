local VideoWindow = class(BaseBehaviour, "VideoWindow")

VideoWindow.PREPARE_COMPLETED = "Prepared_Completed"
VideoWindow.LOOP_POINT_REACHED = "Loop_Point_Reached"
VideoWindow.TIME_REACHED = "Time_Reached"

function VideoWindow:Awake()
	self.audioSource = self.gameObject:GetComponent(typeof(UAudioSource))
	self.videoPlayer = self.gameObject:GetComponent(typeof(UVideoPlayer))
	self.videoPlayer:SetTargetAudioSource(0, self.audioSource)

	self.videoPlayerUtil = GetOrAddComponent(typeof(VideoPlayerUtil), self.gameObject)
	self.videoPlayerUtil:AddListener(VideoPlayerUtil.PREPARE_COMPLETED, self.prepareCompleted, self)
	self.videoPlayerUtil:AddListener(VideoPlayerUtil.LOOP_POINT_REACHED, self.loopPointReached, self)
end

function VideoWindow:Update()
	if self.emitter:has(VideoWindow.TIME_REACHED) then
		if self.videoPlayer.time >= self.reachedTime then
			self.emitter:emit(VideoWindow.TIME_REACHED, {
				vPlayer = self.videoPlayer
			})
			-- This means that reachedTime does not change
			if self.videoPlayer.time >= self.reachedTime then
				self.emitter:off(VideoWindow.TIME_REACHED)
			end
		end
	end
end

function VideoWindow:prepareCompleted(args)
	-- self.videoPlayer.time = 0
	self.videoPlayer:Play()
	self.emitter:emit(VideoWindow.PREPARE_COMPLETED)
end

-- @NOTE: Sometimes the callback is invoked before video reaches the end. Don't
-- know why?
function VideoWindow:loopPointReached(args)
	self.emitter:emit(VideoWindow.LOOP_POINT_REACHED, {
		vPlayer = self.videoPlayer
	})
end

function VideoWindow:playVideo(videoClip)
	if self.videoPlayer.clip == videoClip then
		-- self.videoPlayer.time = 0
		self.videoPlayer:Play()
		-- self.emitter:emit(VideoWindow.PREPARE_COMPLETED)
	else
		-- self.videoPlayer.time = 0
		self.videoPlayer.clip = videoClip
		self.videoPlayer:Prepare()
	end
end

function VideoWindow:setTimeReachedCallbackOnce(reachedTime, listener, obj)
	self.reachedTime = reachedTime
	self.emitter:on(VideoWindow.TIME_REACHED, listener, obj)
end

return VideoWindow