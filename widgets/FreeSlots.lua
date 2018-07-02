local parentMixin = LibContainer.mixins.parent
--[[ FreeSlots:header
This widget adds a "fake" [Slot](Slot) to the Intentory [Category](Category).
This Slot serves two purposes:
1. Displaying the number of free slots left in the player's inventory as the item count text
2. Putting items into this slot will place them in the first free inventory slot available

See [Parent:AddFreeSlot()](Parent#parentaddfreeslot).
--]]

local function OnDrop(Slot)
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		if(GetContainerNumFreeSlots(bagID) > 0) then
			for slotIndex = 1, GetContainerNumSlots(bagID) do
				if(not GetContainerItemInfo(bagID, slotIndex)) then
					PickupContainerItem(bagID, slotIndex)
					return
				end
			end
		end
	end
end

local function Update(self)
	local Slot = self:GetBag(0):GetSlot(99)
	Slot.Count:SetText(CalculateTotalNumberOfFreeBagSlots())
end

local function AddFauxSlot(Bag)
	if(Bag:GetID() == BACKPACK_CONTAINER) then
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
