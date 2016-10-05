local P, E = unpack(select(2, ...))

local Backpack = CreateFrame('Frame', P.name, UIParent)
local Bank = CreateFrame('Frame', '$parentBank', Backpack)
Backpack:Hide()

local modules = {}
function E:ADDON_LOADED(addon)
	if(addon == P.name) then
		BackpackDB = BackpackDB or {}
		BackpackCustomCategory = BackpackCustomCategory or {}
		BackpackKnownItems = BackpackKnownItems or {}

		for _, categoryInfo in next, P.categories do
			P.CreateContainer(categoryInfo, Backpack)
		end

		for _, moduleInfo in next, modules do
			for _, event in next, moduleInfo.events do
				E:RegisterEvent(event, moduleInfo.update)
			end

			moduleInfo.init(Backpack)
		end

		-- Hide on escape
		table.insert(UISpecialFrames, P.name)
	end
end

local callbacks = {}
function P.Fire(event, ...)
	local eventCallbacks = callbacks[event]
	if(eventCallbacks) then
		for _, callback in next, eventCallbacks do
			callback(...)
		end

		if(#eventCallbacks > 0) then
			return true
		end
	end
end

function P.Expose(name, reference)
	Backpack[name] = reference
end

-- @name Backpack:Toggle
-- @usage Backpack:Toggle([alsoBank])
-- @param alsoBank - Boolean to also toggle the bank with the rest of the bags
P.Expose('Toggle', function(alsoBank)
	local isShown = Backpack:IsShown()
	if(not isShown) then
		P.UpdateAllSlots()
	end

	Backpack:SetShown(not isShown)

	if(alsoBank) then
		Bank:SetShown(not isShown)
	end
end)

-- @name Backpack:On
-- @usage Backpack:On(event, callback)
-- @param event    - Event to listen for
-- @param callback - Function that will be called when the event happens
P.Expose('On', function(event, callback)
	if(not callbacks[event]) then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], callback)
end)

function P.AddModule(init, update, ...)
	table.insert(modules, {
		init = init,
		update = update,
		events = {...}
	})
end

P.noop = function() end
