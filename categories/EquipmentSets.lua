local L = select(2, ...)[3]

local categoryName = L['Equipment Sets']
local categoryIndex = 31

local function categoryFilter(bagID, slotID, itemID)
	local isInSet = Backpack:GetContainerItemEquipmentSetInfo(bagID, slotID)
	return isInSet
end

Backpack:AddCategory(categoryIndex, categoryName, 'EquipmentSets', categoryFilter)
