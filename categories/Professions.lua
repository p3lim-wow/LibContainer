local categoryName = TRADE_SKILLS -- "Professions"
local categoryIndex = 50

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
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

Backpack:AddCategory(categoryIndex, categoryName, 'Professions', categoryFilter)
