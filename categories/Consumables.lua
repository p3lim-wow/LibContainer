local categoryName = BAG_FILTER_CONSUMABLES -- "Consumables"
local categoryIndex = 41

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local cached, _, itemQuality, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
		if(cached and itemQuality >= LE_ITEM_QUALITY_COMMON) then
			if(itemClass == LE_ITEM_CLASS_CONSUMABLE and itemSubClass >= 1) then
				-- consumables other than engineering explosives and devices, they're considered profession related
				return true
			elseif(itemClass == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then
				-- enchants, armor kits etc
				return true
			end
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
