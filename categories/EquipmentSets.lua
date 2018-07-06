local L = LibContainer.locale

local name = 'EquipmentSets'
local localizedName = L['Equipment Sets']
local index = 31

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		return not not GetContainerItemEquipmentSetInfo(Slot:GetBagAndSlot())
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
