local P, E = unpack(select(2, ...))

local Backpack = CreateFrame('Frame', P.name, UIParent)
Backpack:Hide()
P.Mixin(Backpack)

local Bank = CreateFrame('Frame', '$parentBank', Backpack)
Bank:Hide()
Bank:HookScript('OnHide', function()
	if(P.atBank) then
		CloseBankFrame()
	end
end)

local modules = {}
function E:ADDON_LOADED(addon)
	if(addon == P.name) then
		BackpackDB = BackpackDB or {}
		BackpackBankDB = BackpackBankDB or {}
		BackpackCustomCategory = BackpackCustomCategory or {}
		BackpackKnownItems = BackpackKnownItems or {}

		for _, categoryInfo in next, P.categories do
			if(categoryInfo.index ~= 1002) then -- no reagentbank for inventory
				P.CreateContainer(categoryInfo, Backpack)
			end

			P.CreateContainer(categoryInfo, Bank)
		end

		for _, moduleInfo in next, modules do
			for _, event in next, moduleInfo.events do
				E:RegisterEvent(event, moduleInfo.update)
			end

			moduleInfo.init(Backpack)

			if(moduleInfo.includeBank) then
				moduleInfo.init(Bank)
			end
		end

		-- Hide on escape
		table.insert(UISpecialFrames, P.name)

		-- might interfere, disable just in case
		SetBackpackAutosortDisabled(true)

		if(not IsReagentBankUnlocked()) then
			E:RegisterEvent('REAGENTBANK_PURCHASED', P.UpdateAllSlots)
		end

		return true
	end
end

function E:BANKFRAME_OPENED()
	P.atBank = true
	Backpack:Toggle(true, true)
end

function E:BANKFRAME_CLOSED()
	P.atBank = false
	Backpack:Toggle(false)
end

local callbacks = {}
function P.Fire(event, ...)
	local eventCallbacks = callbacks[event]
	if(eventCallbacks) then
		for _, callback in next, eventCallbacks do
			callback(...)
		end
	end
end

local layouts = {}
function P.Layout(event, ...)
	local eventLayout = layouts[event]
	if(eventLayout) then
		eventLayout(...)
		return true
	end
end

function P.Expose(name, reference)
	Backpack[name] = reference
end

-- @name Backpack:Toggle
-- @usage Backpack:Toggle([force])
-- @param force - Boolean to force open/close the bags
P.Expose('Toggle', function(self, force, includeBank)
	local isShown = self:IsShown()
	if(not isShown and force ~= false) then
		if(not isShown) then
			P.UpdateAllSlots('OnShow')
			P.PositionSlots()
		end

		self:Show()

		if(includeBank) then
			Bank:Show()
		end
	elseif(isShown and not force) then
		self:Hide()
		Bank:Hide()
	end
end)

-- @name Backpack:On
-- @usage Backpack:On(event, callback)
-- @param event    - Event to listen for
-- @param callback - Function that will be called when the event happens
P.Expose('On', function(self, event, callback)
	if(not callbacks[event]) then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], callback)
end)

-- @name Backpack:Layout
-- @usage Backpack:Layout(event, callback)
-- @param event    - Layout event
-- @param callback - Function that will be called when the event happens
P.Expose('Layout', function(self, event, callback)
	if(layouts[event]) then
		P.error('Layout already exists.')
	else
		layouts[event] = callback
	end
end)

function P.AddModule(init, update, includeBank, ...)
	table.insert(modules, {
		init = init,
		update = update,
		includeBank = includeBank,
		events = {...}
	})
end

P.noop = function() end
