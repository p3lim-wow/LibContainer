local EventHandler = CreateFrame('Frame')

local eventsMixin = {}
local events = {}
--[[ Events:RegisterEvent(event, handler)
Registers an event which the handler will be triggered for.  
If the handler returns true, Events:UnregisterEvent() will be executed.

* event   - event to register (string)
* handler - handler the event should trigger (function)
--]]
function eventsMixin:RegisterEvent(event, handler)
	if(not events[event]) then
		events[event] = {}
		EventHandler:RegisterEvent(event)
	end

	events[event][handler] = self
end

--[[ Events:UnregisterEvent(event, handler)
Unregisters an event for the given handler.

* event   - event to register (string)
* handler - handler the triggering event (function)
--]]
function eventsMixin:UnregisterEvent(event, handler)
	local handlers = events[event]
	if(handlers and handlers[handler]) then
		handlers[handler] = nil

		if(not next(handlers)) then
			events[event] = nil
			EventHandler:UnregisterEvent(event)
		end
	end
end

--[[ Events:TriggerEvent(event[, ...])
Trigger registered handler(s) with the given event and optional parameters.

* event - name of the event to trigger (string)
* ...   - additional parameter(s) to pass to the handler(s) (optional)
--]]
function eventsMixin.TriggerEvent(_, event, ...)
	local handlers = events[event]
	if(handlers) then
		for handler, parent in next, handlers do
			if(securecall(handler, parent, ...)) then
				parent:UnregisterEvent(event, handler)
			end
		end
	end
end

EventHandler:SetScript('OnEvent', eventsMixin.TriggerEvent)

LibContainer.mixins.events = eventsMixin
