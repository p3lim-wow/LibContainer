local parentMixin = LibContainer.mixins.parent
local bagSizes = LibContainer.constants.bagSizes

--[[ Bag:header
The Bag mixin is a mostly transparent object. It serves as the parent for [Slots](Slot), and as
a "proxy" between the [Parent](Parent) and the [Slot](Slot) for events and updates.

The main reason for its existance is to allow 3rd-party addons to easily attach to the [Slots](Slot)
in each container and get predictable information through Slot parent identifiers.
--]]

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
	local numSlots = GetContainerNumSlots(self:GetID())
	for slotIndex = 1, numSlots do
		self:GetSlot(slotIndex):UpdateVisibility()
	end

	if(self.size > numSlots) then
		for slotIndex = math.max(numSlots, 1), bagSizes[self:GetID()] do
			self:GetSlot(slotIndex):Hide()
		end
	end

	self.size = numSlots
end

--[[ Bag:UpdateCooldowns()
Updates the cooldown frame of all visible slots.
--]]
function bagMixin:UpdateCooldowns()
	for slotIndex = 1, GetContainerNumSlots(self:GetID()) do
		self:GetSlot(slotIndex):UpdateCooldown()
	end
end

--[[ Parent:CreateBag(bagID)
Creates and returns a new bag for the Parent.

* bagID - identifier for the bag to create (integer)
--]]
function parentMixin:CreateBag(bagID)
	local Bag = Mixin(CreateFrame('Frame', '$parentBag' .. bagID, self), bagMixin)
	Bag:SetID(bagID)
	Bag:SetSize(1, 1) -- needs a size for child frames to even show up
	Bag.slots = {}
	Bag.size = 0

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
