-- custom list of any items that provide teleporting, because they deserve their own category

local teleporters = {
	6948, -- Hearthstone
	17690, -- Frostwolf Insignia Rank 1
	17691, -- Stormpike Insignia Rank 1
	17900, -- Stormpike Insignia Rank 2
	17901, -- Stormpike Insignia Rank 3
	17902, -- Stormpike Insignia Rank 4
	17903, -- Stormpike Insignia Rank 5
	17904, -- Stormpike Insignia Rank 6
	17905, -- Frostwolf Insignia Rank 2
	17906, -- Frostwolf Insignia Rank 3
	17907, -- Frostwolf Insignia Rank 4
	17908, -- Frostwolf Insignia Rank 5
	17909, -- Frostwolf Insignia Rank 6
	22631, -- Atiesh, Greatstaff of the Guardian
	28585, -- Ruby Slippers
	32757, -- Blessed Medallion of Karabor
	37118, -- Scroll of Recall
	37863, -- Direbrew's Remote
	40585, -- Signet of the Kirin Tor
	44314, -- Scroll of Recall II
	44315, -- Scroll of Recall III
	45691, -- Inscribed Signet of the Kirin Tor
	46874, -- Argent Crusader's Tabard
	48957, -- Etched Signet of the Kirin Tor
	50287, -- Boots of the Bay
	51557, -- Runed Signet of the Kirin Tor
	52251, -- Jaina's Locket
	58487, -- Potion of Deepholm
	63206, -- Wrap of Unity
	63207, -- Wrap of Unity
	63352, -- Shroud of Cooperation
	63353, -- Shroud of Cooperation
	63378, -- Hellscream's Reach Tabard
	63379, -- Baradin's Wardens Tabard
	64457, -- The Last Relic of Argus
	64488, -- The Innkeeper's Daughter
	65274, -- Cloak of Coordination
	65360, -- Cloak of Coordination
	95050, -- The Brassiest Knuckle
	103678, -- Time-Lost Artifact
	110560, -- Garrison Hearthstone
	129276, -- Beginner's Guide to Dimensional Rifting
	140192, -- Dalaran Hearthstone
	141013, -- Scroll of Town Portal: Shala'nir
	141014, -- Scroll of Town Portal: Sashj'tar
	141015, -- Scroll of Town Portal: Kal'delar
	141016, -- Scroll of Town Portal: Faronaar
	141017, -- Scroll of Town Portal: Lian'tril
	141605, -- Flight Master's Whistle
}

-- just so I can list them neater
local temp = {}
for _, itemID in next, teleporters do
	temp[itemID] = true
end
teleporters = temp

local categoryName = "Teleporters"
local categoryIndex = 60

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local itemID = Backpack:GetContainerItemID(bagID, slotID)
		return teleporters[itemID]
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)
