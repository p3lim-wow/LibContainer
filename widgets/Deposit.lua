local L = LibContainer.locale

--[[ Deposit:header
Creates a button that when clicked deposits all reagents from the inventory to the reagent bank.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local Deposit = Container:AddWidget('Deposit')
	Deposit:SetPoint('TOPRIGHT')
	Deposit:SetSize(20, 20)
	Deposit:SetTexture(...)
end)
```
--]]

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Deposit All Reagents'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', DepositReagentBank)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('Deposit', Enable, nop, nop)
