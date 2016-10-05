local categoryName = BATTLE_PET_SOURCE_7 -- "World Event" (EVENTS_LABEL)
local categoryIndex = 70

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		if(itemID) then
			local itemName, _, _, _, _, _, _, _, _, _, _, itemClass, itemSubClass = GetItemInfo(itemID)
			if(itemName and itemClass == 12) then
				local isQuest, questID = GetContainerItemQuestInfo(bagID, slotID)
				if(not questID and not isQuest) then
					return true
				end
			end
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
