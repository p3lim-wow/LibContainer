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

local function OnClick(Widget)
	local Container = Widget:GetParent()
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

local function OnEnter(Widget)
	GameTooltip:SetOwner(Widget, 'TOPRIGHT')
	GameTooltip:AddLine(L['Restack'])
	GameTooltip:Show()
end

local function Update(Widget, event)
	if(event == 'REAGENTBANK_PURCHASED') then
		Widget:Show()
		Widget:UnregisterEvent(event)
	end
end

local function Enable(Widget)
	Widget:SetScript('OnClick', OnClick)
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

LibContainer:RegisterWidget('Restack', Enable, Disable, Update)
