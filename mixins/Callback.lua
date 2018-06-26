local callbackMixin = {}
local callbacks = {}
function callbackMixin:Fire(event, ...)
	if(callbacks[event]) then
		for _, callback in next, callbacks[event] do
			securecall(callback, ...)
		end
	end
end

function callbackMixin:On(event, callback)
	if(not callbacks[event]) then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], callback)
end

function callbackMixin:HasCallback(event)
	return not not callbacks[event]
end

LibContainer.mixins.callback = callbackMixin
