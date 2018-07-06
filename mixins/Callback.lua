--[[ Callback:header
The Callback mixin allows for simple callback triggers throughout the entirety of LibContainer,
and is the primary method for layouts to hook into and modify many aspects of the framework.
--]]

local callbackMixin = {}
--[[ Callback:Fire(event[, ...])
Triggers a callback with the given event and optional parameters.

* event - name of the event to trigger (string)
* ...   - additional parameter(s) to pass to the callback(s) (optional)
--]]
function callbackMixin:Fire(event, ...)
	if(not self.callbacks) then
		self.callbacks = {}
	end

	if(self.callbacks[event]) then
		for _, callback in next, self.callbacks[event] do
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
	if(not self.callbacks) then
		self.callbacks = {}
	end

	if(not self.callbacks[event]) then
		self.callbacks[event] = {}
	end

	table.insert(self.callbacks[event], callback)
end

--[[ Callback:HasCallback(event)
Returns true/false if the given event has any callbacks registered.
--]]
function callbackMixin:HasCallback(event)
	return not not (self.callbacks and self.callbacks[event])
end

LibContainer.mixins.callback = callbackMixin
