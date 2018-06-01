local CourseStateMachine = class(BaseBehaviour, "CourseStateMachine")

function CourseStateMachine:Awake()
	self.currentState = nil

	self.states = {}
	self.orders = {}
end

function CourseStateMachine:stateTransition(stateMix, ...)
	local oldState = self.currentState

	local stateType = nil
	if type(stateMix) == "string" then
		stateType = self.states[stateMix]
	else
		stateType = stateMix
	end

	self.currentState = BehaviourUtil.AddBehaviour(self.gameObject, stateType, self)

	if oldState ~= nil then
		oldState:exit()
	end

	self.currentState:enter(...)

	if oldState ~= nil then
		oldState:destroySelf()
	end

	return self.currentState
end

function CourseStateMachine:addState(stateType)
	self.states[stateType.__name__] = stateType
	table.insert(self.orders, stateType.__name__)
end

function CourseStateMachine:getPrevStateName()
    local currentIndex  = table.indexOf(self.orders, self.currentState.__name__)
    local index = currentIndex - 1

    return (index >= 1 and index <= #self.orders) and self.orders[index] or nil
end

function CourseStateMachine:getNextStateName()
	local currentIndex  = table.indexOf(self.orders, self.currentState.__name__)
    local index = currentIndex + 1

    return (index >= 1 and index <= #self.orders) and self.orders[index] or nil
end

return CourseStateMachine