local Class = require("shadownet.core.middleclass")
local GuiObject = require("shadownet.gui.objects.object")

local GuiLabel = Class("GuiLabel", GuiObject)

function GuiLabel:initialize(config)
  config = config or {}
  config.text = config.text or "Label text"
  config.horizontalAlignment = config.horizontalAlignment or GuiLabel.ALIGNMENT_HORIZONTAL_LEFT
  config.verticalAlignment = config.verticalAlignment or GuiLabel.ALIGNMENT_VERTICAL_TOP

  GuiObject.initialize(self, config)
end

function GuiLabel:update(deltaTime)
  GuiObject.update(self, deltaTime)

  self.width, self.height = #self.text, 1
  self.x, self.y = GuiLabel:getAlignmentCoords(0, 0, self.parent:getWidth(), self.parent:getHeight(), self.horizontalAlignment, self.verticalAlignment, self:getWidth(), self:getHeight())
end

function GuiLabel:draw()
  GuiObject.draw(self)

  self.surface:drawString(self.text, 0, 0, self.bgColor, self.fgColor)
end

return GuiLabel
