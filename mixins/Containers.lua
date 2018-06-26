local callbackMixin = LibContainer.mixins.callback
local parentMixin = LibContainer.mixins.parent

local containerMixin = {}
function containerMixin:AddSlot(Slot)
	table.insert(self.slots, Slot)
	self:UpdateSize()
end

function containerMixin:RemoveSlot(Slot)
	for index, containerSlot in next, self.slots do
		if(Slot == containerSlot) then
			table.remove(self.slots, index)
			self:UpdateSize()
			break
		end
	end
end

function containerMixin:UpdateSize()
	local numSlots = #self.slots
	local categoryIndex = self:GetID()

	if(numSlots > 0) then
		local slotSizeX, slotSizeY = self:GetSlotSize()
		local slotSpacingX, slotSpacingY = self:GetSlotSpacing()
		local slotPaddingX, slotPaddingY = self:GetSlotPadding()
		local paddingX, paddingY = self:GetPadding()

		local cols = self:GetMaxColumns()
		local rows = math.ceil(numSlots / cols)

		local width = (((slotSizeX + slotSpacingX) * cols) - slotSpacingX) + (slotPaddingX) + paddingX
		local height = (((slotSizeY + slotSpacingY) * rows) - slotSpacingY) + (slotPaddingY) + paddingY

		self:SetSize(width, height)
		self:UpdateSlotPositions()
		self:Show()
	else
		self:Hide()
	end
end

function containerMixin:UpdateSlotPositions()
	local category = LibContainer:GetCategory(self:GetID())
	table.sort(self.slots, category.sortFunc)

	local slotSizeX, slotSizeY = self:GetSlotSize()
	local slotSpacingX, slotSpacingY = self:GetSlotSpacing()
	local slotGrowX, slotGrowY = self:GetSlotGrowDirection()
	local slotRelPoint = self:GetSlotRelPoint()

	local cols = self:GetMaxColumns()
	local paddingX, paddingY = self:GetPadding()

	for index, Slot in next, self.slots do
		local col = (index - 1) % cols
		local row = math.floor((index - 1) / cols)

		local x = ((col * (slotSizeX + slotSpacingX)) + paddingX) * slotGrowX
		local y = ((row * (slotSizeY + slotSpacingY)) + paddingY) * slotGrowY

		Slot:ClearAllPoints()
		Slot:SetPoint(slotRelPoint, self, x, y)
	end
end

function containerMixin:OnShow()
	self:Fire('OnShow', self)
end

function containerMixin:OnHide()
	self:Fire('OnHide', self)
end

function containerMixin:SetMaxColumns(num)
	self.maxColumns = num
end

function containerMixin:GetMaxColumns()
	return self.maxColumns or 8
end

function containerMixin:SetSpacing(x, y)
	self.spacingX = x
	self.spacingY = y or x
end

function containerMixin:GetSpacing()
	return self.spacingX or 2, self.spacingY or 2
end

function containerMixin:SetPadding(x, y)
	self.paddingX = x
	self.paddingY = y or x
end

function containerMixin:GetPadding()
	return self.paddingX or 5, self.paddingY or 5
end

function containerMixin:GetLocalizedName()
	return LibContainer:GetCategory(self:GetID()):GetLocalizedName()
end

function containerMixin:GetSlotSize()
	local x, y = self.slotSizeX, self.slotSizeY
	if(not x and not y) then
		x, y = self.slots[1]:GetSize()
	end

	return x, y
end

function containerMixin:SetSlotSize(x, y)
	self.slotSizeX = x
	self.slotSizeY = y or x
end

function containerMixin:SetSlotRelPoint(relPoint)
	self.slotRelPoint = relPoint
end

function containerMixin:GetSlotRelPoint()
	return self.slotRelPoint or 'TOPLEFT'
end

function containerMixin:SetSlotSpacing(x, y)
	self.slotSpacingX = x
	self.slotSpacingY = y or x
end

function containerMixin:GetSlotSpacing()
	return self.slotSpacingX or 4, self.slotSpacingY or 4
end

function containerMixin:SetSlotPadding(x, y)
	self.slotPaddingX = x
	self.slotPaddingY = y or x
end

function containerMixin:GetSlotPadding()
	return self.slotPaddingX or 10, self.slotPaddingY or 10
end

function containerMixin:SetSlotGrowDirection(x, y)
	self.slotGrowX = x == 'LEFT' and -1 or x == 'RIGHT' and 1 or tonumber(x)
	self.slotGrowY = y == 'UP' and 1 or y == 'DOWN' and -1 or tonumber(y)
end

function containerMixin:GetSlotGrowDirection()
	return self.slotGrowX or 1, self.slotGrowY or -1
end

function parentMixin:GetContainer(categoryIndex)
	return self.containers[categoryIndex]
end

function parentMixin:CreateContainers()
	self.containers = {}

	for categoryIndex, info in next, self:GetCategories() do
		local Container = Mixin(CreateFrame('Frame', '$parentContainer' .. info.name, self), callbackMixin, containerMixin)
		Container:SetID(categoryIndex)
		Container:HookScript('OnShow', Container.OnShow)
		Container:HookScript('OnHide', Container.OnHide)
		Container:Hide()
		Container.slots = {}

		self:Fire('PostCreateContainer', Container)

		self.containers[categoryIndex] = Container
	end
end
