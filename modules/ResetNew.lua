local P, E = unpack(select(2, ...))

local function OnClick(self)
	local Container = P.GetCategoryContainer(1001)
	for _, Slot in next, Container.slots do
		local itemID = Slot.itemID
		BackpackKnownItems[itemID] = true
		BackpackCustomCategory[itemID] = nil
	end

	P.UpdateAllSlots()

	if(not P.Override('PositionSlots')) then
		P.PositionSlots()
	end
end

local function Init(self)
	local Parent = BackpackContainerNewItems

	local Button = CreateFrame('Button', '$parentResetNew', Parent)
	Button:SetPoint('TOPRIGHT', -8, -8)
	Button:SetSize(16, 16)
	Button:SetScript('OnClick', OnClick)
	self.ResetNew = Button

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	Button.Texture = Texture

	P.Fire('PostCreateResetNew', self)
end

P.AddModule(Init)
