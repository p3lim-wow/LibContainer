local widgets = {}
local containerMixin = LibContainer.mixins.container

--[[ Widget:header
The Widget mixin serves the purpose of registering and initiating widgets; extra features one would
typically see of want out of a bag addon.

The available widgets are:
- [AutoDeposit](AutoDeposit)
- [AutoVendor](AutoVendor)
- [Bags](Bags)
- [Currencies](Currencies)
- [Deposit](Deposit)
- [FreeSlots](FreeSlots)
- [MarkKnown](MarkKnown)
- [Money](Money)
- [Positioning](Positioning)
- [Restack](Restack)
- [Search](Search)

See the individual pages for more information.
--]]

--[[ LibContainer:RegisterWidget(name, enableFunc[, disableFunc][, updateFunc][, createFunc])
Registers a new widget with the given name.

* name        - name of the new widget (string)
* enableFunc  - function which is run when the widget is created (function)
* disableFunc - function which is run when the widget is disabled (function, optional)
* updateFunc  - function which is run on event updates (function, optional)
* createFunc  - function which creates and returns the widget (function, optional)
--]]
function LibContainer:RegisterWidget(name, enable, disable, update, create)
	assert(not widgets[name], 'Widget \'' .. name .. '\' already exists.')
	assert(type(enable) == 'function', 'enable argument must be a function.')
	assert(disable == nil or type(disable) == 'function', 'disable argument must be a function or nil.')
	assert(update == nil or type(update) == 'function', 'update argument must be a function or nil.')
	assert(create == nil or type(create) == 'function', 'create argument must be a function or nil.')

	widgets[name] = {
		enable = enable,
		disable = disable or nop,
		update = update or nop,
		create = create or nop
	}
end

--[[ Container:AddWidget(name)
Creates and returns a new object for the widget with the given name.

* name - name of the widget (string)
--]]
function containerMixin:AddWidget(name)
	assert(widgets[name], 'name argument must be a valid widget name.')

	local obj = widgets[name].create(self) or CreateFrame('Button', '$parent' .. name .. 'Widget', self)
	obj:SetScript('OnEvent', widgets[name].update)

	self.widgets[name] = obj
	self:EnableWidget(name)
	self:UpdateWidget(name)
	return obj
end

--[[ Container:EnableWidget(name)
Enables the widget by name.

* name - name of widget (string)
--]]
function containerMixin:EnableWidget(name)
	assert(widgets[name], 'name argument must be a valid widget name.')
	widgets[name].enable(self.widgets[name])
end

--[[ Container:DisableWidget(name)
Disables the widget by name.

* name - name of widget (string)
--]]
function containerMixin:DisableWidget(name)
	assert(widgets[name], 'name argument must be a valid widget name.')
	widgets[name].disable(self.widgets[name])
end

--[[ Container:UpdateWidget(name)
Updates the widget by name.

* name - name of widget (string)
--]]
function containerMixin:UpdateWidget(name)
	assert(widgets[name], 'name argument must be a valid widget name.')
	widgets[name].update(self.widgets[name])
end
