local P = unpack(select(2, ...))

local function Update(self)
	local freeSlots, totalSlots = 0, 0
	for bagID = 0, NUM_BAG_FRAMES do
		freeSlots = freeSlots + GetContainerNumFreeSlots(bagID)
		totalSlots = totalSlots + GetContainerNumSlots(bagID)
	end

	Backpack.EmptySlot.Count:SetText(freeSlots)
end

local function OnDrop()
	for bagID = 0, NUM_BAG_FRAMES do
		if(GetContainerNumFreeSlots(bagID) > 0) then
			for slotID = 1, GetContainerNumSlots(bagID) do
				if(not GetContainerItemInfo(bagID, slotID)) then
					PickupContainerItem(bagID, slotID)
					return
				end
			end
		end
	end

	-- BUG: we end up with the container on our cursor if we click the empty slot
end

local function Init(self)
	local Slot = P.CreateSlot(0, 0)
	Slot:SetScript('OnMouseUp', OnDrop)
	Slot:SetScript('OnReceiveDrag', OnDrop)
	Slot:Show()

	-- fake info so we get sorted last
	Slot.itemCount = 0
	Slot.itemQuality = 0
	Slot.itemID = 0
	Slot.itemLevel = 0

	self.EmptySlot = Slot
	P.AddCategorySlot(Slot, P.categories[1])

	Update()
end

P.AddModule(Init, Update, 'BAG_UPDATE')
