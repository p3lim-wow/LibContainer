local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

local function SkinContainer(Container)
	local Title = Container:CreateFontString('$parentTitle', 'ARTWORK')
	Title:SetPoint('TOPLEFT', 11, -10)
	Title:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Title:SetText(Container.name)

	local Anchor = CreateFrame('Frame', '$parentAnchor', Container)
	Anchor:SetPoint('TOPLEFT', 10, -26)
	Anchor:SetSize(1, 1) -- needs a size
	Container.anchor = Anchor

	Container:SetBackdrop(BACKDROP)
	Container:SetBackdropColor(0, 0, 0, 0.6)
	Container:SetBackdropBorderColor(0, 0, 0)
	Container.extraPaddingY = 16 -- needs a little extra because of the title

	if(Container == Backpack) then
		Container.extraPaddingY = 32 -- needs more space for the footer
	end
end

local function SkinSlot(Slot)
	Slot:SetSize(32, 32)
	Slot:SetBackdrop(BACKDROP)
	Slot:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	Slot:SetBackdropBorderColor(0, 0, 0)

	local Icon = Slot.Icon
	Icon:ClearAllPoints()
	Icon:SetPoint('TOPLEFT', 1, -1)
	Icon:SetPoint('BOTTOMRIGHT', -1, 1)
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local Count = Slot.Count
	Count:SetPoint('BOTTOMRIGHT', 0, 2)
	Count:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
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
end

Backpack:AddLayout('Classic', SkinContainer, SkinSlot)

Backpack:Override('UpdateSlot', function(Slot)
	local itemTexture, itemCount, isLocked, itemQuality, isReadable, isLootable, _, _, _, itemID = Backpack:GetContainerItemInfo(Slot.bagID, Slot.slotID)
	local questItem, itemQuestID, itemQuestActive = Backpack:GetContainerItemQuestInfo(Slot.bagID, Slot.slotID)

	local Icon = Slot.Icon
	Icon:SetTexture(itemTexture)
	Icon:SetDesaturated(isLocked)

	Slot.Count:SetText(itemCount > 1e3 and '*' or itemCount > 1 and itemCount or '')

	if(itemQuestID or questItem) then
		Slot:SetBackdropBorderColor(1, 1, 0)
		r, g, b = 1, 1, 0
	elseif(itemQuality >= LE_ITEM_QUALITY_UNCOMMON) then
		Slot:SetBackdropBorderColor(GetItemQualityColor(itemQuality))
	else
		Slot:SetBackdropBorderColor(0, 0, 0)
	end
end)

Backpack:On('PostCreateMoney', function(self)
	local Money = self.Money
	Money:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Money:SetShadowOffset(0, 0)
end)

Backpack:On('PostCreateCurrencies', function(self)
	for _, Currency in next, self.Currencies do
		Currency:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		Currency:SetShadowOffset(0, 0)
	end
end)

local function OnSearchOpen(self)
	self.Icon:Hide()
end

local function OnSearchClosed(self)
	self:GetParent().Icon:Show()
end

Backpack:On('PostCreateSearch', function(self)
	local SearchBox = self.SearchBox
	SearchBox:SetBackdrop(BACKDROP)
	SearchBox:SetBackdropColor(0, 0, 0, 0.9)
	SearchBox:SetBackdropBorderColor(0, 0, 0)
	SearchBox:HookScript('OnClick', OnSearchOpen)

	local SearchBoxIcon = SearchBox:CreateTexture('$parentIcon', 'OVERLAY')
	SearchBoxIcon:SetPoint('CENTER')
	SearchBoxIcon:SetSize(14, 14)
	SearchBoxIcon:SetTexture([[Interface\Common\UI-Searchbox-Icon]])
	SearchBox.Icon = SearchBoxIcon

	local Editbox = SearchBox.Editbox
	Editbox:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	Editbox:SetShadowOffset(0, 0)
	Editbox:HookScript('OnEscapePressed', OnSearchClosed)

	local EditboxIcon = Editbox:CreateTexture('$parentIcon', 'OVERLAY')
	EditboxIcon:SetPoint('RIGHT', Editbox, 'LEFT', -4, 0)
	EditboxIcon:SetSize(14, 14)
	EditboxIcon:SetTexture([[Interface\Common\UI-Searchbox-Icon]])
	Editbox.Icon = EditboxIcon
end)
