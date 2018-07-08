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

local function OnEnter(Widget)
	GameTooltip:SetOwner(Widget, 'TOPRIGHT')
	GameTooltip:AddLine(L['Toggle auto-depositing'])
	GameTooltip:Show()
end

local function Update(Widget, event)
	if(event == 'REAGENTBANK_PURCHASED') then
		Widget:Show()
		Widget:UnregisterEvent(event)
	elseif(event == 'BANKFRAME_OPENED') then
		if(IsReagentBankUnlocked() and LibContainer:GetVariable('autoDeposit') and not IsShiftKeyDown()) then
			DepositReagentBank()
		end
	end
end

local function Enable(Widget)
	Widget:SetScript('OnClick', OnClick)
	Widget:SetScript('OnEnter', OnEnter)
	Widget:SetScript('OnLeave', GameTooltip_Hide)

	Widget:RegisterEvent('BANKFRAME_OPENED')

	if(Widget:GetParent():GetID() == 999 and not IsReagentBankUnlocked()) then
		Widget:RegisterEvent('REAGENTBANK_PURCHASED')
		Widget:Hide()
	end
end

local function Disable(Widget)
	Widget:UnregisterEvent('BANKFRAME_OPENED')

	if(Widget:IsEventRegistered('REAGENTBANK_PURCHASED')) then
		Widget:UnregisterEvent('REAGENTBANK_PURCHASED')
	end
end

LibContainer:RegisterWidget('AutoDeposit', Enable, Disable, Update)
