local addonName = ...

local ICON_TEXTURES = [[Interface\AddOns\Backpack_Classic\assets\icons]]
--@do-not-package@
local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]
local normalFont = CreateFont('Backpack_ClassicFontNormal')
normalFont:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
normalFont:SetShadowOffset(0, 0)

local ICON_TEXTURES = [[Interface\AddOns\Backpack\assets\icons]]
--@end-do-not-package@
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

local disabledFont = CreateFont('Backpack_ClassicFontDisabled')
disabledFont:CopyFontObject('Backpack_ClassicFontNormal')
disabledFont:SetTextColor(DISABLED_FONT_COLOR:GetRGB())

local titleFont = CreateFont('Backpack_ClassicFontYellow')
titleFont:CopyFontObject('Backpack_ClassicFontNormal')
titleFont:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

LibStub('LibDropDown'):RegisterStyle(addonName, {
	gap = 18,
	padding = 8,
	spacing = 0,
	backdrop = {
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
		edgeFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeSize = 1
	},
	backdropColor = CreateColor(0, 0, 0, 0.9),
	backdropBorderColor = CreateColor(0, 0, 0),
	normalFont = normalFont,
	disabledFont = disabledFont,
	titleFont = titleFont,
})

Backpack.Dropdown:SetStyle(addonName)

local function SkinContainer(Container)
	local Title = Container:CreateFontString('$parentTitle', 'ARTWORK', 'Backpack_ClassicFontNormal')
	Title:SetPoint('TOPLEFT', 11, -10)
	Title:SetText(Container.name)
	Container.Title = Title

	local Anchor = CreateFrame('Frame', '$parentAnchor', Container)
	Anchor:SetPoint('TOPLEFT', 10, -26)
	Anchor:SetSize(1, 1) -- needs a size
	Container.anchor = Anchor

	Container:SetBackdrop(BACKDROP)
	Container:SetBackdropColor(0, 0, 0, 0.6)
	Container:SetBackdropBorderColor(0, 0, 0)
	Container.extraPaddingY = 16 -- needs a little extra because of the title

	if(Container == Backpack) then
		Container.extraPaddingY = 36 -- needs more space for the footer
	end
end

local function SkinSlot(Slot)
	Slot:SetSize(32, 32)
	Slot:SetBackdrop(BACKDROP)
	Slot:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	Slot:SetBackdropBorderColor(0, 0, 0)

	local ItemLevel = Slot:CreateFontString('$parentItemLevel', 'ARTWORK', 'Backpack_ClassicFontNormal')
	ItemLevel:SetPoint('BOTTOM', 2, 2)
	ItemLevel:SetJustifyH('CENTER')
	Slot.ItemLevel = ItemLevel

	local Icon = Slot.Icon
	Icon:ClearAllPoints()
	Icon:SetPoint('TOPLEFT', 1, -1)
	Icon:SetPoint('BOTTOMRIGHT', -1, 1)
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local Count = Slot.Count
	Count:SetPoint('BOTTOMRIGHT', 0, 2)
	Count:SetFontObject('Backpack_ClassicFontNormal')
	Count:Show()

	local Pushed = Slot.PushedTexture
	Pushed:ClearAllPoints()
	Pushed:SetPoint('TOPLEFT', 1, -1)
	Pushed:SetPoint('BOTTOMRIGHT', -1, 1)
	Pushed:SetColorTexture(1, 1, 1, 0.3)

	local Highlight = Slot.HighlightTexture
	Highlight:ClearAllPoints()
	Highlight:SetPoint('TOPLEFT', 1, -1)
	Highlight:SetPoint('BOTTOMRIGHT', -1, 1)
	Highlight:SetColorTexture(0, 0.6, 1, 0.3)

	Slot.NormalTexture:SetSize(0.1, 0.1)

	local QuestIcon = Slot.QuestIcon
	if(QuestIcon) then
		QuestIcon:Hide()
	end

	local Flash = Slot.Flash
	if(Flash) then
		Flash:Hide()
	end

	local BattlePay = Slot.BattlePay
	if(BattlePay) then
		BattlePay:Hide()
	end

	local NewItem = Slot.NewItem
	if(NewItem) then
		NewItem:ClearAllPoints()
		NewItem:SetPoint('TOPLEFT', 1, -1)
		NewItem:SetPoint('BOTTOMRIGHT', -1, 1)
		NewItem:SetBlendMode('BLEND')
	end
end

