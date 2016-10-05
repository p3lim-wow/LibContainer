local categoryName = BATTLE_PET_SOURCE_7 -- "World Event" (EVENTS_LABEL)
local categoryIndex = 70

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local cached, _, _, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
		if(cached) then
			if(itemClass == LE_ITEM_CLASS_QUESTITEM) then
				-- quest items that is not part of, or starts, a quest can be considered holiday related
				local isQuest, questID = GetContainerItemQuestInfo(bagID, slotID)
				if(not questID and not isQuest) then
					return true
				end
			elseif(itemClass == LE_ITEM_CLASS_MISCELLANEOUS and itemSubClass == 3) then
				-- holiday crap
				return true
			end
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
