local EventHandler = CreateFrame('Frame')

local eventMixin = {}
local event = {}
--[[ Event:RegisterEvent(event, handler)
Registers an event which the handler will be triggered for.  
If the handler returns true, Event:UnregisterEvent() will be executed.

* event   - event to register (string)
* handler - handler the event should trigger (function)
--]]
function eventMixin:RegisterEvent(event, handler)
	if(not event[event]) then
		event[event] = {}
		EventHandler:RegisterEvent(event)
	end

	event[event][handler] = self
end

--[[ Event:UnregisterEvent(event, handler)
Unregisters an event for the given handler.

* event   - event to register (string)
* handler - handler the triggering event (function)
--]]
function eventMixin:UnregisterEvent(event, handler)
	local handlers = event[event]
	if(handlers and handlers[handler]) then
		handlers[handler] = nil

		if(not next(handlers)) then
			event[event] = nil
			EventHandler:UnregisterEvent(event)
		end
	end
end

--[[ Event:TriggerEvent(event[, ...])
Trigger registered handler(s) with the given event and optional parameters.

* event - name of the event to trigger (string)
* ...   - additional parameter(s) to pass to the handler(s) (optional)
--]]
function eventMixin.TriggerEvent(_, event, ...)
	local handlers = event[event]
	if(handlers) then
		for handler, parent in next, handlers do
			if(securecall(handler, parent, ...)) then
				parent:UnregisterEvent(event, handler)
			end
		end
	end
end

EventHandler:SetScript('OnEvent', eventMixin.TriggerEvent)

LibContainer.mixins.event = eventMixin
