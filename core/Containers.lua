local P = unpack(select(2, ...))

local containers, containerIndices = {}, {}
function P.CreateContainer(category, Parent)
	local Container
	local categoryIndex = category.index
	if(categoryIndex == 1) then
		Container = Parent

		-- TEMP
		Container:SetPoint('BOTTOM', UIParent, 0, 300)
	else
		local strippedName = string.gsub(category.name, ' ', '')
		Container = CreateFrame('Frame', '$parentContainer' .. strippedName, Parent)
	end

	Container:SetID(categoryIndex)
	Container.name = category.name
	Container.slots = {}

	local Title = Container:CreateFontString('$parentTitle', 'ARTWORK')
	Container.Title = Title

	local Anchor = CreateFrame('Frame', '$parentAnchor', Container)
	Anchor:SetSize(1, 1) -- needs a size
	Container.Anchor = Anchor

	if(not P.Override('SkinContainer', Container)) then
		P.SkinContainer(Container)
	end

	Title:SetText(Container.name)

	containers[categoryIndex] = Container
	table.insert(containerIndices, Container)
end

function P.GetCategoryContainer(categoryIndex)
	return containers[categoryIndex]
end

function P.AddContainerSlot(Slot, Container)
	Slot.Container = Container
	table.insert(Container.slots, {Slot.bagID, Slot.slotID})
end

function P.RemoveContainerSlot(Slot)
	for index, slotData in next, Slot.Container.slots do
		if(slotData[1] == Slot.bagID and slotData[2] == Slot.slotID) then
			Slot.Container.slots[index] = nil
			return
		end
	end
end

function P.GetContainers()
	return containers
end
