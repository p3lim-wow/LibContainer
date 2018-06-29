local L = LibContainer.locale

local key = 'Quests'
local name = L['Quest Items']
local index = 20

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		-- any item that is part of, or starts, a quest
		return Slot:GetItemQuestID() or Slot:IsItemQuestItem()
	end
end

LibContainer:AddCategory(index, key, name, filter)
