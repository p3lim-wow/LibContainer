local L = LibContainer.locale

local key = 'Invalid'
local name = L['Erroneous']
local index = 2

local filter = function(Slot)
	-- any item that is not retrieving information
	return not GetContainerItemLink(Slot:GetBagAndSlot())
end

LibContainer:AddCategory(index, key, name, filter)
