local categoryName = QUESTS_LABEL -- "Quests"
local categoryIndex = 20

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local isQuest, questID = GetContainerItemQuestInfo(bagID, slotID)
		return questID or isQuest
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
