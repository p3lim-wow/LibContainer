local categoryName = BAG_FILTER_CONSUMABLES -- "Consumables"
local categoryIndex = 41

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
		if(itemClass == LE_ITEM_CLASS_CONSUMABLE and itemSubClass >= 1) then
			-- consumables other than engineering explosives and devices, they're considered profession related
			if(itemSubClass ~= 8) then
				-- but not consumables in the "other" subclass
				return true
			end
		elseif(itemClass == LE_ITEM_CLASS_ITEM_ENHANCEMENT) then
			-- enchants, armor kits etc
			return true
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
