-- flavor of the expansion, gets their own category
local P, E, L = unpack(select(2, ...))

local categoryName = L['Artifact Power']
local categoryIndex = 10

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		if(IsArtifactPowerItem(itemID)) then
			return true
		end
	end
end

P.AddCategory(categoryIndex, categoryName, 'ArtifactPower', categoryFilter)
