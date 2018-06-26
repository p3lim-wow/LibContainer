local parentAddOnName = ...

local callbackMixin = LibContainer.mixins.callback
local eventsMixin = LibContainer.mixins.events
local bagSlots = LibContainer.constants.bagSlots

local parentMixin = {}

function parentMixin:GetCategories()
	local categories = CopyTable(LibContainer:GetCategories())
	for key in next, self.categoriesIgnored do
		categories[key] = nil
	end

	return categories
end

local function ADDON_LOADED(self, name)
	if(name ~= parentAddOnName) then
		return
	end

	self:CreateContainers()

	self:UnregisterEvent('ADDON_LOADED')
end

local function BAG_UPDATE(self, bagID)
	local Bag = self:GetBag(bagID)
	if(not Bag) then
		if(not bagSlots[self.containerType][bagID]) then
			-- bag doesn't belong to this container type
			return
		end

		-- create the bag if it doesn't exist
		Bag = self:CreateBag(bagID)
	end

	if(not self:GetBag(BACKPACK_CONTAINER)) then
		-- BAG_UPDATE doesn't ever fire for container 0 on load, trigger it manually
		self:TriggerEvent('BAG_UPDATE', BACKPACK_CONTAINER)
	end

	for slotIndex, Slot in next, Bag:GetSlots() do
		Slot:UpdateVisibility()
	end
end

local function ITEM_LOCK_CHANGED(self, bagID, slotIndex)
	-- TODO: decide if we want dedicated methods to handle lock updates or not (like Blizzard)
	local Bag = self:GetBag(bagID)
	if(Bag) then
		if(slotIndex) then
			Bag:UpdateSlot(slotIndex)
		else
			Bag:UpdateAllSlots()
		end
	end
end

local function BAG_UPDATE_COOLDOWN(self)
	if(self:IsVisible()) then -- try to avoid useless updates
		for bagID, Bag in next, self:GetBags() do
			for slotIndex, Slot in next, Bag:GetSlots() do
				Slot:UpdateCooldown()
			end
		end
	end
end

local function QUEST_ACCEPTED(self)
	for bagID, Bag in next, self:GetBags() do
		Bag:UpdateAllSlots()
	end
end

local function UNIT_QUEST_LOG_CHANGED(self, unit)
	if(unit == 'player') then
		QUEST_ACCEPTED(self)
	end
end

local parents = {}
function LibContainer:New(containerType, name, parent)
	assert(type(containerType) == 'string', 'New: containerType must be a string.')
	containerType = containerType:lower()
	assert(containerType == 'bags' or containerType == 'bank', 'New: containerType must be either \'bags\' or \'bank\'.')
	assert(not parents[containerType], 'New: only one container of the same type may exist.')

	if(name) then
		assert(type(name) == 'string', 'New: name must be a string if used.')
		assert(not _G[name], 'New: object with name already exists.')
	else
		name = string.format('%s_%s', parentAddOnName, containerType:gsub('^%l', string.upper))
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

	local Parent = Mixin(CreateFrame('Frame', name, parent), parentMixin, callbackMixin, eventsMixin)
	Parent:RegisterEvent('ADDON_LOADED', ADDON_LOADED)
	Parent:RegisterEvent('BAG_UPDATE', BAG_UPDATE)
	Parent:RegisterEvent('ITEM_LOCK_CHANGED', ITEM_LOCK_CHANGED)
	Parent:RegisterEvent('BAG_UPDATE_COOLDOWN', BAG_UPDATE_COOLDOWN)
	Parent:RegisterEvent('QUEST_ACCEPTED', QUEST_ACCEPTED)
	Parent:RegisterEvent('UNIT_QUEST_LOG_CHANGED', UNIT_QUEST_LOG_CHANGED)

	if(containerType == 'bank') then
		Parent:RegisterEvent('PLAYERBANKSLOTS_CHANGED', PLAYERBANKSLOTS_CHANGED)
		Parent:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED', PLAYERBANKBAGSLOTS_CHANGED)
		Parent:RegisterEvent('PLAYERREAGENTBANKSLOTS_CHANGED', PLAYERREAGENTBANKSLOTS_CHANGED)
		Parent:RegisterEvent('REAGENTBANK_PURCHASED', REAGENTBANK_PURCHASED)
		Parent:RegisterEvent('BANKFRAME_OPENED', BANKFRAME_OPENED)
		Parent:RegisterEvent('BANKFRAME_CLOSED', BANKFRAME_CLOSED)
	end

	Parent.containerType = containerType
	Parent.categoriesIgnored = {}

	parents[containerType] = Parent
	return Parent
end

LibContainer.mixins.parent = parentMixin
