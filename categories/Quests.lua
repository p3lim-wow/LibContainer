local P, E, L = unpack(select(2, ...))

local categoryName = L['Quests Items']
local categoryIndex = 20

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom) then
		return custom == categoryIndex
	else
		-- any item that is part of, or starts, a quest
		local isQuest, questID = Backpack:GetContainerItemQuestInfo(bagID, slotID)
		return questID or isQuest
	end
end

P.AddCategory(categoryIndex, categoryName, 'QuestItems', categoryFilter)
