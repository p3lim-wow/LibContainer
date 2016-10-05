-- flavor of the expansion, gets their own category

local categoryName = ARTIFACT_POWER -- "Artifact Power"
local categoryIndex = 10

local scanTip = CreateFrame('GameTooltip', (...) .. 'ScanTip' .. math.floor(GetTime()))
scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')

local lineName = scanTip:GetName() .. 'TextLeft2'

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	else
		scanTip:SetBagItem(bagID, slotID)
		scanTip:Show()

		local line = _G[lineName]
		return line and line:GetText() == categoryName
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
