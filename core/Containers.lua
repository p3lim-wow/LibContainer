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

	if(not P.Override('SkinContainer', Container)) then
		P.SkinContainer(Container)
	end

	if(not containers[Parent]) then
		containers[Parent] = {}
	end

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

function P.GetContainers(parentContainer)
	return containers[parentContainer]
end
