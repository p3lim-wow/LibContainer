local categoryName = TRADE_SKILLS -- "Professions"
local categoryIndex = 50

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		if(itemID) then
			local itemName, _, _, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
			return itemName and (itemClass == 0 and itemSubClass == 0) or itemClass == 9
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
