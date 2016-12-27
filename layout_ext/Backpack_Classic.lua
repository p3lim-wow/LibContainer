local ICON_TEXTURES = [[Interface\AddOns\Backpack_Classic\assets\icons]]
--@do-not-package@
local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]
local ICON_TEXTURES = [[Interface\AddOns\Backpack\assets\icons]]
--@end-do-not-package@
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

local function SkinContainer(Container)
	local Title = Container:CreateFontString('$parentTitle', 'ARTWORK')
	Title:SetPoint('TOPLEFT', 11, -10)
	--@do-not-package@
	Title:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	--@end-do-not-package@
	--[===[@non-debug@
	Title:SetFontObject('BackpackClassicFont')
	--@end-non-debug@]===]
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

	local ItemLevel = Slot:CreateFontString('$parentItemLevel', 'ARTWORK')
	ItemLevel:SetPoint('BOTTOM', 2, 2)
	--@do-not-package@
	ItemLevel:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	--@end-do-not-package@
	--[===[@non-debug@
	ItemLevel:SetFontObject('BackpackClassicFont')
	--@end-non-debug@]===]
	ItemLevel:SetJustifyH('CENTER')
	Slot.ItemLevel = ItemLevel

	local Icon = Slot.Icon
	Icon:ClearAllPoints()
	Icon:SetPoint('TOPLEFT', 1, -1)
	Icon:SetPoint('BOTTOMRIGHT', -1, 1)
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local Count = Slot.Count
	Count:SetPoint('BOTTOMRIGHT', 0, 2)
	--@do-not-package@
	Count:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	--@end-do-not-package@
	--[===[@non-debug@
	Count:SetFontObject('BackpackClassicFont')
	--@end-non-debug@]===]
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
	local r, g, b, hex = GetItemQualityColor(itemQuality)

	local Icon = Slot.Icon
	Icon:SetTexture(itemTexture)
	Icon:SetDesaturated(isLocked)

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
	local scanTip = CreateFrame('GameTooltip', (...) .. 'ScanTip' .. math.floor(GetTime()), nil, 'GameTooltipTemplate')
	scanTip:SetOwner(WorldFrame, 'ANCHOR_NONE')
	scanTip.name = scanTip:GetName()

	Backpack:HookScript('OnShow', function(self)
		if(not BackpackCategoriesDB.categories[10].enabled) then
			return
		end

		local totalArtifactPower = 0

		for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			for slotID = 1, self:GetContainerNumSlots(bagID) do
				local itemID = self:GetContainerItemID(bagID, slotID)
				if(itemID) then
					scanTip:SetBagItem(bagID, slotID)
					scanTip:Show()

					for index = 1, scanTip:NumLines() do
						local line = _G[scanTip.name .. 'TextLeft' .. index]
						if(line and line:GetText()) then
							local artifactPower = string.match(line:GetText(), '([0-9?,?.]+) ' .. ARTIFACT_POWER)
							if(artifactPower) then
								totalArtifactPower = totalArtifactPower + tonumber((artifactPower:gsub(',', ''):gsub('%.', '')))
								break
							end
						end
					end
				end
			end
		end

		local Container = BackpackContainerArtifactPower
		Container.Title:SetFormattedText('%s |cff00ff00(%s)|r', Container.name, BreakUpLargeNumbers(totalArtifactPower))
	end)
end

Backpack:On('PostCreateMoney', function(Money)
	Money:ClearAllPoints()
	Money:SetPoint('BOTTOMRIGHT', -8, 10)
	--@do-not-package@
	Money:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	--@end-do-not-package@
	--[===[@non-debug@
	Money:SetFontObject('BackpackClassicFont')
	--@end-non-debug@]===]
	Money:SetShadowOffset(0, 0)
end)

Backpack:On('PostCreateCurrencies', function(Currencies)
	for index, Button in next, Currencies do
		local Label = Button.Label
		--@do-not-package@
		Label:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
		--@end-do-not-package@
		--[===[@non-debug@
		Label:SetFontObject('BackpackClassicFont')
		--@end-non-debug@]===]
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
	--@do-not-package@
	Editbox:SetFont(FONT, 8, 'OUTLINEMONOCHROME')
	--@end-do-not-package@
	--[===[@non-debug@
	Editbox:SetFontObject('BackpackClassicFont')
	--@end-non-debug@]===]
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

Backpack:On('PostCreateResetNew', function(Button)
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
