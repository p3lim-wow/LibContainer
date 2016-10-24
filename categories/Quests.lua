local categoryName = AUCTION_CATEGORY_QUEST_ITEMS -- "Quests Items"
local categoryIndex = 20

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		-- any item that is part of, or starts, a quest
		local isQuest, questID = Backpack:GetContainerItemQuestInfo(bagID, slotID)
		return questID or isQuest
	end
end

Backpack:AddCategory(categoryIndex, categoryName, 'QuestItems', categoryFilter)
