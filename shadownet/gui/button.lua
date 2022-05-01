local Class = require("shadownet.core.middleclass")
local GuiObject = require("shadownet.gui.objects.object")

local GuiButton = Class("GuiButton", GuiObject)

GuiButton.static.STYLE_SOLID = 1
GuiButton.static.STYLE_BORDERED = 2
GuiButton.static.EVENT_CLICK = "click"

local function handlePressed(self, button)
  if button == GuiButton.TOUCH or button == GuiButton.MOUSE_BUTTON_LEFT then
    self.isPressed = true
  end

  if button == GuiButton.TOUCH then
    self.pressedStart = os.clock()
  end
end

local function handleReleased(self, button)
  if button == GuiButton.TOUCH or button == GuiButton.MOUSE_BUTTON_LEFT then
    self.isPressed = false
    self.pressedStart = nil

    self:dispatchEvent(GuiButton.EVENT_CLICK)
  end
end

local function drawFrame(surface, x, y, width, height, color)
  local stringUp, stringDown, x2 = "┌" .. string.rep("─", width - 2) .. "┐", "└" .. string.rep("─", width - 2) .. "┘", x + width - 1

  surface:drawString(stringUp, x, y, nil, color); y = y + 1

  for i = 1, height - 2 do
    surface:drawString("│", x, y, nil, color)
    surface:drawString("│", x2, y, nil, color)
    y = y + 1
  end

  surface:drawString(stringDown, x, y, nil, color)
end

function GuiButton:initialize(config)
  config = config or {}
  config.text = config.text or "Button text"
  config.style = config.style or GuiButton.STYLE_SOLID
  config.bgColor = config.bgColor or colors.lightGray
  config.bgColorPressed = config.bgColorPressed or colors.white
  config.fgColor = config.fgColor or colors.gray
  config.fgColorPressed = config.fgColorPressed or colors.lightGray

  GuiObject.initialize(self, config)
end

function GuiButton:update(deltaTime)
  GuiObject.update(self, deltaTime)

  if self.isPressed and self.pressedStart ~= nil then
    local secondsSincePressedStart = os.clock() - self.pressedStart

    if secondsSincePressedStart >= 0.2 then
      handleReleased(self, GuiButton.TOUCH)
    end
  end

  self.xText, self.yText = GuiButton:getAlignmentCoords(0, 0, self:getWidth(), self:getHeight(), GuiButton.ALIGNMENT_HORIZONTAL_CENTER, GuiButton.ALIGNMENT_VERTICAL_CENTER, #self.text, 1)
end

function GuiButton:draw()
  if self.style == GuiButton.STYLE_SOLID then
    self.surface:clear(self.isPressed and self.bgColorPressed or self.bgColor)
  end

  if self.style == GuiButton.STYLE_BORDERED then
    drawFrame(self.surface, 0, 0, self:getWidth(), self:getHeight(), self.bgColor)
  end

  GuiObject.draw(self)

  self.surface:drawString(self.text, self.xText, self.yText, nil, self.isPressed and self.fgColorPressed or self.fgColor)
end

function GuiButton:handleMonitorTouched(x, y, withinBounds)
  if withinBounds then
    handlePressed(self, GuiButton.TOUCH)
  end

  GuiObject.handleMonitorTouched(self, x, y)
end

function GuiButton:handleMousePressed(x, y, button, withinBounds)
  if withinBounds then
    handlePressed(self, button)
  end

  GuiObject.handleMousePressed(self, x, y, button)
end

function GuiButton:handleMouseReleased(x, y, button, withinBounds)
  handleReleased(self, button)

  GuiObject.handleMouseReleased(self, x, y, button)
end

function GuiButton:setBackgroundColor(color)
  self.bgColor = color

  return self
end

function GuiButton:setBackgroundColorPressed(color)
  self.bgColorPressed = color

  return self
end

function GuiButton:setForegroundColor(color)
  self.fgColor = color

  return self
end

function GuiButton:setForegroundColorPressed(color)
  self.fgColorPressed = color

  return self
end

function GuiButton:setStyle(style)
  self.style = style

  return self
end

function GuiButton:onClick(eventHandlerFn)
  return self:addEventHandler(GuiButton.EVENT_CLICK, eventHandlerFn)
end

return GuiButton
