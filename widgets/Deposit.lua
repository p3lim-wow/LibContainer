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

local function OnEnter(Widget)
	GameTooltip:SetOwner(Widget, 'TOPRIGHT')
	GameTooltip:AddLine(L['Deposit All Reagents'])
	GameTooltip:Show()
end

local function Update(Widget, event)
	if(event == 'REAGENTBANK_PURCHASED') then
		Widget:Show()
		Widget:UnregisterEvent(event)
	end
end

local function Enable(Widget)
	Widget:SetScript('OnClick', DepositReagentBank)
	Widget:SetScript('OnEnter', OnEnter)
	Widget:SetScript('OnLeave', GameTooltip_Hide)

	if(Widget:GetParent():GetID() == 999 and not IsReagentBankUnlocked()) then
		Widget:RegisterEvent('REAGENTBANK_PURCHASED')
		Widget:Hide()
	end
end

local function Disable(Widget)
	if(Widget:IsEventRegistered('REAGENTBANK_PURCHASED')) then
		Widget:UnregisterEvent('REAGENTBANK_PURCHASED')
	end
end

LibContainer:RegisterWidget('Deposit', Enable, Disable, Update)
