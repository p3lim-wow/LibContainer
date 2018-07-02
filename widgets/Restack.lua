local L = LibContainer.locale

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	GameTooltip:AddLine(L['Restack'])
	GameTooltip:Show()
end

local function Enable(self)
	self:SetScript('OnClick', SortBags)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
end

LibContainer:RegisterWidget('Restack', Enable)
