local parentMixin = LibContainer.mixins.parent
local bagSizes = LibContainer.constants.bagSizes

local bagMixin = {}
--[[ Bag:GetSlot(slotIndex)
Returns the Slot object by index.

* slotIndex - index of the slot (integer)
--]]
function bagMixin:GetSlot(slotIndex)
	return self.slots[slotIndex]
end

--[[ Bag:UpdateSlots()
Updates all slots.
--]]
function bagMixin:UpdateSlots()
	for slotIndex = 1, self.size do
		self:GetSlot(slotIndex):UpdateVisibility()
	end
end

--[[ Bag:UpdateCooldowns()
Updates the cooldown frame of all visible slots.
--]]
function bagMixin:UpdateCooldowns()
	for slotIndex = 1, self.size do
		self:GetSlot(slotIndex):UpdateCooldown()
	end
end

--[[ Bag:UpdateSize()
Updates the amount of slots the bag contains.
--]]
function bagMixin:UpdateSize()
	self.size = GetContainerNumSlots(self:GetID())
end

--[[ Parent:CreateBag(bagID)
Creates and returns a new bag for the Parent.

* bagID - identifier for the bag to create (integer)
--]]
function parentMixin:CreateBag(bagID)
	local Bag = Mixin(CreateFrame('Frame', '$parentBag' .. bagID, self), bagMixin)
	Bag:SetID(bagID)
	Bag:UpdateSize()
	Bag:SetSize(1, 1) -- needs a size for child frames to even show up
	Bag.slots = {}

	if(not self.bags) then
		self.bags = {}
	end
	self.bags[bagID] = Bag

	for slotIndex = 1, bagSizes[bagID] do
		Bag:CreateSlot(slotIndex)
	end

	self:Fire('PostCreateBag', Bag)

	return Bag
end

--[[ Parent:GetBag(bagID)
Returns the bag by identifier.

* bagID - identifier for the bag (integer)
--]]
function parentMixin:GetBag(bagID)
	return self.bags and self.bags[bagID]
end

--[[ Parent:GetBags()
Returns a table of all bags on the Parent.  
The table is indexed by the bag identifier and valued with the Bag object.
--]]
function parentMixin:GetBags()
	return self.bags
end

LibContainer.mixins.bag = bagMixin
