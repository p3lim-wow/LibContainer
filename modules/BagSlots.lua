local P, E, L = unpack(select(2, ...))

local bags = {}
local inventoryIDToBagID = {}

local function UpdateBag(bagID)
	local Bag = bags[bagID]
	if(not P.Override('UpdateBagSlot', Bag)) then
		local inventoryID = Bag:GetID()
		if(Bag.isBank) then
			Bag.PurchaseIcon:SetShown(bagID - NUM_BAG_SLOTS > GetNumBankSlots())
		end

		local Icon = Bag.Icon
		Icon:SetTexture(GetInventoryItemTexture('player', inventoryID))
		Icon:SetDesaturated(IsInventoryItemLocked(inventoryID))

		P.Fire('PostUpdateBagSlot', Bag)
	end
end

local function Update(event, ...)
	if(event == 'ITEM_LOCK_CHANGED') then
		local inventoryID, slotID = ...
		if(inventoryID == BANK_CONTAINER and slotID > NUM_BANKGENERIC_SLOTS) then
			inventoryID, slotID = ContainerIDToInventoryID(slotID - NUM_BANKGENERIC_SLOTS + NUM_BAG_SLOTS)
		end

		if(not slotID) then
			local bagID = inventoryIDToBagID[inventoryID]
			if(bagID) then
				UpdateBag(bagID)
			end
		end
	else
		for bagID in next, bags do
			UpdateBag(bagID)
		end
	end
end

local function OnClick(self)
	if(self.PurchaseIcon:IsShown()) then
		BankFrame.nextSlotCost = GetBankSlotCost(GetNumBankSlots())
		StaticPopup_Show('CONFIRM_BUY_BANK_SLOT')
		return
	end

	if(CursorHasItem()) then
		PutItemInBag(self:GetID())
	else
		PickupBagFromSlot(self:GetID())
	end
end

local function OnDragStart(self)
	PickupBagFromSlot(self:GetID())
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	if(not GameTooltip:SetInventoryItem('player', self:GetID())) then
		if(self.PurchaseIcon:IsShown()) then
			GameTooltip:SetText(L['Purchase'])
		else
			GameTooltip:SetText(L['Equip Container'])
		end
	end

	GameTooltip:Show()
end

local function CreateBag(self, index, bagID)
	local inventoryID = ContainerIDToInventoryID(bagID)

	local Bag = CreateFrame('Button', '$parentBag' .. index, self, 'ItemButtonTemplate')
	Bag:RegisterForDrag('LeftButton')
	Bag:SetScript('OnClick', OnClick)
	Bag:SetScript('OnReceiveDrag', OnClick)
	Bag:SetScript('OnDragStart', OnDragStart)
	Bag:SetScript('OnEnter', OnEnter)
	Bag:SetScript('OnLeave', GameTooltip_Hide)
	Bag:SetID(inventoryID)
	Bag.bagID = bagID
	Bag.isBank = bagID > NUM_BAG_SLOTS

	local PurchaseIcon = Bag:CreateTexture('$parentPurchaseIcon', 'ARTWORK')
	PurchaseIcon:SetPoint('CENTER')
	PurchaseIcon:SetSize(16, 16)
	PurchaseIcon:SetTexture([[Interface\GossipFrame\BankerGossipIcon]])
	PurchaseIcon:Hide()
	Bag.PurchaseIcon = PurchaseIcon

	local bagName = Bag:GetName()
	Bag.Icon = _G[bagName .. 'IconTexture']
	Bag.NormalTexture = Bag:GetNormalTexture()
	Bag.PushedTexture = Bag:GetPushedTexture()
	Bag.HighlightTexture = Bag:GetHighlightTexture()
	Bag.Stock = _G[bagName .. 'Stock']
	Bag.Border = _G[bagName .. 'Border']
	Bag.SearchOverlay = _G[bagName .. 'SearchOverlay']

	local Container = self:GetParent():GetParent()

	local sizeX = Container.slotSizeX or Container.slotSize or 32
	local spacingX = Container.spacingX or Container.spacing or 4

	Bag:SetPoint('BOTTOMLEFT', (sizeX + spacingX) * (index - 1), 0)

	inventoryIDToBagID[inventoryID] = bagID
	bags[bagID] = Bag

	P.SkinCallback('Slot', Bag)
	P.Fire('PostCreateBagSlot', Bag)

	UpdateBag(bagID)
end

local function OnShow(self)
	local Container = self:GetParent()

	local slotSizeY = Container.slotSizeY or Container.slotSize or 32
	local extraPaddingY = Container.extraPaddingY or Container.extraPadding or 0

	Container.overridePaddingY = extraPaddingY + (slotSizeY * 1.5)

	P.UpdateContainerSizes(Container, true)
end

local function OnHide(self)
	local Container = self:GetParent()
	Container.overridePaddingY = nil

	P.UpdateContainerSizes(Container, true)
end

local function CreateParent(self)
	local Parent = CreateFrame('Frame', '$parentBagSlots', self)
	Parent:Hide()
	Parent:SetScript('OnShow', OnShow)
	Parent:SetScript('OnHide', OnHide)

	P.Fire('PostCreateBagSlot', Parent)

	self.BagSlots = Parent

	return Parent
end

local function Toggle(self)
	local BagSlots = self:GetParent().BagSlots
	BagSlots:SetShown(not BagSlots:IsShown())
end

local function HideBagSlots(self)
	self.BagSlots:Hide()
end

local function Init(self, isBank)
	local Button = P.CreateContainerButton('ToggleBagSlots', 1, isBank)
	Button:SetScript('OnClick', Toggle)
	Button.tooltipText = L['Toggle bag slots']
	self.ToggleBagSlots = Button

	local BagSlots = CreateParent(self)
	local numBagSlots = isBank and NUM_BANKBAGSLOTS or NUM_BAG_SLOTS
	for index = 1, numBagSlots do
		CreateBag(BagSlots, index, index + (isBank and NUM_BAG_SLOTS or 0))
	end

	if(not P.Override('PositionBagSlots', BagSlots)) then
		-- use the same position variables as the slots and containers use
		-- might want to use something custom here though
		local sizeX = self.slotSizeX or self.slotSize or 32
		local sizeY = self.slotSizeY or self.slotSize or 32

		local spacingX = self.spacingX or self.spacing or 4
		local spacingY = self.spacingY or self.spacing or 4

		local paddingX = self.paddingX or self.padding or 10
		local paddingY = self.paddingY or self.padding or 10

		local extraPaddingY = self.extraPaddingY or self.extraPadding or 0

		BagSlots:SetPoint('BOTTOMRIGHT', - paddingX, extraPaddingY - paddingY + spacingY)
		BagSlots:SetSize(((sizeX + spacingX) * numBagSlots) - spacingX, sizeY)
	end

	P.Fire('PostCreateBagSlots', Button, BagSlots)

	self:HookScript('OnHide', HideBagSlots)
end

Backpack:AddModule('BagSlots', Init, Update, true, 'BAG_UPDATE', 'BANKFRAME_OPENED', 'PLAYERBANKBAGSLOTS_CHANGED', 'ITEM_LOCK_CHANGED')
