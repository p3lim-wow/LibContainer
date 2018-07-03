local L = LibContainer.locale

local function OnClick()
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'TOPRIGHT')
	-- GameTooltip:AddLine(L[''])
	GameTooltip:Show()
end

local function Update(self, event, ...)
end

local function Enable(self)
	self:SetScript('OnClick', OnClick)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)

	-- self:RegisterEvent('')
end

local function Disable(self)
	-- self:UnregisterEvent('')
end

LibContainer:RegisterWidget('Bags', Enable, Disable, Update)
