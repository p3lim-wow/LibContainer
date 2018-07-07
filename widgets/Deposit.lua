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

local function Update(self, event)
	if(event == 'REAGENTBANK_PURCHASED') then
		self:Show()
		self:UnregisterEvent(event)
	end
end

local function Enable(self)
	self:SetScript('OnClick', DepositReagentBank)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)

	if(self:GetParent():GetID() == 999 and not IsReagentBankUnlocked()) then
		self:RegisterEvent('REAGENTBANK_PURCHASED')
		self:Hide()
	end
end

local function Disable(self)
	if(self:IsEventRegistered('REAGENTBANK_PURCHASED')) then
		self:UnregisterEvent('REAGENTBANK_PURCHASED')
	end
end

LibContainer:RegisterWidget('Deposit', Enable, Disable, Update)
