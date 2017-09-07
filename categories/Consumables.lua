local P, E, L = unpack(select(2, ...))

local categoryName = L['Consumables']
local categoryIndex = 41

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom) then
		return custom == categoryIndex
	else
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

P.AddCategory(categoryIndex, categoryName, 'Consumables', categoryFilter)
