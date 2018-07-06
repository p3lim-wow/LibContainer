local L = LibContainer.locale

local name = 'Inventory'
local localizedName = L['Inventory']
local index = 1 -- as low as possible

local filter = function(Slot)
	-- default path
	return true
end

LibContainer:AddCategory(index, name, localizedName, filter)
