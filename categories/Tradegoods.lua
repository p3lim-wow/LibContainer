local categoryName = BAG_FILTER_TRADE_GOODS -- "Trade Goods"
local categoryIndex = 40

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local itemID = GetContainerItemID(bagID, slotID)
		if(itemID) then
			local itemName, _, _, _, _, _, _, _, _, _, _, itemClass = GetItemInfo(itemID)
			return itemName and itemClass == 7
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
