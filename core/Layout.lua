local P = unpack(select(2, ...))

local FONT = [[Interface\AddOns\Backpack\assets\semplice.ttf]]
local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1}

function P.SkinContainer(Container)
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
	Container.paddingY = 18 -- needs a little extra because of the title

	if(Container:GetID() == 1) then
		Container:SetPoint('BOTTOMRIGHT', UIParent, -50, 50)
		Container.paddingY = 27 -- needs even more space for the footer

		Container:EnableMouse(true)
		Container:SetMovable(true)
		Container:CreateTitleRegion():SetAllPoints()
		Container:SetClampedToScreen(true)
	end
end

function P.SkinSlot(Slot)
	Slot:SetSize(32, 32)
	Slot:SetBackdrop(BACKDROP)
	Slot:SetBackdropColor(0, 0, 0, 0.8)
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

	Slot.QuestIcon:Hide()
	Slot.Flash:Hide()
	Slot.BattlePay:Hide()
end

function P.OnUpdateSlot(Slot, bagID, slotID)
	local itemTexture, itemCount, isLocked, itemQuality, isReadable, isLootable, _, _, _, itemID = GetContainerItemInfo(bagID, slotID)
	local questItem, itemQuestID, itemQuestActive = GetContainerItemQuestInfo(bagID, slotID)
	local cooldownStart, cooldownDuration, cooldownEnabled = GetContainerItemCooldown(bagID, slotID)

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

	CooldownFrame_Set(Slot.Cooldown, cooldownStart, cooldownDuration, cooldownEnabled)
end

function P.PositionSlots()
	local categorySlots = P.categorySlots
	for categoryIndex in next, categorySlots do
		table.sort(categorySlots[categoryIndex], P.categories[categoryIndex].sortFunc)
	end

	for categoryIndex, slots in next, categorySlots do
		local Container = P.GetCategoryContainer(categoryIndex)

		-- defaults
		local anchor = Container.anchor or Container
		local anchorPoint = Container.anchorPoint or 'TOPLEFT'

		local sizeX = Container.slotSizeX or Container.slotSize or 32
		local sizeY = Container.slotSizeY or Container.slotSize or 32

		local spacingX = Container.spacingX or Container.spacing or 4
		local spacingY = Container.spacingY or Container.spacing or 4

		local growX = Container.growX == 'LEFT' and -1 or 1
		local growY = Container.growY == 'UP' and 1 or -1

		local cols = Container.columns or 8

		for index, Slot in next, slots do
			local col = (index - 1) % cols
			local row = math.floor((index - 1) / cols)

			Slot:ClearAllPoints()
			Slot:SetPoint(anchorPoint, anchor, col * (sizeX + spacingX) * growX, row * (sizeY + spacingY) * growY)
		end
	end

	P.ResizeContainers()
end

function P.ResizeContainers()
	local visibleContainers = {}

	local containers = P.GetContainers()
	for categoryIndex, Container in next, containers do
		local numSlots = #Container.slots
		if(categoryIndex == 1) then
			numSlots = numSlots + 1
		end

		if(numSlots > 0) then
			table.insert(visibleContainers, Container)

			-- defaults
			local sizeX = Container.slotSizeX or Container.slotSize or 32
			local sizeY = Container.slotSizeY or Container.slotSize or 32

			local spacingX = Container.spacingX or Container.spacing or 4
			local spacingY = Container.spacingY or Container.spacing or 4

			local paddingX = Container.paddingX or Container.padding or 10
			local paddingY = Container.paddingY or Container.padding or 10

			local cols = Container.columns or 8
			local rows = math.ceil(numSlots / cols)

			local width = (((sizeX + spacingX) * cols) - spacingX) + (paddingX * 2)
			local height = (((sizeY + spacingY) * rows) - spacingY) + (paddingY * 2)

			Container:SetSize(width, height)
			Container:Show()
		else
			-- no slots
			Container:Hide()
		end
	end

	P.PositionContainers(visibleContainers)
end

function P.PositionContainers(visibleContainers)
	local numVisibleContainers = #visibleContainers
	if(numVisibleContainers > 0) then -- the inventory can actually be empty
		-- yank the parent out of there so it doesn't mess with positioning
		for index, Container in next, visibleContainers do
			if(Container:GetID() == 1) then
				table.remove(visibleContainers, index)
				break
			end
		end

		for index, Container in next, visibleContainers do
			Container:ClearAllPoints()
			Container:SetPoint('BOTTOM', visibleContainers[index - 1] or Container:GetParent(), 'TOP', 0, 2)
		end
	end
end

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
