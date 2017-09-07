local P, E, L = unpack(select(2, ...))

local categoryName = L['New Items']
local categoryIndex = 1001

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		local _, _, _, itemQuality = Backpack:GetContainerItemInfo(bagID, slotID)
		if(itemQuality > LE_ITEM_QUALITY_POOR) then
			-- don't mark junk as new items
			return not BackpackKnownItems[itemID]
		end
	end
end

P.AddCategory(categoryIndex, categoryName, 'NewItems', categoryFilter)

local function OnClick(self)
	local Container = P.GetCategoryContainer(self.parentContainer, 1001)
	for _, Slot in next, Container.slots do
		local itemID = Slot.itemID
		BackpackKnownItems[itemID] = true
	end

	P.UpdateAllSlots('ResetNew')
	P.PositionSlots()
end

local function Init(self, isBank)
	local Button = P.CreateContainerButton('ResetNew', categoryIndex, isBank)
	Button:SetScript('OnClick', OnClick)
	Button.tooltipText = L['Mark items as known']
	Button.parentContainer = self
	self.ResetNew = Button

	P.Fire('PostCreateResetNew', Button)
end

Backpack:AddModule('ResetNew', Init, nil, true)
