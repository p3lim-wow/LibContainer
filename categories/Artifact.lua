local key = 'ArtifactPower'
local name = ARTIFACT_POWER -- "Artifact Power"
local index = 100

local filter = function(Slot)
	local custom = LibContainer.db.KnownItems[Slot:GetItemID()]
	if(custom and type(custom) == 'string') then
		return custom == key
	else
		return IsArtifactPowerItem(Slot:GetItemID())
	end
end

LibContainer:AddCategory(index, key, name, filter)
