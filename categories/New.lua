local P, E, L = unpack(select(2, ...))

local categoryName = L['New Items']
local categoryIndex = 1001

local categoryFilter = function(bagID, slotID, itemID)
	local custom = BackpackCustomCategory[itemID]
	if(custom and custom == categoryIndex) then
		return true
	elseif(not custom) then
		local _, _, _, itemQuality = Backpack:GetContainerItemInfo(bagID, slotID)
		if(itemQuality > LE_ITEM_QUALITY_POOR) then
			-- don't mark junk as new items
			return not BackpackKnownItems[itemID]
		end
	end
end

Backpack:AddCategory(categoryIndex, categoryName, categoryFilter)

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(L['Mark items as known'])
	GameTooltip:Show()
end

local function OnClick(self)
	local Container = P.GetCategoryContainer(self.parentContainer, 1001)
	for _, Slot in next, Container.slots do
		local itemID = Slot.itemID
		BackpackKnownItems[itemID] = true
		BackpackCustomCategory[itemID] = nil
	end

	P.UpdateAllSlots('ResetNew')
	P.PositionSlots()
end

local function Init(self)
	local Parent = _G[self:GetName() .. 'ContainerNewItems']

	local Button = CreateFrame('Button', '$parentResetNew', Parent)
	Button:SetPoint('TOPRIGHT', -8, -8)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', OnClick)
	Button:SetScript('OnEnter', ShowTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)
	Button.parentContainer = self
	self.ResetNew = Button

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-RefreshButton]])
	Button.Texture = Texture

	P.Fire('PostCreateResetNew', self)
end

Backpack:AddModule('ResetNew', Init, nil, true)
