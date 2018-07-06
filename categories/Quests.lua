local L = LibContainer.locale

local name = 'Quests'
local localizedName = L['Quest Items']
local index = 20

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		-- any item that is part of, or starts, a quest
		return Slot:GetItemQuestID() or Slot:IsItemQuestItem()
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
