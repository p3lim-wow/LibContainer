local widgets = {}
local containerMixin = LibContainer.mixins.container

--[[ LibContainer:RegisterWidget(name, enableFunc, disableFunc, updateFunc)
Registers a new widget with the given name.

* name        - name of the new widget (string)
* enableFunc  - function which is run when the widget is created (function)
* disableFunc - function which is run when the widget is disabled (function)
* updateFunc  - function which is run on event updates (function)
--]]
function LibContainer:RegisterWidget(name, enable, disable, update)
	assert(not widgets[name], 'Widget \'' .. name .. '\' already exists.')
	widgets[name] = {
		enable = enable,
		disable = disable,
		update = update
	}
end

--[[ Container:AddWidget(name)
Creates and returns a new object for the widget with the given name.

* name - name of the widget (string)
--]]
function containerMixin:AddWidget(name)
	assert(widgets[name], 'No widget named \'' .. name .. '\' exists.')

	local obj = CreateFrame('Button', nil, self)
	obj:SetScript('OnEvent', widgets[name].update)

	self.widgets[name] = obj
	self:EnableWidget(name)
	return obj
end

--[[ Container:EnableWidget(name)
Enables the widget by name.

* name - name of widget (string)
--]]
function containerMixin:EnableWidget(name)
	widgets[name].enable(self.widgets[name])
end

--[[ Container:DisableWidget(name)
Disables the widget by name.

* name - name of widget (string)
--]]
function containerMixin:DisableWidget(name)
	widgets[name].disable(self.widgets[name])
end
