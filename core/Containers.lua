local P = unpack(select(2, ...))

local containers = {}
function P.CreateContainer(category, Parent)
	local Container
	local categoryIndex = category.index
	if(categoryIndex == 1) then
		Container = Parent
	else
		local strippedName = string.gsub(category.name, ' ', '')
		Container = CreateFrame('Frame', '$parentContainer' .. strippedName, Parent)
	end

	Container:SetID(categoryIndex)
	Container.name = category.name
	Container.slots = {}

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

function P.ResizeContainers(parentContainer)
	local visibleContainers = {}

	local containers = P.GetContainers(parentContainer)
	for categoryIndex, Container in next, containers do
		local numSlots = #Container.slots
		if(categoryIndex == 1 or categoryIndex == 1002) then
			-- Inventory and ReagentBank needs an additional slot for FreeSlots module
			numSlots = numSlots + 1
		end

		if(numSlots > 0) then
			table.insert(visibleContainers, Container)

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

	P.PositionContainers(parentContainer, visibleContainers)
end

function P.PositionContainers(parentContainer, visibleContainers)
	local numVisibleContainers = #visibleContainers
	if(numVisibleContainers > 0) then -- the inventory can actually be empty
		for index, Container in next, visibleContainers do
			if(Container:GetID() == 1) then
				-- yank the parent out of there so it doesn't mess with positioning
				table.remove(visibleContainers, index)
				break
			end
		end

		for index, Container in next, visibleContainers do
			if(Container:GetID() == 1002) then
				-- shift the position for reagentbank so it's right after inventory
				table.remove(visibleContainers, index)
				table.insert(visibleContainers, 1, Container)
				break
			end
		end

		local anchorPoint = parentContainer.containerAnchorPoint or 'BOTTOM'
		local anchorPointRelative = parentContainer.containerAnchorPointRelative or 'TOP'

		local spacingX = parentContainer.containerSpacingX or 0
		local spacingY = parentContainer.containerSpacingY or 2

		for index, Container in next, visibleContainers do
			Container:ClearAllPoints()
			Container:SetPoint(anchorPoint, visibleContainers[index - 1] or Container:GetParent(), anchorPointRelative, spacingX, spacingY)
		end
	end
end
