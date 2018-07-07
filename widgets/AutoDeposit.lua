local L = LibContainer.locale

--[[ AutoDeposit:header
Creates a button that allows toggling whether reagents should be auto-deposited to the reagent bank.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local AutoDeposit = Container:AddWidget('AutoDeposit')
	AutoDeposit:SetPoint('TOPRIGHT')
	AutoDeposit:SetSize(20, 20)
	AutoDeposit:SetTexture(...)
end)
```
--]]

local function OnClick()
	LibContainer:SetVariable('autoDeposit', not LibContainer:GetVariable('autoDeposit'))
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Toggle auto-depositing'])
	GameTooltip:Show()
end

local function Update()
	if(IsReagentBankUnlocked() and LibContainer:GetVariable('autoDeposit') and not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)

	self:RegisterEvent('BANKFRAME_OPENED')
end

local function Disable(self)
	self:UnregisterEvent('BANKFRAME_OPENED')
end

LibContainer:RegisterWidget('AutoDeposit', Enable, Disable, Update)
