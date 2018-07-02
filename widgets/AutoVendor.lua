local L = LibContainer.locale

local function OnClick()
	LibContainer:SetVariable('autoSellJunk', not LibContainer:GetVariable('autoSellJunk'))
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Toggle auto-vendoring'])
	GameTooltip:Show()
end

local lastNumItems = 0
local function Update(self, event, ...)
	if(LibContainer:GetVariable('autoSellJunk')) then
		if(event == 'MERCHANT_SHOW' or lastNumItems > 0) then
			lastNumItems = 0

			local Container = self:GetParent()
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

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)

	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('MERCHANT_CLOSED')
	self:RegisterEvent('BAG_UPDATE_DELAYED')
end

local function Disable(self)
	self:UnregisterEvent('MERCHANT_SHOW')
	self:UnregisterEvent('MERCHANT_CLOSED')
	self:UnregisterEvent('BAG_UPDATE_DELAYED')
end

LibContainer:RegisterWidget('AutoVendor', Enable, Disable, Update)
