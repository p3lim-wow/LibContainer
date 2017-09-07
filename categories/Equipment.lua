local P, E, L = unpack(select(2, ...))

local categoryName = L['Equipment']
local categoryIndex = 30

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		local cached, _, itemQuality, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
		if(cached and itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
			if(itemClass == LE_ITEM_CLASS_WEAPON or itemClass == LE_ITEM_CLASS_ARMOR) then
				-- weapons and armor (including jewelry)
				return true
			elseif(itemClass == LE_ITEM_CLASS_GEM and itemSubClass == 11) then
				-- artifact relics
				return true
			end
		end
	end
end

P.AddCategory(categoryIndex, categoryName, 'Equipment', categoryFilter)
