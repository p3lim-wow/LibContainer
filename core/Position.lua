local P, E, L = unpack(select(2, ...))

local defaultPositions = {
	Backpack = {'BOTTOMRIGHT', -50, 50},
	BackpackBank = {'TOPLEFT', 50, -50},
}

local function OnDragStop(self)
	if(BackpackDB.locked) then
		return
	end

	self:StopMovingOrSizing()

	local left, bottom, width, height = self:GetRect()
	local screenWidth, screenHeight = UIParent:GetSize()

	local point, x, y
	if((left + (width / 2)) >= (screenWidth / 2)) then
		point = 'RIGHT'
		x = - math.ceil(screenWidth - (left + width) + 0.5)
	else
		point = 'LEFT'
		x = math.floor(left + 0.5)
	end

	if((bottom + (height / 2)) >= (screenHeight / 2)) then
		point = 'TOP' .. point
		y = - math.ceil(screenHeight - (bottom + height) + 0.5)
	else
		point = 'BOTTOM' .. point
		y = math.floor(bottom + 0.5)
	end

	self:ClearAllPoints()
	self:SetPoint(point, 'UIParent', x, y)

	local savedPosition = BackpackPosition[self:GetName()]
	savedPosition[1] = point
	savedPosition[2] = x
	savedPosition[3] = y

	P.UpdateContainerPositions(self)
end

local function OnDragStart(self)
	if(not BackpackDB.locked) then
		self:StartMoving()
	end
end

function P.InitializePosition(self)
	if(not BackpackPosition) then
		BackpackPosition = defaultPositions
	end

	local point, x, y = unpack(BackpackPosition[self:GetName()])
	self:SetPoint(point, 'UIParent', x, y)

	self:SetClampedToScreen(true)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag('LeftButton')

	self:SetScript('OnDragStart', OnDragStart)
	self:SetScript('OnDragStop', OnDragStop)
end

local function OnClick(self)
	BackpackDB.locked = not BackpackDB.locked

	self.tooltipText = BackpackDB.locked and L['Unlock'] or L['Lock']
	self:UpdateTooltip()
end

local function Init(self, isBank)
	local Button = P.CreateContainerButton('ToggleLock', 1, isBank)
	Button:SetScript('OnClick', OnClick)
	Button.tooltipText = L['Unlock']
	self.ToggleLock = Button

	if(isBank) then
		Button.overrideShouldShow = function()
			return true
		end
	end

	P.Fire('PostCreateToggleLock', Button)
end

Backpack:AddModule('ToggleLock', Init, nil, true)
