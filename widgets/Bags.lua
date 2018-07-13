--[[ Bags:header
Creates a button that will toggle the visibility of [bag slots](BagSlot) when clicked.  
It's completely useless unless also implementing the [BagSlot](BagSlot) widget in the layout.

Example:
```lua
Bags:SetPoint('CENTER')
Bags:On('PostCreateContainer', function(Container)
    local Bags = Container:AddWidget('Bags')
    Bags:SetPoint('TOPRIGHT')
    Bags:SetSize(20, 20)
    Bags:SetTexture(...)
end)
```
--]]
local L = LibContainer.locale

local function OnClick(Widget)
	local Parent = Widget:GetParent():GetParent()
	if(Parent.bagSlots) then
		for _, Slot in next, Parent.bagSlots do
			Slot:SetShown(not Slot:IsShown())
		end
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Toggle bag slots'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('Bags', Enable)
