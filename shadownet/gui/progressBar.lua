local Class = require("shadownet.core.middleclass")
local GuiObject = require("shadownet.gui.objects.object")

local GuiProgressBar = Class("GuiProgressBar", GuiObject)

local function padLeft(text, requiredLength, char)
  return string.rep(char or " ", requiredLength - #text) .. text
end

function GuiProgressBar:initialize(config)
  config = config or {}
  
  config.height = config.height or 3
  config.bgColor = config.bgColor or colors.lightGray
  config.fillColorLow = config.fillColorLow or colors.red
  config.fillColorMid = config.fillColorMid or colors.orange
  config.fillColorHigh = config.fillColorHigh or colors.green
  config.fgColor = config.fgColor or colors.white
  config.lowPercentage = config.lowPercentage or 25
  config.highPercentage = config.highPercentage or 75
  config.showPercentage = config.showPercentage or true
  config.value = config.value or 0
  config.maxValue = config.maxValue or 100

  GuiObject.initialize(self, config)
end

function GuiProgressBar:update(deltaTime)
  self.valuePercentage = (self.value / self.maxValue) * 100

  GuiObject.update(self, deltaTime)
end

function GuiProgressBar:draw()
  self.surface:clear(self.bgColor)

  local fillWidth = math.floor(math.min(self.value, self.maxValue) / self.maxValue * self:getWidth())
  self.surface:push(0, 0, fillWidth, self:getHeight())

  if self.valuePercentage <= self.lowPercentage then
    self.surface:clear(self.fillColorLow)
  elseif self.valuePercentage >= self.highPercentage then
    self.surface:clear(self.fillColorHigh)
  else
    self.surface:clear(self.fillColorMid)
  end

  self.surface:pop()

  GuiObject.draw(self)

  if self.showPercentage then
    self.text = padLeft(tostring(math.floor(self.valuePercentage)), 3) .. " %"
    --self.xText, self.yText = GuiProgressBar:getAlignmentCoords(0, 0, math.max(fillWidth, #self.text + 2), self:getHeight(), GuiProgressBar.ALIGNMENT_HORIZONTAL_RIGHT, GuiProgressBar.ALIGNMENT_VERTICAL_CENTER, #self.text + 2, 1)
    self.xText, self.yText = GuiProgressBar:getAlignmentCoords(0, 0, self:getWidth(), self:getHeight(), GuiProgressBar.ALIGNMENT_HORIZONTAL_CENTER, GuiProgressBar.ALIGNMENT_VERTICAL_CENTER, #self.text + 2, 1)
    self.surface:drawString(self.text, math.floor(self.xText), math.floor(self.yText), nil, self.fgColor)
  end
end

function GuiProgressBar:setMaxValue(maxValue)
  self.maxValue = maxValue

  return self
end

function GuiProgressBar:setValue(value)
  self.value = value

  return self
end

return GuiProgressBar
