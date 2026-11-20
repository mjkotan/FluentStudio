--!strict
-- Fluent Paragraph Element (Multi-line Thai-friendly info card)

local Creator = require(script.Parent.Parent.Core.Creator)
local BaseElement = require(script.Parent.BaseElement)
local Types = require(script.Parent.Parent.Types)

type ParagraphOptions = Types.ParagraphOptions

local Paragraph = {}

function Paragraph.new(
	parent: Instance,
	themeReg: Creator.ThemeRegistry,
	options: ParagraphOptions
)
	local card = BaseElement.CreateCard(parent, themeReg, {
		Id = options.Id,
		Title = options.Title,
		Description = options.Content,
		Visible = options.Visible,
		Saveable = false,
	}, 0)

	card.TextArea.Size = UDim2.new(1, 0, 0, 0)
	card.ControlHolder.Visible = false

	local handle = setmetatable({
		Type = "Paragraph",
		SetContent = function(self, content: string)
			self:SetDescription(content)
		end,
	}, { __index = card })

	return handle
end

return Paragraph
