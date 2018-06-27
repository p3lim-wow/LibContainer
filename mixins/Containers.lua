local callbackMixin = LibContainer.mixins.callback
local parentMixin = LibContainer.mixins.parent

local containerMixin = {}
function containerMixin:AddSlot(Slot)
	table.insert(self.slots, Slot)
end

function containerMixin:RemoveSlot(Slot)
	for index, containerSlot in next, self.slots do
		if(Slot == containerSlot) then
			table.remove(self.slots, index)
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
		self:GetParent():UpdateContainerPositions()
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

function containerMixin:SetMaxColumns(num)
	self.maxColumns = num
end

function containerMixin:GetMaxColumns()
	return self.maxColumns or 8
end

function containerMixin:SetRelPoint(relPoint)
	self.relPoint = relPoint
end

function containerMixin:GetRelPoint()
	return self.relPoint or 'BOTTOMRIGHT'
end

function containerMixin:SetGrowDirection(x, y)
	self.growX = x == 'LEFT' and -1 or x == 'RIGHT' and 1 or tonumber(x)
	self.growY = y == 'UP' and 1 or y == 'DOWN' and -1 or tonumber(y)
end

function containerMixin:GetGrowDirection()
	return self.growX or -1, self.growY or 1
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

function containerMixin:GetName()
	return LibContainer:GetCategory(self:GetID()):GetName()
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

function parentMixin:UpdateContainerPositions()
	local visibleContainers = {}
	for categoryIndex, Container in next, self.containers do
		if(Container:IsShown()) then
			table.insert(visibleContainers, categoryIndex)
		end
	end

	table.sort(visibleContainers, self.SortContainers)

	local parentContainer = self:GetContainer(1) -- Inventory container is always parent
	local spacingX, spacingY = parentContainer:GetSpacing()
	local growX, growY = parentContainer:GetGrowDirection()
	local relPoint = parentContainer:GetRelPoint()

	-- set the position of the parent container first
	parentContainer:ClearAllPoints()
	parentContainer:SetPoint(relPoint)

	local parentTop = parentContainer:GetTop()
	local parentBottom = parentContainer:GetBottom()
	local cols = 1

	local _, maxHeight = GetPhysicalScreenSize()

	for index = 1, #visibleContainers do
		local Container = self:GetContainer(visibleContainers[index])
		if(Container ~= parentContainer) then
			local prevContainer = self:GetContainer(visibleContainers[index - 1]) or parentContainer
			local prevTop = prevContainer:GetTop()
			local prevBottom = prevContainer:GetBottom()

			if(growY > 0) then
				if((prevTop + Container:GetHeight() + spacingY) > maxHeight) then
					cols = cols + 1
					y = 0
				else
					y = prevTop - parentBottom + spacingY
				end
			else
				if((prevBottom - (Container:GetHeight() + spacingY)) < 0) then
					cols = cols + 1
					y = 0
				else
					y = prevTop - prevBottom + spacingY
				end
			end

			x = (Container:GetWidth() + spacingX) * (cols - 1)

			Container:ClearAllPoints()
			Container:SetPoint(relPoint, x * growX, y * growY)
		end
	end
end

function parentMixin:UpdateContainers()
	for _, Container in next, self:GetContainers() do
		Container:UpdateSize()
	end
end

function parentMixin:GetContainer(categoryIndex)
	return self.containers[categoryIndex]
end

function parentMixin:GetContainers()
	return self.containers
end

function parentMixin:CreateContainers()
	self.containers = {}

	for categoryIndex, info in next, self:GetCategories() do
		local Container = Mixin(CreateFrame('Frame', '$parentContainer' .. info.name, self), callbackMixin, containerMixin)
		Container:SetID(categoryIndex)
		Container:Hide()
		Container.slots = {}

		self:Fire('PostCreateContainer', Container)

		self.containers[categoryIndex] = Container
	end
end
