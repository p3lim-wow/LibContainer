local L = LibContainer.locale

local key = 'EquipmentSets'
local name = L['Equipment Sets']
local index = 31

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		return not not GetContainerItemEquipmentSetInfo(Slot:GetBagAndSlot())
	end
end

LibContainer:AddCategory(index, key, name, filter)
