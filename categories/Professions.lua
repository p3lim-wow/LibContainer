local P, E, L = unpack(select(2, ...))

local categoryName = L['Professions']
local categoryIndex = 50

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom) then
		return custom == categoryIndex
	else
		local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
		if(itemClass == LE_ITEM_CLASS_CONSUMABLE and itemSubClass == 0) then
			-- engineering explosives and devices
			return true
		elseif(itemClass == LE_ITEM_CLASS_RECIPE) then
			-- recipes
			return true
		elseif(itemClass == LE_ITEM_CLASS_CONTAINER and itemSubClass ~= 1) then
			-- profession bags except for warlock soulshards (not that they exist any more)
			return true
		end
	end
end

P.AddCategory(categoryIndex, categoryName, 'Professions', categoryFilter)
