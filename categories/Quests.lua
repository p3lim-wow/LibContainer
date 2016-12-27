local L = select(2, ...)[3]

local categoryName = L['Quests Items']
local categoryIndex = 20

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and custom == categoryIndex) then
		return true
	else
		-- any item that is part of, or starts, a quest
		local isQuest, questID = Backpack:GetContainerItemQuestInfo(bagID, slotID)
		return questID or isQuest
	end
end

Backpack:AddCategory(categoryIndex, categoryName, 'QuestItems', categoryFilter)
