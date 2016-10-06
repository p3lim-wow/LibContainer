local P = unpack(select(2, ...))
P.categories = {}

local MAX_INDEX = 1001
local MIN_INDEX = 0
local ASSIGN_INDEX = 1e2

local function defaultSort(slotA, slotB)
	if(not slotA or not slotB) then
		return slotA or slotB
	elseif(slotA.itemQuality ~= slotB.itemQuality) then
		return slotA.itemQuality > slotB.itemQuality
	elseif(slotA.itemLevel ~= slotB.itemLevel) then
		return slotA.itemLevel > slotB.itemLevel
	elseif(slotA.itemID ~= slotB.itemID) then
		return slotA.itemID > slotB.itemID
	elseif(slotA.itemCount ~= slotB.itemCount) then
		return slotA.itemCount > slotB.itemCount
	else
		return slotA.slotID > slotB.slotID
	end
end

function P.GetCategory(bagID, slotID, itemID)
	local categories = P.categories

	local reverse = {}
	for categoryIndex in next, categories do
		table.insert(reverse, 1, categoryIndex)
		table.sort(reverse)
	end

	for index = #reverse, 1, -1 do
		local category = categories[reverse[index]]
		if(category.filterFunc(bagID, slotID, itemID)) then
			return category
		end
	end
end

-- @name Backpack:AddCategory
-- @usage Backpack:AddCategory(index, name, filterFunc[, sortFunc])
-- @param index      - Category index, higher is prioritized (will be assigned one between 100 and 999 if nil)
-- @param name       - Category name, displayed as a label on the container and menu
-- @param filterFunc - Function to determine if an item should be part of this category or not
-- @param sortFunc   - Function to allow custom sorting within the category (optional)
P.Expose('AddCategory', function(_, index, name, filterFunc, sortFunc)
	assert(name, string.format('Missing required parameter "name" for category "%s".', name))
	assert(type(name) == 'string', string.format('Parameter "name" for category "%s" must be a string.', name))

	if(index) then
		if(type(index) ~= 'number') then
			error(string.format('Index for category "%s" must be a number, was "%s".', name, type(index)), 2)
		elseif(index > MAX_INDEX or index < MIN_INDEX) then
			error(string.format('Index \'%d\' for category "%s" is out of bounds.', index, name), 2)
		elseif(P.categories[index]) then
			error(string.format('Index \'%d\' is already occupied by category "%s".', index, P.categories[index].name), 2)
		end
	else
		local index = ASSIGN_INDEX
		while(P.categories[index] and index <= MAX_INDEX) do
			index = index + 1
		end

		if(index >= MAX_INDEX) then
			-- this addon must be popular!
			error(string.format('Automatic index for category "%s" could not be provided.', name))
		end
	end

	assert(filterFunc, string.format('Missing required parameter "filterFunc" for category "%s".', name))
	assert(type(filterFunc) == 'function', string.format('Parameter "filterFunc" for category "%s" must be a function.', name))

	if(sortFunc) then
		assert(type(sortFunc) == 'function', string.format('Parameter "sortFunc" for category "%s" must be a function.', name))
	end

	P.categories[index] = {
		index = index,
		name = name,
		filterFunc = filterFunc,
		sortFunc = sortFunc or defaultSort,
	}
end)
