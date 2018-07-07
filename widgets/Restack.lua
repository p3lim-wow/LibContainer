--[[ Restack:header
Creates a button that allows the user to sort the bags or bank.  
Since LibContainer is a category-based bag framework, sorting functionality doesn't make much sense,
but it's useful for re-stacking items to save space, hence the name.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local Restack = Container:AddWidget('Restack')
	Restack:SetPoint('TOPRIGHT')
	Restack:SetSize(20, 20)
	Restack:SetTexture(...)
end)
```
--]]

local L = LibContainer.locale

local function OnClick(self)
	local Container = self:GetParent()
	if(Container:GetParent():GetType() == 'bank') then
		SortBankBags()
	else
		SortBags()
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Restack'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('Restack', Enable)
