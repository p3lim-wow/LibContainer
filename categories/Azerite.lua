local key = 'Azerite'
local name = ISLANDS_QUEUE_WEEKLY_QUEST_PROGRESS:gsub('%%d/%d ', '') -- "%d/%d Azerite"
local index = 101

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		return C_Azerite.IsAzeriteItem(Slot:GetItemLocation())
	end
end

LibContainer:AddCategory(index, key, name, filter)
