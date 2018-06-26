local EventHandler = CreateFrame('Frame')

local eventsMixin = {}
local events = {}
function eventsMixin:RegisterEvent(event, handler)
	if(not events[event]) then
		events[event] = {}
		EventHandler:RegisterEvent(event)
	end

	events[event][handler] = self
end

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
