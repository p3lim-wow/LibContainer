local P = unpack(select(2, ...))

local containers, containerIndices = {}, {}
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

	if(not P.Override('SkinContainer', Container)) then
		P.SkinContainer(Container)
	end

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
	local slots = Slot.Container.Slots
	for index = #slots, 1, -1 do
		local slotData = slots[index]
		if(slotData[1] == Slot.bagID and slotData[2] == Slot.slotID) then
			Slot.Container = nil

			table.remove(slots, index)
		end
	end
end

function P.GetContainers()
	return containers
end
