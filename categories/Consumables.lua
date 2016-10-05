local categoryName = BAG_FILTER_CONSUMABLES -- "Consumables"
local categoryIndex = 41

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local itemID = GetContainerItemID(bagID, slotID)
		if(itemID) then
			local itemName, _, itemQuality, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
			if(itemName and itemQuality >= LE_ITEM_QUALITY_COMMON) then
				return itemClass == 0 and (itemSubClass == 1 or itemSubClass == 5)
			end
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
