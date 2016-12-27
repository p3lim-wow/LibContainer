local P, E, L = unpack(select(2, ...))

local categoryName = L['Equipment Sets']
local categoryIndex = 31

local function categoryFilter(bagID, slotID, itemID)
	local isInSet = Backpack:GetContainerItemEquipmentSetInfo(bagID, slotID)
	return isInSet
end

P.AddCategory(categoryIndex, categoryName, 'EquipmentSets', categoryFilter)
