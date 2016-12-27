local P, E, L = unpack(select(2, ...))
P.categories = {}

local MAX_INDEX = 999
local MIN_INDEX = 1e2

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

local function defaultFilter(bagID, slotID, itemID, categoryIndex)
	local custom = BackpackKnownItems[itemID]
	return custom and custom == categoryIndex
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
		if(BackpackCategoriesDB.categories[category.index].enabled and category.filterFunc(bagID, slotID, itemID, category.index)) then
			return category
		end
	end
end

function P.AddCategory(index, name, frameName, filterFunc, sortFunc)
	P.categories[index] = {
		index = index,
		name = name,
		frameName = frameName or name,
		filterFunc = filterFunc or defaultFilter,
		sortFunc = sortFunc or defaultSort,
	}

	return P.categories[index]
end

-- @name Backpack:AddCategory
-- @usage info = Backpack:AddCategory(index, name, filterFunc[, sortFunc])
-- @param index      - Category index, higher is prioritized (will be assigned one between 100 and 999 if nil)
-- @param name       - Category name, displayed as a label on the container and menu
-- @param frameName  - Container frame name, used for the global namespace (optional, uses name if not supplied (not recommended))
-- @param filterFunc - Function to determine if an item should be part of this category or not (optional)
-- @param sortFunc   - Function to allow custom sorting within the category (optional)
-- @return info      - Table containing information about the category
P.Expose('AddCategory', function(_, index, name, frameName, filterFunc, sortFunc)
	assert(name, string.format('Missing required parameter "name" for category "%d".', index))
	assert(type(name) == 'string', string.format('Parameter "name" for category "%d" must be a string.', index))

	if(index) then
		if(type(index) ~= 'number') then
			error(string.format('Index for category "%s" must be a number, was "%s".', frameName or name, type(index)), 2)
		elseif(index > MAX_INDEX or index < MIN_INDEX) then
			error(string.format('Index \'%d\' for category "%s" is out of bounds.', index, frameName or name), 2)
		elseif(P.categories[index]) then
			error(string.format('Index \'%d\' is already occupied by category "%s".', index, P.categories[index].frameName), 2)
		end
	else
		index = MIN_INDEX
		while(P.categories[index] and index <= MAX_INDEX) do
			index = index + 1
		end

		if(index >= MAX_INDEX) then
			-- this addon must be popular!
			error(string.format('Automatic index for category "%s" could not be provided.', frameName or name))
		end
	end

	if(frameName) then
		assert(type(frameName) == 'string', string.format('Parameter "frameName" for category "%d" must be a string.', index))
	end

	if(filterFunc) then
		assert(type(filterFunc) == 'function', string.format('Parameter "filterFunc" for category "%s" must be a function.', frameName or name))
	end

	if(sortFunc) then
		assert(type(sortFunc) == 'function', string.format('Parameter "sortFunc" for category "%s" must be a function.', frameName or name))
	end

	return P.AddCategory(index, name, frameName, filterFunc, sortFunc)
end)
