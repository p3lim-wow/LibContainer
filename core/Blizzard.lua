local parentMixin = LibContainer.mixins.parent

--[[ LibContainer:DisableBlizzard(parentType)
Disables the stock UI for the given parent type (see [Parent:GetType()](Parent#parentgettype)).

* parentType - parent container type (string)
--]]
function LibContainer:DisableBlizzard(parentType)
	if(parentType == 'bags') then
		MainMenuBarBackpackButton:UnregisterEvent('INVENTORY_SEARCH_UPDATE')

		for containerIndex = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS + 1 do
			-- for some reason the indices are skewed
			_G['ContainerFrame' .. containerIndex]:UnregisterAllEvents()
		end

		-- TODO: disable bag slot buttons
	elseif(parentType == 'bank') then
		BankFrame:UnregisterAllEvents()
		ReagentBankFrame:UnregisterAllEvents()

		for containerIndex = NUM_BAG_SLOTS + 2, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 2 do
			-- for some reason the indices are skewed
			_G['ContainerFrame' .. containerIndex]:UnregisterAllEvents()
		end
	end
end

--[[ Parent:OverrideToggles()
Overrides the methods for toggling the visible state of the stock bags to instead toggle
the visibility of the Parent container.

This is optional, but highly recommended for typical usage.  
The layout could instead override the methods themselves and add custom bindings.
--]]
function parentMixin:OverrideToggles()
	assert(self:GetType() == 'bags', 'OverrideToggles can only be called on bags')

	OpenAllBags = function()
		self:Toggle(true)
	end

	CloseAllBags = function()
		self:Toggle(false)
	end

	ToggleBackpack = function()
		self:Toggle()
	end

	ToggleAllBags = ToggleBackpack
	ToggleBag = nop
end
