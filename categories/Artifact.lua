local L = LibContainer.locale

local name = 'ArtifactPower'
local localizedName = L['Artifact Power']
local index = 100

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'number') then
		return custom == index
	else
		return IsArtifactPowerItem(Slot:GetItemID())
	end
end

LibContainer:AddCategory(index, name, localizedName, filter)
