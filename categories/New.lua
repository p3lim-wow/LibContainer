local categoryName = NEW .. ' ' .. ITEMS -- TODO: improve this
local categoryIndex = 1001

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local _, _, _, itemQuality = Backpack:GetContainerItemInfo(bagID, slotID)
		if(itemQuality > LE_ITEM_QUALITY_POOR) then
			-- don't mark junk as new items
			return not BackpackKnownItems[itemID]
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
