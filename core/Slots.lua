local P = unpack(select(2, ...))
P.categorySlots = {}

local parents, slots = {}, {}
local function CreateParent(bagID)
	local containerName
	if(bagID == -1 or bagID == -3) then
		containerName = P.name .. 'Bank'
	else
		containerName = P.name
	end

	local Parent = CreateFrame('Frame', '$parentBag' .. bagID, _G[containerName])
	Parent:SetID(bagID)

	parents[bagID] = Parent
	slots[bagID] = {}

	return Parent
end

function P.CreateSlot(bagID, slotID)
	local template
	if(bagID == -1) then
		template = 'ContainerFrameItemButtonTemplate'
	elseif(bagID == -3) then
		template = 'ReagentBankItemButtonGenericTemplate'
	else
		template = 'ContainerFrameItemButtonTemplate'
	end

	local Parent = parents[bagID] or CreateParent(bagID)
	local Slot = CreateFrame('Button', '$parentSlot' .. slotID, Parent, template)
	local slotName = Slot:GetName()

	Slot:SetID(slotID)
	Slot.slotID = slotID
	Slot.bagID = bagID

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

	return Slot
end

local function GetSlot(bagID, slotID)
	return slots[bagID] and slots[bagID][slotID] or P.CreateSlot(bagID, slotID)
end

local function UpdateSlot(event, bagID, slotID)
	if(GetContainerItemInfo(bagID, slotID)) then
		local itemID = GetContainerItemID(bagID, slotID)

		local category = P.GetCategory(bagID, slotID, itemID)
		local categoryIndex = category.index

		local Slot = GetSlot(bagID, slotID)
		local slotCategoryIndex = Slot.categoryIndex
		if(slotCategoryIndex ~= categoryIndex) then
			if(slotCategoryIndex) then
				P.RemoveCategorySlot(Slot)
				P.RemoveContainerSlot(Slot)
			end

			P.AddCategorySlot(Slot, category)
			P.AddContainerSlot(Slot, P.GetCategoryContainer(categoryIndex))
		end

		-- for the sorting methods
		local _, itemCount, _, itemQuality = GetContainerItemInfo(bagID, slotID)
		Slot.itemCount = itemCount
		Slot.itemQuality = itemQuality
		Slot.itemID = itemID
		Slot.itemLevel = select(4, GetItemInfo(itemID))

		if(not P.Override('UpdateSlot', Slot)) then
			P.OnUpdateSlot(Slot, bagID, slotID)
		end

		Slot:Show()

		P.Fire('PostUpdateSlot', event, bagID, slotID)
	else
		local Slot = slots[bagID] and slots[bagID][slotID]
		if(Slot) then
			P.RemoveCategorySlot(Slot)
			P.RemoveContainerSlot(Slot)

			Slot:Hide()

			P.Fire('PostRemoveSlot', event, bagID, slotID)
		end
	end
end

function P.AddCategorySlot(Slot, category)
	local categoryIndex = category.index
	Slot.category = category
	Slot.categoryIndex = categoryIndex

	if(not P.categorySlots[categoryIndex]) then
		P.categorySlots[categoryIndex] = {}
	end

	table.insert(P.categorySlots[categoryIndex], Slot)
end

function P.RemoveCategorySlot(Slot)
	for index, categorySlot in next, P.categorySlots[Slot.categoryIndex] do
		if(categorySlot == Slot) then
			P.categorySlots[Slot.categoryIndex][index] = nil
			return
		end
	end
end

local initialized
function P.UpdateAllSlots()
	for bagID = 0, NUM_BAG_FRAMES do
		for slotID = 1, GetContainerNumSlots(bagID) do
			UpdateSlot('Initialize', bagID, slotID)
		end
	end

	if(not P.Fire('PositionSlots')) then
		P.PositionSlots()
	end
end