Backpack:AddLayout('Classic', SkinContainer, SkinSlot)

Backpack:Override('UpdateSlot', function(Slot)
	local itemTexture, itemCount, isLocked, itemQuality, isReadable, isLootable, _, _, _, itemID = Backpack:GetContainerItemInfo(Slot.bagID, Slot.slotID)
	local questItem, itemQuestID, itemQuestActive = Backpack:GetContainerItemQuestInfo(Slot.bagID, Slot.slotID)
	local r, g, b, hex = GetItemQualityColor(itemQuality)

	local Icon = Slot.Icon
	Icon:SetTexture(itemTexture)
	Icon:SetDesaturated(isLocked)

	local NewItem = Slot.NewItem
	if(NewItem) then
		if(itemQuality > LE_ITEM_QUALITY_POOR and C_NewItems.IsNewItem(Slot.bagID, Slot.slotID)) then
			NewItem:SetColorTexture(r, g, b, 0.5)
			NewItem:Show()
			Slot.NewItemAnim:Play()
		else
			NewItem:Hide()
			Slot.NewItemAnim:Stop()
		end
	end

	Slot.Count:SetText(itemCount > 1e3 and '*' or itemCount > 1 and itemCount or '')
	if(itemID) then
		local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
		if(itemQuality >= LE_ITEM_QUALITY_UNCOMMON and (itemClass == LE_ITEM_CLASS_WEAPON or itemClass == LE_ITEM_CLASS_ARMOR or (itemClass == LE_ITEM_CLASS_GEM and itemSubClass == 11))) then
			local ItemLevel = Slot.ItemLevel
			ItemLevel:SetFormattedText('|c%s%s|r', hex, Slot.itemLevel)
			ItemLevel:Show()
		else
			Slot.ItemLevel:Hide()
		end

		if(itemQuestID or questItem) then
			Slot:SetBackdropBorderColor(1, 1, 0)
		elseif(itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
			Slot:SetBackdropBorderColor(r, g, b)
		else
			Slot:SetBackdropBorderColor(0, 0, 0)
		end
	end
end)

do
	local function UpdateArtifactPower()
		if(not BackpackCategoriesDB.categories[10].enabled) then
			return
		end

		local totalArtifactPower = 0
		for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			for slotID = 1, Backpack:GetContainerNumSlots(bagID) do
				totalArtifactPower = totalArtifactPower + (GetContainerItemArtifactPower(bagID, slotID) or 0)
			end
		end

		local Container = BackpackContainerArtifactPower
		Container.Title:SetFormattedText('%s |cff00ff00(%s)|r', Container.name, BreakUpLargeNumbers(totalArtifactPower))
	end

	Backpack:HookScript('OnShow', function(self)
		self:RegisterEvent('BAG_UPDATE_DELAYED', UpdateArtifactPower)
		UpdateArtifactPower()
	end)

	Backpack:HookScript('OnHide', function(self)
		self:UnregisterEvent('BAG_UPDATE_DELAYED', UpdateArtifactPower)
	end)
end

Backpack:On('PostCreateMoney', function(Money)
	Money:ClearAllPoints()
	Money:SetPoint('BOTTOMRIGHT', -8, 10)
	Money:SetFontObject('Backpack_ClassicFontNormal')
	Money:SetShadowOffset(0, 0)
end)

Backpack:On('PostCreateCurrencies', function(Currencies)
	for index, Button in next, Currencies do
		local Label = Button.Label
		Label:SetFontObject('Backpack_ClassicFontNormal')
		Label:SetShadowOffset(0, 0)

		local Icon = Button.Icon
		Icon:SetSize(9, 9)
		Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		local IconBorder = Button:CreateTexture('$parentIconBorder', 'BORDER')
		IconBorder:SetPoint('TOPLEFT', Icon, -1, 1)
		IconBorder:SetPoint('BOTTOMRIGHT', Icon, 1, -1)
		IconBorder:SetColorTexture(0, 0, 0)

		Button:ClearAllPoints()
		if(index == 1) then
			Button:SetPoint('BOTTOMLEFT', 11, 10)
		else
			Button:SetPoint('LEFT', Currencies[index - 1], 'RIGHT', 10, 0)
		end
	end
end)

local function OnSearchOpen(self)
	self.Icon:Hide()
	self:SetFrameLevel(self:GetFrameLevel() + 1)
end

local function OnSearchClosed(self)
	local SearchBox = self:GetParent()
	SearchBox.Icon:Show()
	SearchBox:SetFrameLevel(SearchBox:GetFrameLevel() - 1)
end

Backpack:On('PostCreateSearch', function(SearchBox)
	SearchBox:SetBackdrop(BACKDROP)
	SearchBox:SetBackdropColor(0, 0, 0, 0.9)
	SearchBox:SetBackdropBorderColor(0, 0, 0)
	SearchBox:HookScript('OnClick', OnSearchOpen)

	local SearchBoxIcon = SearchBox:CreateTexture('$parentIcon', 'OVERLAY')
	SearchBoxIcon:SetPoint('CENTER')
	SearchBoxIcon:SetSize(16, 16)
	SearchBoxIcon:SetTexture(ICON_TEXTURES)
	SearchBoxIcon:SetTexCoord(0.75, 1, 0.75, 1)
	SearchBox.Icon = SearchBoxIcon

	local Editbox = SearchBox.Editbox
	Editbox:SetFontObject('Backpack_ClassicFontNormal')
	Editbox:SetShadowOffset(0, 0)
	Editbox:HookScript('OnEscapePressed', OnSearchClosed)

	local EditboxIcon = Editbox:CreateTexture('$parentIcon', 'OVERLAY')
	EditboxIcon:SetPoint('RIGHT', Editbox, 'LEFT', -4, 0)
	EditboxIcon:SetSize(16, 16)
	EditboxIcon:SetTexture(ICON_TEXTURES)
	EditboxIcon:SetTexCoord(0.75, 1, 0.75, 1)
	Editbox.Icon = EditboxIcon
end)

Backpack:On('PostCreateContainerButton', function(Button)
	Button.Texture:SetTexture(ICON_TEXTURES)
end)

Backpack:On('PostCreateBagSlots', function(Button)
	Button:GetParent().ToggleBagSlots.Texture:SetTexCoord(0, 0.25, 0.25, 0.5)
end)

local function OnClickDepositReagents(self)
	if(BackpackDB.autoDepositReagents) then
		self.Texture:SetVertexColor(1, 1, 1)
	else
		self.Texture:SetVertexColor(0.3, 0.3, 0.3)
	end
end

Backpack:On('PostCreateDepositReagents', function(Button)
	Button.Texture:SetTexCoord(0.5, 0.75, 0, 0.25)
	Button:HookScript('OnClick', OnClickDepositReagents)

	OnClickDepositReagents(Button)
end)

local function OnClickAutoDeposit(self)
	if(BackpackDB.autoDepositReagents) then
		self.Texture:SetVertexColor(0, 0.6, 1)
	else
		self.Texture:SetVertexColor(0.3, 0.3, 0.3)
	end
end

Backpack:On('PostCreateAutoDeposit', function(Button)
	Button.Texture:SetTexCoord(0.5, 0.75, 0, 0.25)
	Button:HookScript('OnClick', OnClickAutoDeposit)

	OnClickAutoDeposit(Button)
end)

local function OnClickSellJunk(self)
	if(BackpackDB.autoSellJunk) then
		self.Texture:SetVertexColor(1, 0.1, 0.1)
	else
		self.Texture:SetVertexColor(0.3, 0.3, 0.3)
	end
end

Backpack:On('PostCreateSellJunk', function(Button)
	Button.Texture:SetTexCoord(0, 0.25, 0, 0.25)
	Button:HookScript('OnClick', OnClickSellJunk)

	OnClickSellJunk(Button)
end)

Backpack:On('PostCreateResetUnknown', function(Button)
	Button.Texture:SetTexCoord(0.75, 1, 0, 0.25)
end)

Backpack:On('PostCreateRestack', function(Button, SecondButton)
	Button.Texture:SetTexCoord(0.25, 0.5, 0, 0.25)

	if(SecondButton) then
		SecondButton.Texture:SetTexCoord(0.25, 0.5, 0, 0.25)
	end
end)

local function OnClickToggleLock(self)
	if(Backpack.locked) then
		self.Texture:SetTexCoord(0, 0.25, 0.75, 1)
		self.Texture:SetVertexColor(1, 1, 1)
	else
		self.Texture:SetTexCoord(0.25, 0.5, 0.75, 1)
		self.Texture:SetVertexColor(0.1, 1, 0.1)
	end
end

Backpack:On('PostCreateToggleLock', function(Button)
	Button:HookScript('OnClick', OnClickToggleLock)
	OnClickToggleLock(Button)
end)
