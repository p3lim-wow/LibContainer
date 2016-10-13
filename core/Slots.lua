local P = unpack(select(2, ...))
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

	P.Fire('PostCreateParent', bagID)

	return Parent
end

function P.CreateSlot(bagID, slotID)
	local template
	if(bagID == BANK_CONTAINER) then
		template = 'BankItemButtonGenericTemplate'
	elseif(bagID == REAGENTBANK_CONTAINER) then
		template = 'ReagentBankItemButtonGenericTemplate'
	else
		template = 'ContainerFrameItemButtonTemplate'
	end

	local Parent = parents[bagID] or CreateParent(bagID)
	local Slot = CreateFrame('Button', '$parentSlot' .. slotID, Parent, template)
	local slotName = Slot:GetName()

	Slot:Hide()
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
	Slot.QuestIcon = Slot.IconQuestTexture or _G[slotName .. 'IconQuestTexture']
	Slot.JunkIcon = Slot.JunkIcon
	Slot.Flash = Slot.flash
	Slot.NewItem = Slot.NewItemTexture
	Slot.BattlePay = Slot.BattlepayItemTexture
	Slot.Cooldown = _G[slotName .. 'Cooldown']

	P.SkinCallback('Slot', Slot)

	slots[bagID][slotID] = Slot

	return Slot
end

function P.GetSlot(bagID, slotID)
	return slots[bagID] and slots[bagID][slotID]
end

function P.GetAllSlots(bagID)
	return slots[bagID]
end

function P.GetAllParents()
	return parents
end

function P.HasParent(bagID)
	return parents[bagID] ~= nil
end

function P.UpdateSlot(bagID, slotID, event)
	if(Backpack:GetContainerItemInfo(bagID, slotID)) then
		local itemID = Backpack:GetContainerItemID(bagID, slotID)
		local cached, _, _, itemLevel = GetItemInfo(Backpack:GetContainerItemLink(bagID, slotID))

		local category = P.GetCategory(bagID, slotID, itemID)
		local categoryIndex = category.index

		local Slot = P.GetSlot(bagID, slotID)
		if(not cached) then
			table.insert(P.query, Slot)
		end

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
		local _, itemCount, _, itemQuality = Backpack:GetContainerItemInfo(bagID, slotID)
		Slot.itemCount = itemCount
		Slot.itemQuality = itemQuality
		Slot.itemID = itemID
		Slot.itemLevel = itemLevel or 0

		if(not P.Override('UpdateSlot', Slot)) then
			P.UpdateSlotInfo(Slot)
		end

		if(not P.Override('UpdateSlotCooldown', Slot)) then
			P.UpdateSlotCooldown(Slot)
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

function P.UpdateSlotInfo(Slot)
	local itemTexture, itemCount, isLocked, itemQuality, _, _, _, _, _, itemID = Backpack:GetContainerItemInfo(Slot.bagID, Slot.slotID)
	local questItem, itemQuestID, itemQuestActive = Backpack:GetContainerItemQuestInfo(Slot.bagID, Slot.slotID)

	SetItemButtonTexture(Slot, itemTexture)
	SetItemButtonQuality(Slot, itemQuality, itemID)
	SetItemButtonCount(Slot, itemCount)
	SetItemButtonDesaturated(Slot, isLocked)

	local QuestIcon = Slot.QuestIcon
	if(itemQuestID and not itemQuestActive) then
		QuestIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG)
		QuestIcon:Show()
	elseif(itemQuestID or questItem) then
		QuestIcon:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
		QuestIcon:Show()
	else
		QuestIcon:Hide()
	end

	local BattlePay = Slot.BattlePay
	if(BattlePay) then
		BattlePay:SetShown(IsBattlePayItem(Slot.bagID, Slot.slotID))
	end

	local JunkIcon = Slot.JunkIcon
	if(JunkIcon) then
		JunkIcon:SetShown(itemQuality == LE_ITEM_QUALITY_POOR)
	end
end

function P.UpdateSlotCooldown(Slot)
	if(Slot and Slot:IsShown()) then
		local start, duration, enabled = Backpack:GetContainerItemCooldown(Slot.bagID, Slot.slotID)
		CooldownFrame_Set(Slot.Cooldown, start, duration, enabled)
	end
end

function P.UpdateContainerCooldowns(startBagID, endBagID)
	for bagID = startBagID, endBagID or startBagID do
		for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
			if(not P.Override('UpdateSlotCooldown', P.GetSlot(bagID, slotID))) then
				P.UpdateSlotCooldown(P.GetSlot(bagID, slotID))
			end
		end
	end
end

function P.UpdateContainerSlots(bagID, event)
	for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
		P.UpdateSlot(bagID, slotID, event)
	end
end

function P.UpdateAllSlots(event)
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		P.UpdateContainerSlots(bagID, event)
	end

	if(P.atBank or BackpackBankDB ~= nil) then
		P.UpdateContainerSlots(BANK_CONTAINER, event)

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			P.UpdateContainerSlots(bagID, event)
		end

		if(IsReagentBankUnlocked()) then
			P.UpdateContainerSlots(REAGENTBANK_CONTAINER, event)
		end
	end
end

function P.InitializeAllSlots(bagID)
	for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
		P.CreateSlot(bagID, slotID)
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

function P.PositionSlots()
	for parentContainer, categorySlots in next, P.categorySlots do
		for categoryIndex in next, categorySlots do
			table.sort(categorySlots[categoryIndex], P.categories[categoryIndex].sortFunc)
		end

		for categoryIndex, slots in next, categorySlots do
			local Container = P.GetCategoryContainer(parentContainer, categoryIndex)

			-- defaults
			local anchor = Container.anchor or Container
			local anchorPoint = Container.anchorPoint or 'TOPLEFT'

			local sizeX = Container.slotSizeX or Container.slotSize or 32
			local sizeY = Container.slotSizeY or Container.slotSize or 32

			local spacingX = Container.spacingX or Container.spacing or 4
			local spacingY = Container.spacingY or Container.spacing or 4

			local growX = Container.growX == 'LEFT' and -1 or 1
			local growY = Container.growY == 'UP' and 1 or -1

			local cols = Container.columns or 8

			for index, Slot in next, slots do
				local col = (index - 1) % cols
				local row = math.floor((index - 1) / cols)

				Slot:ClearAllPoints()
				Slot:SetPoint(anchorPoint, anchor, col * (sizeX + spacingX) * growX, row * (sizeY + spacingY) * growY)
			end
		end

		P.ResizeContainers(parentContainer)
	end
end
