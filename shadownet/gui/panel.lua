local Class = require("shadownet.core.middleclass")
local GuiObject = require("shadownet.gui.objects.object")

local GuiPanel = Class("GuiPanel", GuiObject)

function GuiPanel:initialize(config)
  config = config or {}
  config.bgColor = config.bgColor or colors.lightGray
  config.fgColor = config.fgColor or colors.black

  GuiObject.initialize(self, config)
end

function GuiPanel:draw()
  self.surface:clear(self.bgColor, self.fgColor, " ")

  GuiObject.draw(self)
end

return GuiPanel
