function ToggleBackpack()
	Backpack:Toggle()
end

function ToggleAllBags()
	Backpack:Toggle(true)
end

ToggleBag = private.noop
