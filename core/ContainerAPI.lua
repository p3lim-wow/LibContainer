local P, E = unpack(select(2, ...))

local slotMethods = {
	'GetContainerItemCooldown',
	'GetContainerItemDurability',
	'GetContainerItemEquipmentSetInfo',
	'GetContainerItemID',
	'GetContainerItemInfo',
	'GetContainerItemLink',
	'GetContainerItemQuestInfo',
}

local bagMethods = {
	'GetContainerNumFreeSlots',
	'GetContainerNumSlots',
}

local methodsMixin = {}
for _, method in next, slotMethods do
	methodsMixin[method] = function(_, bagID, slotID)
		if((bagID < BACKPACK_CONTAINER or bagID > NUM_BAG_SLOTS) and not P.atBank) then
			if(BackpackBankDB) then
				if(BackpackBankDB[bagID]) then
					if(BackpackBankDB[bagID][slotID]) then
						if(BackpackBankDB[bagID][slotID][method]) then
							return unpack(BackpackBankDB[bagID][slotID][method])
						end
					end
				end
			end
		else
			return _G[method](bagID, slotID)
		end
	end
end

for _, method in next, bagMethods do
	methodsMixin[method] = function(_, bagID)
		if((bagID < BACKPACK_CONTAINER or bagID > NUM_BAG_SLOTS) and not P.atBank) then
			if(BackpackBankDB) then
				if(BackpackBankDB[bagID]) then
					if(BackpackBankDB[bagID][method]) then
						return unpack(BackpackBankDB[bagID][method])
					end
				end
			end

			return 0
		else
			return _G[method](bagID)
		end
	end
end

local function SaveData(bagID, slotID)
	if(not BackpackBankDB[bagID]) then
		BackpackBankDB[bagID] = {}
	end

	if(not BackpackBankDB[bagID][slotID]) then
		BackpackBankDB[bagID][slotID] = {}
	else
		table.wipe(BackpackBankDB[bagID][slotID])
	end

	for _, method in next, slotMethods do
		local data = {_G[method](bagID, slotID)}
		if(#data > 0) then
			BackpackBankDB[bagID][slotID][method] = data
		end
	end

	for _, method in next, bagMethods do
		local data = {_G[method](bagID)}
		if(#data > 0) then
			BackpackBankDB[bagID][method] = data
		end
	end
end

function E:BANKFRAME_OPENED()
	for slotID = 1, GetContainerNumSlots(BANK_CONTAINER) do
		SaveData(BANK_CONTAINER, slotID)
	end

	for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
		for slotID = 1, GetContainerNumSlots(bagID) do
			SaveData(bagID, slotID)
		end
	end

	if(IsReagentBankUnlocked()) then
		for slotID = 1, GetContainerNumSlots(REAGENTBANK_CONTAINER) do
			SaveData(REAGENTBANK_CONTAINER, slotID)
		end
	end
end

function E:BAG_UPDATE_COOLDOWN()
	if(P.atBank) then
		for slotID = 1, GetContainerNumSlots(BANK_CONTAINER) do
			SaveData(BANK_CONTAINER, slotID)
		end

		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slotID = 1, GetContainerNumSlots(bagID) do
				SaveData(bagID, slotID)
			end
		end
	end
end

function E.PLAYERBANKSLOTS_CHANGED(event, slotID)
	SaveData(BANK_CONTAINER, slotID)
end

function E.PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
	SaveData(REAGENTBANK_CONTAINER, slotID)
end

function P.MixinAPI(frame)
	Mixin(frame, methodsMixin)
end

