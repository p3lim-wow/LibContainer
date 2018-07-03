--[[ Restack:header
Creates a button that allows the user to sort the bags.  
Since LibContainer is a category-based bag framework, this functionality doesn't make much sense,
but it's useful to re-stack items in the bags to save space.

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

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Restack'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', SortBags)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('Restack', Enable)
