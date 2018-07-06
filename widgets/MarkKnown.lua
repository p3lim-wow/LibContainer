local L = LibContainer.locale

--[[ MarkKnown:header
Creates a button that allows re-categorizing the entire New [category](Category)'s [slots](Slot),
marking them as "known" items.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local MarkKnown = Container:AddWidget('MarkKnown')
	MarkKnown:SetPoint('TOPRIGHT')
	MarkKnown:SetSize(20, 20)
	MarkKnown:SetTexture(...)
end)
```
--]]

local function OnClick(self)
	local Container = self:GetParent()
	local slots = Container:GetSlots()

	-- we have to iterate through this in reverse because the slots table will
	-- diminish while we iterate through it. an alternate solution is to copy
	-- the table, but that seems wasteful.
	for index = #slots, 1, -1 do
		local Slot = slots[index]
		local category = Slot:GuessCategory(true)
		Slot:AssignCategory(category.index)
	end

	Container:GetParent():UpdateContainers()
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Mark items as known'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('MarkKnown', Enable, nop, nop)
