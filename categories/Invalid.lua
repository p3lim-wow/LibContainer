local L = LibContainer.locale

local name = 'Invalid'
local localizedName = L['Erroneous']
local index = 2

local filter = function(Slot)
	-- any item that is not retrieving information
	return not GetContainerItemLink(Slot:GetBagAndSlot())
end

LibContainer:AddCategory(index, name, localizedName, filter)
