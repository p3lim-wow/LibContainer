local L = LibContainer.locale

--[[ AutoVendor:header
Creates a button that allows toggling whether junk should be auto-sold to merchants.

Example:
```Lua
local Bags = LibContainer:New('bags', 'MyBags')
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
	local AutoVendor = Container:AddWidget('AutoVendor')
	AutoVendor:SetPoint('TOPRIGHT')
	AutoVendor:SetSize(20, 20)
	AutoVendor:SetTexture(...)
end)
```
--]]

local function OnClick()
	LibContainer:SetVariable('autoSellJunk', not LibContainer:GetVariable('autoSellJunk'))
end

local function OnEnter(Widget)
	GameTooltip:SetOwner(Widget, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(L['Toggle auto-vendoring'])
	GameTooltip:Show()
end

local lastNumItems = 0
local function Update(Widget, event, ...)
	if(LibContainer:GetVariable('autoSellJunk') and not IsShiftKeyDown()) then
		if(event == 'MERCHANT_SHOW' or lastNumItems > 0) then
			lastNumItems = 0

			local Container = Widget:GetParent()
			for _, Slot in next, Container:GetSlots() do
				if(not MerchantFrame:IsShown()) then
					return
				end

				if(Slot:IsItemValuable()) then
					lastNumItems = lastNumItems + 1
					UseContainerItem(Slot:GetBagAndSlot())
				end
			end
		end
	end
end

local function Enable(Widget)
	Widget:SetScript('OnClick', OnClick)
	Widget:SetScript('OnEnter', OnEnter)
	Widget:SetScript('OnLeave', GameTooltip_Hide)

	Widget:RegisterEvent('MERCHANT_SHOW')
	Widget:RegisterEvent('MERCHANT_CLOSED')
	Widget:RegisterEvent('BAG_UPDATE_DELAYED')
end

local function Disable(Widget)
	Widget:UnregisterEvent('MERCHANT_SHOW')
	Widget:UnregisterEvent('MERCHANT_CLOSED')
	Widget:UnregisterEvent('BAG_UPDATE_DELAYED')
end

LibContainer:RegisterWidget('AutoVendor', Enable, Disable, Update)
