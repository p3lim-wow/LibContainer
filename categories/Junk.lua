local categoryName = BAG_FILTER_JUNK -- "Junk"
local categoryIndex = 1e3

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local _, _, _, quality = GetContainerItemInfo(bagID, slotID)
		return quality == LE_ITEM_QUALITY_POOR
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
