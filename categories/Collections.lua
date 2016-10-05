local categoryName = COLLECTIONS -- "Collections"
local categoryIndex = 80

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local cached, _, _, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
		if(cached) then
			if(itemClass == LE_ITEM_CLASS_BATTLEPET) then
				-- caged battlepets
				return true
			elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS)
				if(itemSubClass == 2 or itemSubClass == 5) then
					-- uncaged battlepets and mounts
					return true
				elseif(itemSubClass == 4) then
					-- TODO: scan tooltips, toys are in this subclass
				end
			end
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
