local P, E = unpack(select(2, ...))
P.categorySlots = {}

local parents, slots = {}, {}
local function CreateParent(bagID)
	local parentContainer
	if(bagID < 0 or bagID > 4) then
		parentContainer = BackpackBank
	else
		parentContainer = Backpack
	end

	local Parent = CreateFrame('Frame', '$parentBag' .. bagID, parentContainer)
	Parent:SetID(bagID)

	parents[bagID] = Parent
	slots[bagID] = {}

	return Parent
end

function P.CreateSlot(bagID, slotID)
	local Parent = parents[bagID] or CreateParent(bagID)
	local Slot = CreateFrame('Button', '$parentSlot' .. slotID, Parent, 'ContainerFrameItemButtonTemplate')
	local slotName = Slot:GetName()

	Slot:SetID(slotID)
	Slot.slotID = slotID
	Slot.bagID = bagID
	Slot.parentContainer = Parent:GetParent()

	-- make sure all the subframes have keys
	Slot.Icon = _G[slotName .. 'IconTexture']
	Slot.Count = _G[slotName .. 'Count']
	Slot.NormalTexture = Slot:GetNormalTexture()
	Slot.PushedTexture = Slot:GetPushedTexture()
	Slot.HighlightTexture = Slot:GetHighlightTexture()
	Slot.QuestIcon = _G[slotName .. 'IconQuestTexture']
	Slot.JunkIcon = Slot.JunkIcon
	Slot.Flash = Slot.flash
	Slot.NewItem = Slot.NewItemTexture
	Slot.BattlePay = Slot.BattlepayItemTexture
	Slot.Cooldown = _G[slotName .. 'Cooldown']

	if(not P.Fire('SkinSlot', Slot)) then
		P.SkinSlot(Slot)
	end

	slots[bagID][slotID] = Slot

	return Slot
end

function P.GetSlot(bagID, slotID)
	return slots[bagID] and slots[bagID][slotID]
end

function P.UpdateSlot(bagID, slotID, event)
	if(GetContainerItemInfo(bagID, slotID)) then
		local itemID = GetContainerItemID(bagID, slotID)

		local category = P.GetCategory(bagID, slotID, itemID)
		local categoryIndex = category.index

		local Slot = P.GetSlot(bagID, slotID) or P.CreateSlot(bagID, slotID)
		local slotCategoryIndex = Slot.categoryIndex
		if(slotCategoryIndex ~= categoryIndex) then
			if(slotCategoryIndex) then
				P.RemoveCategorySlot(Slot)
				P.RemoveContainerSlot(Slot)
			end

			P.AddCategorySlot(Slot, category)
			P.AddContainerSlot(Slot, P.GetCategoryContainer(Slot.parentContainer, categoryIndex))
		end

		-- for the sorting methods
		local _, itemCount, _, itemQuality = GetContainerItemInfo(bagID, slotID)
		Slot.itemCount = itemCount
		Slot.itemQuality = itemQuality
		Slot.itemID = itemID
		Slot.itemLevel = select(4, GetItemInfo(GetContainerItemLink(bagID, slotID)))

		if(not P.Override('UpdateSlot', Slot)) then
			P.OnUpdateSlot(Slot, bagID, slotID)
		end

		Slot:Show()

		P.Fire('PostUpdateSlot', bagID, slotID, event)
	else
		local Slot = P.GetSlot(bagID, slotID)
		if(Slot and Slot:IsShown()) then
			P.RemoveCategorySlot(Slot)
			P.RemoveContainerSlot(Slot)

			Slot.itemCount = nil
			Slot.itemQuality = nil
			Slot.itemID = nil
			Slot.itemLevel = nil
			Slot:Hide()

			P.Fire('PostRemoveSlot', bagID, slotID, event)
		end
	end
end

function P.UpdateContainerSlots(bagID, event)
	for slotID = 1, GetContainerNumSlots(bagID) do
		P.UpdateSlot(bagID, slotID, event)
	end
end

local initialized
function P.UpdateAllSlots(event)
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		P.UpdateContainerSlots(bagID)
	end

	if(P.atBank) then
		P.UpdateContainerSlots(BANK_CONTAINER)

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			P.UpdateContainerSlots(bagID)
		end
	end

	if(not initialized) then
		E:RegisterEvent('BAG_UPDATE', P.BAG_UPDATE)
		E:RegisterEvent('ITEM_LOCK_CHANGED', P.ITEM_LOCK_CHANGED)
		E:RegisterEvent('BAG_UPDATE_COOLDOWN', P.BAG_UPDATE_COOLDOWN)
		E:RegisterEvent('QUEST_ACCEPTED', P.QUEST_ACCEPTED)
		E:RegisterEvent('UNIT_QUEST_LOG_CHANGED', P.UNIT_QUEST_LOG_CHANGED)
		E:RegisterEvent('PLAYERBANKSLOTS_CHANGED', P.PLAYERBANKSLOTS_CHANGED)

		initialized = true
	end
end

function P.AddCategorySlot(Slot, category)
	local categoryIndex = category.index
	Slot.category = category
	Slot.categoryIndex = categoryIndex

	local container = Slot.parentContainer
	if(not P.categorySlots[container]) then
		P.categorySlots[container] = {}
	end

	if(not P.categorySlots[container][categoryIndex]) then
		P.categorySlots[container][categoryIndex] = {}
	end

	table.insert(P.categorySlots[container][categoryIndex], Slot)
end

function P.RemoveCategorySlot(Slot)
	local categorySlots = P.categorySlots[Slot.parentContainer][Slot.categoryIndex]
	for index = #categorySlots, 1, -1 do
		local categorySlot = categorySlots[index]
		if(categorySlot == Slot) then
			Slot.category = nil
			Slot.categoryIndex = nil

			table.remove(categorySlots, index)
		end
	end
end

function P.BAG_UPDATE(event, bagID)
	P.UpdateContainerSlots(bagID, event)

	if(not P.Override('PositionSlots')) then
		P.PositionSlots()
	end
end

function P.ITEM_LOCK_CHANGED(event, bagID, slotID)
	if(slotID) then
		P.UpdateSlot(bagID, slotID, event)
	else
		P.UpdateContainerSlots(bagID, event)
	end

	if(not P.Override('PositionSlots')) then
		P.PositionSlots()
	end
end

local function UpdateContainerCooldowns(startBagID, endBagID)
	for bagID = startBagID, endBagID or startBagID do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if(not P.Override('UpdateCooldown')) then
				P.OnUpdateCooldown(P.GetSlot(bagID, slotID), bagID, slotID)
			end
		end
	end
end

function P.BAG_UPDATE_COOLDOWN(event)
	UpdateContainerCooldowns(BACKPACK_CONTAINER, NUM_BAG_SLOTS)

	if(BackpackBank:IsVisible()) then
		UpdateContainerCooldowns(BANK_CONTAINER)
		UpdateContainerCooldowns(NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
	end
end

function P.QUEST_ACCEPTED(event)
	P.UpdateAllSlots(event)
end

function P.UNIT_QUEST_LOG_CHANGED(event, unit)
	if(unit == 'player') then
		P.QUEST_ACCEPTED(event)
	end
end

function P.PLAYERBANKSLOTS_CHANGED(event, slotID)
	P.UpdateSlot(BANK_CONTAINER, slotID, event)

	if(not P.Override('PositionSlots')) then
		P.PositionSlots()
	end
end
