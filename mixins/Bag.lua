local parentMixin = LibContainer.mixins.parent
local bagSizes = LibContainer.constants.bagSizes

local bagMixin = {}
function bagMixin:GetSlot(slotIndex)
	return self.slots[slotIndex]
end

function bagMixin:UpdateSlots()
	for slotIndex = 1, self.size do
		self:GetSlot(slotIndex):UpdateVisibility()
	end
end

function bagMixin:UpdateCooldowns()
	for slotIndex = 1, self.size do
		self:GetSlot(slotIndex):UpdateCooldown()
	end
end

function bagMixin:UpdateSize()
	self.size = GetContainerNumSlots(self:GetID())
end

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

function parentMixin:GetBag(bagID)
	return self.bags and self.bags[bagID]
end

function parentMixin:GetBags()
	return self.bags
end

LibContainer.mixins.bag = bagMixin
