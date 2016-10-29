local P, E, L = unpack(select(2, ...))

local atBank
local function UpdatePositions()
	for parentContainer, containers in next, P.GetAllContainers() do
		for categoryIndex, Container in next, containers do
			if(Container.buttons) then
				local index = 1
				for _, Button in next, Container.buttons do
					local shouldShow
					if(Button.overrideShouldShow) then
						shouldShow = Button:overrideShouldShow(atBank)
					else
						shouldShow = not (Button.hideOfflineBank and not atBank)
					end

					Button:SetShown(shouldShow)

					if(Button:IsShown()) then
						Button:ClearAllPoints()
						Button:SetPoint('TOPRIGHT', -8 - (20 * (index - 1)), -6)

						index = index + 1
					end
				end
			end
		end
	end
end

local function ShowTooltip(self)
	if(self.tooltipText) then
		GameTooltip:SetOwner(self, self.tooltipAnchor or 'ANCHOR_TOP')
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end
end

function P.CreateContainerButton(name, categoryIndex, forBank)
	local parentContainer = forBank and BackpackBank or Backpack
	local Parent = P.GetCategoryContainer(parentContainer, categoryIndex)

	local Button = CreateFrame('Button', '$parent' .. name, Parent)
	Button:SetSize(16, 16)
	Button:SetScript('OnEnter', ShowTooltip)
	Button:SetScript('OnLeave', GameTooltip_Hide)
	Button.hideOfflineBank = forBank

	local Texture = Button:CreateTexture('$parentTexture', 'ARTWORK')
	Texture:SetAllPoints()
	Texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]])
	Button.Texture = Texture

	P.Fire('PostCreateContainerButton', Button)

	Button.UpdateTooltip = ShowTooltip

	if(not Parent.buttons) then
		Parent.buttons = {}
	end

	table.insert(Parent.buttons, Button)
	UpdatePositions()

	return Button
end

BackpackBank:HookScript('OnShow', UpdatePositions)

function E:BANKFRAME_OPENED()
	atBank = true
	UpdatePositions()
end

function E:BANKFRAME_CLOSED()
	atBank = false
	UpdatePositions()
end

function E:REAGENTBANK_PURCHASED()
	UpdatePositions()
end
