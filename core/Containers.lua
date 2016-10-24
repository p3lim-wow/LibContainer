local P = unpack(select(2, ...))

local containers = {}
function P.CreateContainer(category, Parent)
	local Container
	local categoryIndex = category.index
	if(categoryIndex == 1) then
		Container = Parent
		Container.type = Parent == Backpack and 1 or 2
	else
		local strippedName = string.gsub(category.name, ' ', '')
		Container = CreateFrame('Frame', '$parentContainer' .. strippedName, Parent)
	end

	Container:Hide()
	Container:SetID(categoryIndex)
	Container.name = category.name
	Container.slots = {}
	Container.numSlots = 0

	if(not containers[Parent]) then
		containers[Parent] = {}
	end

	P.SkinCallback('Container', Container)

	containers[Parent][categoryIndex] = Container
end

function P.GetCategoryContainer(parentContainer, categoryIndex)
	return containers[parentContainer][categoryIndex]
end

function P.AddContainerSlot(Slot, Container)
	Slot.Container = Container
	table.insert(Container.slots, Slot)
end

function P.RemoveContainerSlot(Slot)
	local slots = Slot.Container.slots
	for index = #slots, 1, -1 do
		local containerSlot = slots[index]
		if(containerSlot.bagID == Slot.bagID and containerSlot.slotID == Slot.slotID) then
			Slot.Container = nil

			table.remove(slots, index)
		end
	end
end

function P.GetAllContainers()
	return containers
end

function P.GetContainers(parentContainer)
	return containers[parentContainer]
end

function P.UpdateContainerSizes(parentContainer)
	local containers, changes = P.GetContainers(parentContainer)
	for categoryIndex, Container in next, containers do
		local numSlots = #Container.slots
		if(categoryIndex == 1 or categoryIndex == 1002) then
			-- Inventory and ReagentBank needs an additional slot for FreeSlots module
			numSlots = numSlots + 1
		end

		if(numSlots ~= Container.numSlots) then
			Container.numSlots = numSlots
			changes = true

			if(numSlots > 0) then
				-- defaults
				local sizeX = Container.slotSizeX or Container.slotSize or 32
				local sizeY = Container.slotSizeY or Container.slotSize or 32

				local spacingX = Container.spacingX or Container.spacing or 4
				local spacingY = Container.spacingY or Container.spacing or 4

				local paddingX = Container.paddingX or Container.padding or 10
				local paddingY = Container.paddingY or Container.padding or 10

				local extraPaddingX = Container.extraPaddingX or Container.extraPadding or 0
				local extraPaddingY = Container.extraPaddingY or Container.extraPadding or 0

				local cols = Container.columns or 8
				local rows = math.ceil(numSlots / cols)

				local width = (((sizeX + spacingX) * cols) - spacingX) + (paddingX * 2) + extraPaddingX
				local height = (((sizeY + spacingY) * rows) - spacingY) + (paddingY * 2) + extraPaddingY

				Container:SetSize(width, height)

				if(categoryIndex ~= 1) then
					Container:Show()
				end
			else
				-- no slots
				Container:Hide()
			end
		end
	end

	if(changes) then
		P.UpdateContainerPositions(parentContainer)
	end
end

local function UpdateContainerOrders(parentContainer)
	local parentContainerType = parentContainer.type
	for categoryIndex, Container in next, containers[parentContainer] do
		if(categoryIndex ~= 1) then
			local found
			for index, containerName in next, BackpackDB.containerOrder[parentContainerType] do
				if(Container:GetName() == containerName) then
					found = true
					break
				end
			end

			if(not found) then
				table.insert(BackpackDB.containerOrder[parentContainerType], Container:GetName())
			end
		end
	end
end

function P.UpdateContainerPositions(parentContainer)
	UpdateContainerOrders(parentContainer)

	local visibleContainers = {}
	for index, containerName in next, BackpackDB.containerOrder[parentContainer.type] do
		local Container = _G[containerName]
		if(Container:IsShown()) then
			table.insert(visibleContainers, Container)
		end
	end

	local spacingX = parentContainer.containerSpacingX or 2
	local spacingY = parentContainer.containerSpacingY or 2

	local point = parentContainer:GetPoint()
	local growX = string.find(point, 'RIGHT') and -1 or 1
	local growY = string.find(point, 'TOP') and -1 or 1

	local parentTop = parentContainer:GetTop()
	local parentBottom = parentContainer:GetBottom()
	local cols = 1

	local resolution = select(GetCurrentResolution(), GetScreenResolutions())
	local resolutionHeight = tonumber(string.match(resolution, '%d+x(%d+)'))

	for index, Container in next, visibleContainers do
		local prevContainer = visibleContainers[index - 1] or parentContainer
		local prevTop = prevContainer:GetTop()
		local prevBottom = prevContainer:GetBottom()

		local x, y
		if(growY > 0) then
			if((prevTop + Container:GetHeight() + spacingY) > resolutionHeight) then
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
				y = parentTop - prevBottom + spacingY
			end
		end

		x = (Container:GetWidth() + spacingX) * (cols - 1)

		Container:ClearAllPoints()
		Container:SetPoint(point, x * growX, y * growY)
	end
end
