local parentAddOnName = ...

local callbackMixin = LibContainer.mixins.callback
local eventMixin = LibContainer.mixins.event
local bagSlots = LibContainer.constants.bagSlots

--[[ Parent:header
The Parent mixin is the lowest object the layout has to interact with.  
The layout would typically want to create two separate parents - one for bags, one for bank.  
Once created, the Parent serves as the ground layer for the entirety of LibContainer, and it's
where the layout starts to adjust preferences and hook into the rest of the mixins with [Callbacks](Callback).
--]]

local parentMixin = {}
--[[ Parent:GetCategories()
Returns a (filtered) table of all categories.  
The table is indexed by the category index and valued with the Category data table.

Any categories that has been ignored on the Parent will not be included.
--]]
function parentMixin:GetCategories()
	local categories = CopyTable(LibContainer:GetCategories())
	for _, index in next, self.categoriesIgnored do
		categories[index] = nil
	end

	return categories
end

--[[ Parent:DisableCategories(...)
Disables one or more categories by name from the Parent containers.

* ... - category name(s) (string)
--]]
function parentMixin:DisableCategories(...)
	for index = 1, select('#', ...) do
		local name = select(index, ...)
		local category = LibContainer:GetCategoryByName(name)
		assert(category, 'Category \'' .. name .. '\' doesn\'t exist.')
		table.insert(self.categoriesIgnored, category.index)
	end
end

