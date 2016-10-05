local categoryName = strsplit(':', EQUIPMENT_SETS) -- "Equipment Sets"
local categoryIndex = 31

local function categoryFilter(bagID, slotID, itemID)
	local isInSet = GetContainerItemEquipmentSetInfo(bagID, slotID)
	return isInSet
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
