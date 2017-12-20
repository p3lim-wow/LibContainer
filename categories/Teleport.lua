local P, E, L = unpack(select(2, ...))

-- custom list of any items that provide teleporting, because they deserve their own category
local teleporters = {
	-- Quest/achievement rewards
	[21711] = true, -- Lunar Festival Invitation
	[35230] = true, -- Darnarian's Scroll of Teleportation
	[52251] = true, -- Jaina's Locket
	[68808] = true, -- Hero's Hearthstone
	[68809] = true, -- Veteran's Hearthstone
	[110560] = true, -- Garrison Hearthstone
	[128353] = true, -- Admiral's Compass
	[140192] = true, -- Dalaran Hearthstone
	[141605] = true, -- Flight Master's Whistle

	-- Equipment
	[17690] = true, -- Frostwolf Insignia Rank 1
	[17691] = true, -- Stormpike Insignia Rank 1
	[17900] = true, -- Stormpike Insignia Rank 2
	[17901] = true, -- Stormpike Insignia Rank 3
	[17902] = true, -- Stormpike Insignia Rank 4
	[17903] = true, -- Stormpike Insignia Rank 5
	[17904] = true, -- Stormpike Insignia Rank 6
	[17905] = true, -- Frostwolf Insignia Rank 2
	[17906] = true, -- Frostwolf Insignia Rank 3
	[17907] = true, -- Frostwolf Insignia Rank 4
	[17908] = true, -- Frostwolf Insignia Rank 5
	[17909] = true, -- Frostwolf Insignia Rank 6
	[22589] = true, -- Atiesh, Greatstaff of the Guardian (Mage)
	[22630] = true, -- Atiesh, Greatstaff of the Guardian (Warlock)
	[22631] = true, -- Atiesh, Greatstaff of the Guardian (Priest)
	[22632] = true, -- Atiesh, Greatstaff of the Guardian (Druid)
	[28585] = true, -- Ruby Slippers
	[32757] = true, -- Blessed Medallion of Karabor
	[40585] = true, -- Signet of the Kirin Tor
	[40586] = true, -- Band of the Kirin Tor
	[44934] = true, -- Loop of the Kirin Tor
	[44935] = true, -- Ring of the Kirin Tor
	[45688] = true, -- Inscribed Band of the Kirin Tor
	[45689] = true, -- Inscribed Loop of the Kirin Tor
	[45690] = true, -- Inscribed Ring of the Kirin Tor
	[45691] = true, -- Inscribed Signet of the Kirin Tor
	[46874] = true, -- Argent Crusader's Tabard
	[48954] = true, -- Etched Band of the Kirin Tor
	[48955] = true, -- Etched Loop of the Kirin Tor
	[48956] = true, -- Etched Ring of the Kirin Tor
	[48957] = true, -- Etched Signet of the Kirin Tor
	[50287] = true, -- Boots of the Bay
	[51557] = true, -- Runed Signet of the Kirin Tor
	[51558] = true, -- Runed Loop of the Kirin Tor
	[51559] = true, -- Runed Ring of the Kirin Tor
	[51560] = true, -- Runed Band of the Kirin Tor
	[63206] = true, -- Wrap of Unity
	[63207] = true, -- Wrap of Unity
	[63352] = true, -- Shroud of Cooperation
	[63353] = true, -- Shroud of Cooperation
	[63378] = true, -- Hellscream's Reach Tabard
	[63379] = true, -- Baradin's Wardens Tabard
	[65274] = true, -- Cloak of Coordination
	[65360] = true, -- Cloak of Coordination
	[95050] = true, -- The Brassiest Knuckle (Horde)
	[95051] = true, -- The Brassiest Knuckle (Alliance)
	[103678] = true, -- Time-Lost Artifact
	[139599] = true, -- Empowered Ring of the Kirin Tor
	[142469] = true, -- Violet Seal of the Grand Magus

	-- Misc
	[6948] = true, -- Hearthstone
	[37118] = true, -- Scroll of Recall
	[37863] = true, -- Direbrew's Remote
	[44314] = true, -- Scroll of Recall II
	[44315] = true, -- Scroll of Recall III
	[58487] = true, -- Potion of Deepholm
	[64457] = true, -- The Last Relic of Argus
	[87548] = true, -- Lorewalker's Lodestone
	[118663] = true, -- Relic of Karabor
	[128502] = true, -- Hunter's Seeking Crystal
	[128503] = true, -- Master Hunter's Seeking Crystal
	[129276] = true, -- Beginner's Guide to Dimensional Rifting
	[139590] = true, -- Scroll of Teleport: Ravenholdt
	[141013] = true, -- Scroll of Town Portal: Shala'nir
	[141014] = true, -- Scroll of Town Portal: Sashj'tar
	[141015] = true, -- Scroll of Town Portal: Kal'delar
	[141016] = true, -- Scroll of Town Portal: Faronaar
	[141017] = true, -- Scroll of Town Portal: Lian'tril
}

local categoryName = L['Teleporters']
local categoryIndex = 60

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackKnownItems[itemID]
	if(custom and type(custom) == 'number') then
		return custom == categoryIndex
	else
		local itemID = Backpack:GetContainerItemID(bagID, slotID)
		return teleporters[itemID]
	end
end

P.AddCategory(categoryIndex, categoryName, 'Teleporters', categoryFilter)
