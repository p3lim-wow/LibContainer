local bagSlots = {}
bagSlots.bags = {}
bagSlots.bank = {}

bagSlots.bank[BANK_CONTAINER] = true
bagSlots.bank[REAGENTBANK_CONTAINER] = true

for index = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
	bagSlots.bags[index] = true
end

for index = 1, NUM_BANKBAGSLOTS do
	bagSlots.bank[NUM_BAG_SLOTS + index] = true
end

local bagSizes = setmetatable({
	[BACKPACK_CONTAINER] = BACKPACK_BASE_SIZE + 4,
	[BANK_CONTAINER] = NUM_BANKGENERIC_SLOTS,
	[REAGENTBANK_CONTAINER] = 98
}, {
	__index = function()
		return MAX_CONTAINER_ITEMS
	end
})

LibContainer.constants.bagSlots = bagSlots
LibContainer.constants.bagSizes = bagSizes
