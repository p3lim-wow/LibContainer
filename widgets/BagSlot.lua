--[[ BagSlot:header
This widget adds additional slots to the [Parent](Parent) that represents the bags the item
[Slots](Slot) are placed in.

The layout is responsible for positioning (and optionally styling) the bag slots.  
See the [Bags](Bags) widget for a way to toggle the visibility of the bag slots.

In addition, this widget has a few methods on the slots themselves, but does not have the
[Slot](Slot) or [Item](Item) methods.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:AddBagSlots()
```

- Callbacks:
   - On [Slot](Slot)
      - `PreUpdate(Slot)` - Fired before a slot is updated.
      - `PostUpdate(Slot)` - Fired after a slot is updated.
   - On [Parent](Parent)
      - `PostCreateBagSlot(Slot)` - Fired after a bag slot is created.
--]]
local L = LibContainer.locale

local callbackMixin = LibContainer.mixins.callback
local parentMixin = LibContainer.mixins.parent

local bagSlotMixin = {}
--[[ BagSlot:GetInventoryID()
Returns the intentory ID for the [BagSlot](BagSlot).  
Alias for `ContainerIDToInventoryID(BagSlot:GetID())`.
--]]
function bagSlotMixin:GetInventoryID()
	return ContainerIDToInventoryID(self:GetID())
end

--[[ BagSlot:GetSlotTexture()
Returns the texture ID for the [BagSlot](BagSlot).  
Alias for `GetInventoryItemTexture('player', BagSlot:GetInventoryID())`.
--]]
function bagSlotMixin:GetSlotTexture()
	return GetInventoryItemTexture('player', self:GetInventoryID())
end

--[[ BagSlot:IsSlotLocked()
Returns true/false if the [BagSlot](BagSlot) is locked or not.  
Alias for `IsInventoryItemLocked(BagSlot:GetInventoryID())`.
--]]
function bagSlotMixin:IsSlotLocked()
	return IsInventoryItemLocked(self:GetInventoryID())
end

--[[ BagSlot:IsBankSlot()
Returns true/false if the [BagSlot](BagSlot) belongs to the bank or not.
--]]
function bagSlotMixin:IsBankSlot()
	return self:GetID() > NUM_BAG_SLOTS
end

--[[ BagSlot:IsSlotPurchased()
Returns true/false if the [BagSlot](BagSLot) is purchased or not.

Always returns true for non-bank bag slots.
--]]
function bagSlotMixin:IsSlotPurchased()
	if(self:IsBankSlot()) then
		return (self:GetID() - NUM_BAG_SLOTS) <= GetNumBankSlots()
	else
		-- the stock bag slots are always available
		return true
	end
end

--[[ BagSlot:HasBag()
Returns true/false if the [BagSlot](BagSlot) has a bag or not (is empty).
--]]
function bagSlotMixin:HasBag()
	return not not GetInventoryItemID('player', self:GetInventoryID())
end

--[[
function bagSlotMixin:GetSlotCost()
	if(self:IsBankSlot() and not self:IsSlotPurchased()) then
		return GetBankSlotCost(self:GetID() - NUM_BAG_SLOTS)
	end
end
--]]
local function UpdateSlot(Slot)
	Slot:Fire('PreUpdate', Slot)
	local Icon = Slot.Icon
	Icon:SetTexture(Slot:GetSlotTexture())
	Icon:SetDesaturated(Slot:IsSlotLocked())

	Slot.PurchaseIcon:SetShown(not Slot:IsSlotPurchased())
	Slot:Fire('PostUpdate', Slot)
end

local function OnClick(Slot)
	if(not Slot:IsSlotPurchased()) then
		-- prompt for a slot purchase
		BankFrame.nextSlotCost = GetBankSlotCost(GetNumBankSlots())
		StaticPopup_Show('CONFIRM_BUY_BANK_SLOT')
	else
		if(CursorHasItem()) then
			PutItemInBag(Slot:GetInventoryID())
		else
			PickupBagFromSlot(Slot:GetInventoryID())
		end
	end
end

local function OnShow(Slot)
	UpdateSlot(Slot)
end

local function OnDragStart(Slot)
	PickupBagFromSlot(Slot:GetInventoryID())
end

local function OnEnter(Slot)
	GameTooltip:SetOwner(Slot, 'ANCHOR_LEFT')
	if(not GameTooltip:SetInventoryItem('player', Slot:GetInventoryID())) then
		if(not Slot:IsSlotPurchased()) then
			GameTooltip:SetText(L['Purchase'])
		else
			GameTooltip:SetText(L['Equip Container'])
		end
	end

	GameTooltip:Show()
end

local function OnLeave(Slot)
	GameTooltip:Hide()
	ResetCursor()
end

local function ITEM_LOCK_CHANGED(Parent, inventoryID, slotIndex)
	if(inventoryID == BANK_CONTAINER and slotIndex > NUM_BANKGENERIC_SLOTS) then
		inventoryID = ContainerIDToInventoryID(slotIndex - NUM_BANKGENERIC_SLOTS + NUM_BAG_SLOTS)
	end

	local Slot = Parent.bagSlots and Parent.bagSlots[inventoryID]
	if(Slot) then
		UpdateSlot(Slot)
	end
end

local function PLAYERBANKBAGSLOTS_CHANGED(Parent)
	if(Parent.bagSlots) then
		for _, Slot in next, Parent.bagSlots do
			UpdateSlot(Slot)
		end
	end
end

local function BAG_CLOSED(Parent, bagID)
	local inventoryID = ContainerIDToInventoryID(bagID)
	local Slot = Parent.bagSlots and Parent.bagSlots[inventoryID]
	if(Slot) then
		UpdateSlot(Slot)
	end
end

local function AddFauxSlot(Bag)
	local numBags, startIndex
	if(Bag:GetID() == BACKPACK_CONTAINER) then
		numBags = NUM_BAG_SLOTS
		startIndex = BACKPACK_CONTAINER + 1
	elseif(Bag:GetID() == BANK_CONTAINER) then
		numBags = NUM_BANKBAGSLOTS
		startIndex = NUM_BAG_SLOTS + 1
	end

	if(numBags) then
		local Parent = Bag:GetParent()
		if(not Parent.bagSlots) then
			Parent.bagSlots = {}
		end

		-- create faux bag slots, more or less the same as Bag.CreateSlot
		for index = 1, numBags do
			local bagIndex = index + startIndex - 1
			local Slot = Mixin(CreateFrame('Button', '$parentBagSlot' .. index, Bag:GetParent(), 'ItemButtonTemplate'), bagSlotMixin, callbackMixin)
			Slot:Hide()
			--[[ BagSlot:GetID()
			Returns the bag slot's bag index.
			--]]
			Slot:SetID(bagIndex)
			Slot:SetScript('OnShow', OnShow)
			Slot:SetScript('OnClick', OnClick)
			Slot:SetScript('OnDragStart', OnDragStart)
			Slot:SetScript('OnReceiveDrag', OnClick)
			Slot:SetScript('OnEnter', OnEnter)
			Slot:SetScript('OnLeave', OnLeave)
			Slot:RegisterForDrag('LeftButton')
			Slot.index = index

			-- assign predictable keys for children
			local slotName = Slot:GetName()
			Slot.Icon = Slot.icon
			Slot.Stock = _G[slotName .. 'Stock']
			Slot.SearchOverlay = Slot.searchOverlay
			Slot.IconBorder = Slot.IconBorder
			Slot.IconOverlay = Slot.IconOverlay
			Slot.NormalTexture = Slot:GetNormalTexture()
			Slot.PushedTexture = Slot:GetPushedTexture()
			Slot.HighlightTexture = Slot:GetHighlightTexture()

			local PurchaseIcon = Slot:CreateTexture('$parentPurchaseIcon', 'ARTWORK')
			PurchaseIcon:SetPoint('CENTER')
			PurchaseIcon:SetSize(16, 16)
			PurchaseIcon:SetTexture([[Interface\GossipFrame\BankerGossipIcon]])
			PurchaseIcon:Hide()
			Slot.PurchaseIcon = PurchaseIcon

			Bag:GetParent():Fire('PostCreateBagSlot', Slot)

			Parent.bagSlots[Slot:GetInventoryID()] = Slot
		end
	end
end

--[[ Parent:AddBagSlots()
Adds a [BagSlot](BagSlot) widget to the Parent.
--]]
function parentMixin:AddBagSlots()
	self:On('PostCreateBag', AddFauxSlot)
	self:RegisterEvent('ITEM_LOCK_CHANGED', ITEM_LOCK_CHANGED)

	if(self:GetType() == 'bank') then
		self:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED', PLAYERBANKBAGSLOTS_CHANGED)
		self:RegisterEvent('PLAYERBANKSLOTS_CHANGED', PLAYERBANKBAGSLOTS_CHANGED)
	else
		self:RegisterEvent('BAG_CLOSED', BAG_CLOSED)
	end
end
