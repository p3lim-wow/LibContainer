--[[ Event:header
The Event mixin allows easy management of game events and the functions they call once triggered.
--]]

local eventMixin = {}

local function OnEvent(self, ...)
	self:GetParent():TriggerEvent(...)
end

--[[ Event:RegisterEvent(event, handler)
Registers an event which the handler will be triggered for.  
If the handler returns true, Event:UnregisterEvent() will be executed.

* event   - event to register (string)
* handler - handler the event should trigger (function)
--]]
function eventMixin:RegisterEvent(event, handler)
	if(not self.events) then
		self.events = {}
	end

	if(not self.events[event]) then
		self.events[event] = {}

		if(not self.eventHandler) then
			self.eventHandler = CreateFrame('Frame', '$parentEventHandler', self)
			self.eventHandler:SetScript('OnEvent', OnEvent)
		end

		self.eventHandler:RegisterEvent(event)
	end

	self.events[event][handler] = self
end

--[[ Event:UnregisterEvent(event, handler)
Unregisters an event for the given handler.

* event   - event to register (string)
* handler - handler the triggering event (function)
--]]
function eventMixin:UnregisterEvent(event, handler)
	local handlers = self.events[event]
	if(handlers and handlers[handler]) then
		handlers[handler] = nil

		if(not next(handlers)) then
			self.events[event] = nil
			self.eventHandler:UnregisterEvent(event)
		end
	end
end

--[[ Event:TriggerEvent(event[, ...])
Trigger registered handler(s) with the given event and optional parameters.

* event - name of the event to trigger (string)
* ...   - additional parameter(s) to pass to the handler(s) (optional)
--]]
function eventMixin:TriggerEvent(event, ...)
	local handlers = self.events[event]
	if(handlers) then
		for handler, parent in next, handlers do
			if(securecall(handler, parent, ...)) then
				parent:UnregisterEvent(event, handler)
			end
		end
	end
end

LibContainer.mixins.event = eventMixin
