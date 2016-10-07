local P = unpack(select(2, ...))

function ToggleBackpack()
	Backpack:Toggle()
end

function ToggleAllBags()
	Backpack:Toggle()
end

function OpenAllBags()
	Backpack:Toggle(true)
end

function CloseAllBags()
	Backpack:Toggle(false)
end

ToggleBag = P.noop

do
	MainMenuBarBackpackButton:UnregisterAllEvents()

	for index = 0, 3 do
		local Frame = _G['CharacterBag' .. index .. 'Slot']
		Frame:UnregisterAllEvents()
	end
end