--[[ Parent:GetType()
Returns 'bags' or 'bank' depending on which type of parent it is.  
See [LibContainer:New()](LibContainer#libcontainernew).
--]]
function parentMixin:GetType()
	return self.parentType
end

local function ADDON_LOADED(self, name)
	if(name ~= parentAddOnName) then
		return
	end

	self:CreateContainers()

	self:UnregisterEvent('ADDON_LOADED')
end

local function PLAYER_LOGIN(self)
	if(not self:GetBag(BACKPACK_CONTAINER)) then
		-- BAG_UPDATE doesn't ever fire for container 0 on load, trigger it manually
		self:TriggerEvent('BAG_UPDATE', BACKPACK_CONTAINER)
	end
end

local function BAG_UPDATE(self, bagID)
	if(not bagSlots[self:GetType()][bagID]) then
		-- bag doesn't belong to this container type
		return
	end

	if(not self:GetBag(bagID)) then
		-- create the bag if it doesn't exist
		self:CreateBag(bagID)
	end

	-- running updates on every BAG_UPDATE has severe performance issues, especially
	-- when this event occurs multiple times in quick succession.
	-- we cache the bags that were updated (dirty) and let them update once the
	-- barrage of events are over
	self.dirtyBags[bagID] = true
end

local function BAG_UPDATE_DELAYED(self)
	-- this event always fires after BAG_UPDATE(s) are done, a perfect time to
	-- perform updates on "dirty" bags
	for bagID in next, self.dirtyBags do
		self:GetBag(bagID):UpdateSlots()
	end

	-- we'll only update containers once all the slots are done updating.
	-- this is because we mark slots as "dirty" in the same fashion as with bags to
	-- avoid unneccessary updates to containers
	self:UpdateContainers()

	table.wipe(self.dirtyBags)
end

local function ITEM_LOCK_CHANGED(self, bagID, slotIndex)
	local Bag = self:GetBag(bagID)
	if(Bag) then
		if(slotIndex) then
			local Slot = Bag:GetSlot(slotIndex)
			if(Slot) then
				Slot:UpdateLock()
			end
		end
	end
end

local function BAG_UPDATE_COOLDOWN(self)
	if(self:IsVisible()) then -- try to avoid useless updates
		for bagID, Bag in next, self:GetBags() do
			Bag:UpdateCooldowns()
		end
	end
end

local function QUEST_ACCEPTED(self)
	for bagID, Bag in next, self:GetBags() do
		Bag:UpdateSlots()
	end
end

local function UNIT_QUEST_LOG_CHANGED(self, unit)
	if(unit == 'player') then
		self:TriggerEvent('QUEST_ACCEPTED')
	end
end

local function MODIFIER_STATE_CHANGED(self)
	-- update the Slot tooltip on modifier change instead of waiting for OnUpdate
	local obj = GameTooltip:GetOwner()
	if(obj and obj:GetParent() and obj:GetParent():GetParent()) then
		if(obj:GetParent():GetParent() == self) then
			obj:UpdateTooltip()
		end
	end
end

local function PLAYERBANKSLOTS_CHANGED(self, slotIndex)
	local Bag = self:GetBag(BANK_CONTAINER)
	if(Bag) then
		if(slotIndex > NUM_BANKGENERIC_SLOTS) then
			-- a bank bag slot was changed, need to mark it as dirty
			local bagID = slotIndex - NUM_BANKGENERIC_SLOTS + NUM_BAG_SLOTS
			self.dirtyBags[bagID] = true
		else
			local Slot = Bag:GetSlot(slotIndex)
			if(Slot) then
				Slot:UpdateVisibility()
				self:UpdateContainers()
			end
		end
	end
end

local function PLAYERREAGENTBANKSLOTS_CHANGED(self, slotIndex)
	local Bag = self:GetBag(REAGENTBANK_CONTAINER)
	if(Bag) then
		Bag:GetSlot(slotIndex):UpdateVisibility()
		self:UpdateContainers()
	end
end

local function REAGENTBANK_PURCHASED(self)
	local Bag = self:GetBag(REAGENTBANK_CONTAINER)
	if(not Bag) then
		Bag = self:CreateBag(REAGENTBANK_CONTAINER)
	end

	Bag:UpdateSlots()
	self:UpdateContainers()
end

local function BANKFRAME_OPENED(self)
	local Bag = self:GetBag(BANK_CONTAINER)
	if(not Bag) then
		Bag = self:CreateBag(BANK_CONTAINER)

		if(IsReagentBankUnlocked()) then
			REAGENTBANK_PURCHASED(self)
		else
			self:RegisterEvent('REAGENTBANK_PURCHASED', REAGENTBANK_PURCHASED)
		end
	end

	Bag:UpdateSlots()
	self:UpdateContainers()

	for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		-- BAG_UPDATE doesn't fire for bank bags when visiting the bank, so we need to trigger it
		-- to create and update the bags (marking them as "dirty")
		self:TriggerEvent('BAG_UPDATE', bagID)
	end

	-- since the bank bags are now marked as "dirty" we need to update them
	self:TriggerEvent('BAG_UPDATE_DELAYED')
end

local parents = {}
--[[ LibContainer:New(parentType[, name][, parent])
Creates and returns a new Parent.

* parentType - type of Parent to represent (string, 'bags'|'bank')
* name          - name of the Parent (string, optional, default = parent AddOn name + parentType)
* parent        - parent for the Parent frame (frame|string, optional, default = UIParent)
--]]
function LibContainer:New(parentType, name, parent)
	assert(type(parentType) == 'string', 'New: parentType must be a string.')
	parentType = parentType:lower()
	assert(parentType == 'bags' or parentType == 'bank', 'New: parentType must be either \'bags\' or \'bank\'.')
	assert(not parents[parentType], 'New: only one container of the same type may exist.')

	if(name) then
		assert(type(name) == 'string', 'New: name must be a string if used.')
		assert(not _G[name], 'New: object with name already exists.')
	else
		name = string.format('%s_%s', parentAddOnName, parentType:gsub('^%l', string.upper))
	end

	if(parent) then
		if(type(parent) == 'string') then
			assert(_G[parent], 'New: parent must exist if used.')
		else
			assert(type(parent) == 'table', 'New: parent must be a frame if used.')
		end
	else
		parent = UIParent
	end

	local Parent = Mixin(CreateFrame('Frame', name, parent), parentMixin, callbackMixin, eventMixin)
	Parent:SetSize(1, 1) -- needs a size for child frames to even show up
	Parent:RegisterEvent('ADDON_LOADED', ADDON_LOADED)
	Parent:RegisterEvent('PLAYER_LOGIN', PLAYER_LOGIN)
	Parent:RegisterEvent('BAG_UPDATE', BAG_UPDATE)
	Parent:RegisterEvent('BAG_UPDATE_DELAYED', BAG_UPDATE_DELAYED)
	Parent:RegisterEvent('ITEM_LOCK_CHANGED', ITEM_LOCK_CHANGED)
	Parent:RegisterEvent('BAG_UPDATE_COOLDOWN', BAG_UPDATE_COOLDOWN)
	Parent:RegisterEvent('QUEST_ACCEPTED', QUEST_ACCEPTED)
	Parent:RegisterEvent('UNIT_QUEST_LOG_CHANGED', UNIT_QUEST_LOG_CHANGED)
	Parent:RegisterEvent('MODIFIER_STATE_CHANGED', MODIFIER_STATE_CHANGED)

	if(parentType == 'bank') then
		Parent:RegisterEvent('PLAYERBANKSLOTS_CHANGED', PLAYERBANKSLOTS_CHANGED)
		Parent:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED', PLAYERREAGENTBANKSLOTS_CHANGED)
		Parent:RegisterEvent('REAGENTBANK_PURCHASED', REAGENTBANK_PURCHASED)
		Parent:RegisterEvent('BANKFRAME_OPENED', BANKFRAME_OPENED)
	end

	Parent.parentType = parentType
	Parent.categoriesIgnored = {}
	Parent.dirtyBags = {}

	parents[parentType] = Parent
	return Parent
end

LibContainer.mixins.parent = parentMixin
