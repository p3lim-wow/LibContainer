local P = unpack(select(2, ...))

local emptySlots = {}

local function GetFreeSlots(containerID)
	local freeSlots = 0
	if(containerID == BACKPACK_CONTAINER) then
		for bagID = containerID, NUM_BAG_SLOTS do
			freeSlots = freeSlots + Backpack:GetContainerNumFreeSlots(bagID)
		end
	elseif(containerID == BANK_CONTAINER and (P.atBank or BackpackBankDB ~= nil)) then
		freeSlots = Backpack:GetContainerNumFreeSlots(containerID)

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			freeSlots = freeSlots + Backpack:GetContainerNumFreeSlots(bagID)
		end
	elseif(containerID == REAGENTBANK_CONTAINER and (P.atBank or BackpackBankDB ~= nil)) then
		freeSlots = Backpack:GetContainerNumFreeSlots(containerID)
	end

	return freeSlots
end

local function Update(self)
	for _, EmptySlot in next, emptySlots do
		local freeSlots = GetFreeSlots(EmptySlot.bagID)
		EmptySlot.Count:SetText(freeSlots)
	end
end

local function GetContainerEmptySlot(bagID)
	if(Backpack:GetContainerNumFreeSlots(bagID) > 0) then
		for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
			if(not Backpack:GetContainerItemInfo(bagID, slotID)) then
				return bagID, slotID
			end
		end
	end
end

local function GetEmptySlot(containerID)
	if(containerID == BACKPACK_CONTAINER) then
		for index = containerID, NUM_BAG_SLOTS do
			local bagID, slotID = GetContainerEmptySlot(index)
			if(slotID) then
				return bagID, slotID
			end
		end
	elseif(containerID == BANK_CONTAINER) then
		local bagID, slotID = GetContainerEmptySlot(containerID)
		if(slotID) then
			return bagID, slotID
		end

		for index = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			local bagID, slotID = GetContainerEmptySlot(index)
			if(slotID) then
				return bagID, slotID
			end
		end
	elseif(containerID == REAGENTBANK_CONTAINER) then
		local bagID, slotID = GetContainerEmptySlot(containerID)
		if(slotID) then
			return bagID, slotID
		end
	end
end

local function OnDrop(self)
	PickupContainerItem(GetEmptySlot(self.bagID))
	-- BUG: we end up with the container on our cursor if we click the empty slot
end

local function CreateEmptySlot(bagID, categoryIndex)
	local Slot = P.CreateSlot(bagID, 0)
	Slot:SetScript('OnMouseUp', OnDrop)
	Slot:SetScript('OnReceiveDrag', OnDrop)
	Slot:Show()

	-- fake info so we get sorted last
	Slot.itemCount = 0
	Slot.itemQuality = 0
	Slot.itemID = 0
	Slot.itemLevel = 0

	P.AddCategorySlot(Slot, P.categories[categoryIndex])

	table.insert(emptySlots, Slot)

	return Slot
end

local function Init(self)
	Backpack.EmptySlot = CreateEmptySlot(BACKPACK_CONTAINER, 1)
	BackpackBank.EmptySlot = CreateEmptySlot(BANK_CONTAINER, 1)
	BackpackBankContainerReagentBank.EmptySlot = CreateEmptySlot(REAGENTBANK_CONTAINER, 1002)

	Update()
end

P.AddModule(Init, Update, false, 'BAG_UPDATE', 'BANKFRAME_OPENED')
