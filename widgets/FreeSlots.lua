local parentMixin = LibContainer.mixins.parent
--[[ FreeSlots:header
This widget adds a "fake" [Slot](Slot) to the bags' or bank's Inventory [Category](Category).
This Slot serves two purposes:
1. Displaying the number of free slots left in the player's inventory as the item count text
2. Putting items into this slot will place them in the first free inventory slot available

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:AddFreeSlot()
```
--]]

local function GetContainerEmptySlot(bagID)
	for slotIndex = 1, GetContainerNumSlots(bagID) do
		if(not GetContainerItemID(bagID, slotIndex)) then
			return slotIndex
		end
	end
end

local function GetEmptySlot(bagID)
	if(bagID == BACKPACK_CONTAINER) then
		for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local slotIndex = GetContainerEmptySlot(bagID)
			if(slotIndex) then
				return bagID, slotIndex
			end
		end
	elseif(bagID == BANK_CONTAINER) then
		local slotIndex = GetContainerEmptySlot(bagID)
		if(slotIndex) then
			return bagID, slotIndex
		end

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			local slotIndex = GetContainerEmptySlot(bagID)
			if(slotIndex) then
				return bagID, slotIndex
			end
		end
	end
end

local function OnDrop(Slot)
	local bagID, slotIndex = GetEmptySlot((Slot:GetBagAndSlot()))
	if(slotIndex) then
		PickupContainerItem(bagID, slotIndex)
	end
end

local function GetNumFreeSlots(bagID)
	if(bagID == BACKPACK_CONTAINER) then
		return CalculateTotalNumberOfFreeBagSlots()
	elseif(bagID == BANK_CONTAINER) then
		local numFreeSlots = GetContainerNumFreeSlots(bagID)
		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			numFreeSlots = numFreeSlots + GetContainerNumFreeSlots(bagID)
		end
		return numFreeSlots
	end
end

local function UpdateCount(self, bagID)
	local Bag = self:GetBag(bagID)
	if(Bag) then
		local Slot = Bag:GetSlot(99)
		if(Slot) then
			Slot.Count:SetText(GetNumFreeSlots(bagID))
		end
	end
end

local function Update(self)
	local containerType = self:GetType()
	if(containerType == 'bags') then
		UpdateCount(self, BACKPACK_CONTAINER)
	else
		UpdateCount(self, BANK_CONTAINER)
	end
end

local function AddFauxSlot(Bag)
	local containerType = Bag:GetParent():GetType()
	local bagID = Bag:GetID()
	if((containerType == 'bags' and bagID == BACKPACK_CONTAINER) or
		(containerType == 'bank' and bagID == BANK_CONTAINER)) then
		-- create a faux slot way outside the bounds of the backpack container
		local Slot = Bag:CreateSlot(99)
		Slot:SetScript('OnMouseUp', OnDrop)
		Slot:SetScript('OnReceiveDrag', OnDrop)
		Slot:Show()
		Slot.Hide = nop

		-- fake info so it gets sorted last
		Slot.itemCount = 0
		Slot.itemQuality = 0
		Slot.itemID = 0
		Slot.itemLevel = 0

		local Parent = Bag:GetParent()
		Parent:GetContainer(1):AddSlot(Slot)
		Update(Parent)
	end
end

--[[ Parent:AddFreeSlot()
Adds a [Free Slots](FreeSlots) widget to the Inventory [Container](Container).
--]]
function parentMixin:AddFreeSlot()
	self:On('PostCreateBag', AddFauxSlot)
	self:RegisterEvent('BAG_UPDATE_DELAYED', Update)
end
