local P, E = unpack(select(2, ...))

local Backpack = CreateFrame('Frame', P.name, UIParent)
Backpack:Hide()
P.MixinAPI(Backpack)

local Bank = CreateFrame('Frame', '$parentBank', Backpack)
Bank:Hide()
Bank:HookScript('OnHide', function()
	if(P.atBank) then
		CloseBankFrame()
	end
end)

local modules = {}
function E:ADDON_LOADED(event, addon)
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

			if(moduleInfo.init) then
				moduleInfo.init(Backpack)

				if(moduleInfo.includeBank) then
					moduleInfo.init(Bank)
				end
			end
		end

		if(Backpack:GetContainerNumSlots(BANK_CONTAINER) > 0) then
			P.InitializeBank()
		end

		-- Hide on escape
		table.insert(UISpecialFrames, P.name)

		-- might interfere, disable just in case
		SetBackpackAutosortDisabled(true)

		return true
	end
end

function E:BAG_UPDATE(event, bagID)
	if(not P.HasParent(BACKPACK_CONTAINER)) then
		-- doesn't seem to have its own event
		P.InitializeAllSlots(BACKPACK_CONTAINER)
	end

	if(not P.HasParent(bagID)) then
		P.InitializeAllSlots(bagID)
	end

	P.UpdateContainerSlots(bagID, event)
	P.PositionSlots()
end

function E:ITEM_LOCK_CHANGED(event, bagID, slotID)
	if(slotID) then
		P.UpdateSlot(bagID, slotID, event)
	else
		P.UpdateContainerSlots(bagID, event)
	end

	P.PositionSlots()
end

function E:BAG_UPDATE_COOLDOWN()
	if(Backpack:IsVisible()) then
		P.UpdateContainerCooldowns(BACKPACK_CONTAINER, NUM_BAG_SLOTS)
	end

	if(BackpackBank:IsVisible()) then
		P.UpdateContainerCooldowns(BANK_CONTAINER)
		P.UpdateContainerCooldowns(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
	end
end

function E:QUEST_ACCEPTED(event)
	P.UpdateAllSlots(event)
end

function E:UNIT_QUEST_LOG_CHANGED(event, unit)
	if(unit == 'player') then
		P.UpdateAllSlots(event)
	end
end

function E:PLAYERBANKSLOTS_CHANGED(event, slotID)
	P.UpdateSlot(BANK_CONTAINER, slotID, event)
	P.PositionSlots()
end

function E:PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
	P.UpdateSlot(REAGENTBANK_CONTAINER, slotID, event)
	P.PositionSlots()
end

local function REAGENTBANK_PURCHASED(event)
	P.InitializeAllSlots(REAGENTBANK_CONTAINER)
	P.UpdateContainerSlots(REAGENTBANK_CONTAINER, event)
	P.PositionSlots()

	return true
end

function P.InitializeBank()
	P.InitializeAllSlots(BANK_CONTAINER)

	for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		P.InitializeAllSlots(bagID)
	end

	if(IsReagentBankUnlocked()) then
		P.InitializeAllSlots(REAGENTBANK_CONTAINER)
	else
		E:RegisterEvent('REAGENTBANK_PURCHASED', REAGENTBANK_PURCHASED)
	end
end

function E:BANKFRAME_OPENED()
	P.atBank = true

	if(not P.HasParent(BANK_CONTAINER)) then
		P.InitializeBank()
	end

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
	local shouldShow, shouldShowBank

	local isShown = self:IsShown()
	if(((not isShown and force ~= false) or force) and not (isShown and not force)) then
		shouldShow = true
	end

	if(includeBank and not Bank:IsShown() and Backpack:GetContainerNumSlots(BANK_CONTAINER) > 0) then
		shouldShowBank = true
	end

	if(shouldShow or shouldShowBank) then
		if(not isShown) then
			P.UpdateAllSlots('OnShow')
			P.PositionSlots()
		end

		self:Show()

		if(shouldShowBank) then
			Bank:Show()
		end
	elseif(not shouldShow) then
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
