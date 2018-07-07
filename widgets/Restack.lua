--[[ Restack:header
Creates a button that allows the user to sort the bags, bank or reagent bank.  
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
	if(Container:GetName() == 'ReagentBank') then
		SortReagentBankBags()
	else
		if(Container:GetParent():GetType() == 'bank') then
			SortBankBags()
		else
			SortBags()
		end
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Restack'])
	GameTooltip:Show()
end

local function Update(self, event)
	if(event == 'REAGENTBANK_PURCHASED') then
		self:Show()
		self:UnregisterEvent(event)
	end
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
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

LibContainer:RegisterWidget('Restack', Enable, Disable, Update)
