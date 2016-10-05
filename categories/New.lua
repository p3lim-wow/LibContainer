local categoryName = NEW .. ' ' .. ITEMS -- TODO: improve this
local categoryIndex = 1001

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == gearCategoryIndex) then
		return true
	elseif(not custom) then
		-- don't mark junk as new
		local _, _, _, quality = GetContainerItemInfo(bagID, slotID)
		if(quality == LE_ITEM_QUALITY_POOR) then
			return false
		else
			return not BackpackKnownItems[itemID]
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
