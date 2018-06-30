local callbackMixin = {}
local callbacks = {}
--[[ Callback:Fire(event[, ...])
Triggers a callback with the given event and optional parameters.

* event - name of the event to trigger (string)
* ...   - additional parameter(s) to pass to the callback(s) (optional)
--]]
function callbackMixin:Fire(event, ...)
	if(callbacks[event]) then
		for _, callback in next, callbacks[event] do
			securecall(callback, ...)
		end
	end
end

--[[ Callback:On(event, callback)
Registers a callback for the given event.

* event    - name of the event to register callback for (string)
* callback - function to trigger (function)
--]]
function callbackMixin:On(event, callback)
	if(not callbacks[event]) then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], callback)
end

--[[ Callback:HasCallback(event)
Returns true/false if the given event has any callbacks registered.
--]]
function callbackMixin:HasCallback(event)
	return not not callbacks[event]
end

LibContainer.mixins.callback = callbackMixin
