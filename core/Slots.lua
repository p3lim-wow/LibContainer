﻿local P, E = unpack(select(2, ...))
P.categorySlots = {}

local parents, slots = {}, {}
local function CreateParent(bagID)
	local Parent = CreateFrame('Frame', '$parentBag' .. bagID, Backpack)
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
			P.AddContainerSlot(Slot, P.GetCategoryContainer(categoryIndex))
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
	for bagID = 0, NUM_BAG_FRAMES do
		P.UpdateContainerSlots(bagID, event)
	end

	if(not initialized) then
		E:RegisterEvent('BAG_UPDATE', P.BAG_UPDATE)
		E:RegisterEvent('ITEM_LOCK_CHANGED', P.ITEM_LOCK_CHANGED)
		E:RegisterEvent('BAG_UPDATE_COOLDOWN', P.BAG_UPDATE_COOLDOWN)
		E:RegisterEvent('QUEST_ACCEPTED', P.QUEST_ACCEPTED)
		E:RegisterEvent('UNIT_QUEST_LOG_CHANGED', P.UNIT_QUEST_LOG_CHANGED)

		initialized = true
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
	local categorySlots = P.categorySlots[Slot.categoryIndex]
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
	if(bagID >= 0 and bagID <= 4) then
		if(slotID) then
			P.UpdateSlot(bagID, slotID, event)
		else
			P.UpdateContainerSlots(bagID, event)
		end
	end
end

function P.BAG_UPDATE_COOLDOWN(event)
	for bagID = 0, NUM_BAG_FRAMES do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if(not P.Override('UpdateCooldown')) then
				P.OnUpdateCooldown(P.GetSlot(bagID, slotID), bagID, slotID)
			end
		end
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
