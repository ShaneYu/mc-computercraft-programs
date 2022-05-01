local Class = require("shadownet.core.middleclass")
local GuiPanel = require("shadownet.gui.objects.panel")

local function getMinRenderTargetSize(renderTargets)
  local minWidth, minHeight = 99999999, 99999999

  for i = 1, #renderTargets do
    local width, height = renderTargets[i].getSize()

    minWidth = math.min(minWidth, width)
    minHeight = math.min(minHeight, height)
  end

  return minWidth, minHeight
end

local function calculateDeltaTime(self)
  if not self.lastClock then
    self.lastClock = os.clock()

    return 0
  end

  local newClock = os.clock()
  local deltaTime = newClock - self.lastClock

  self.lastClock = newClock

  return deltaTime
end

local handleUpdateTimer = function(self)
  local deltaTime = calculateDeltaTime(self)

  self:update(deltaTime)
  self.updateTimer = os.startTimer(self.updateSpeed)
  self:draw()
end

local GuiApplication = Class("GuiApplication", GuiPanel)

function GuiApplication:initialize(config)
  config = config or {}
  config.application = self
  config.updateSpeed = config.updateSpeed or 0.1
  config.useRawEvents = config.useRawEvents or false
  config.textScale = config.textScale or 0.5
  config.bgColor = config.bgColor or colors.blue
  config.fgColor = config.fgColor or colors.white

  GuiPanel.initialize(self, config)

  self:setTextScale(self.textScale)
end

function GuiApplication:setTextScale(scale)
  for i = 1, #self.renderTo do
    if self.renderTo[i].setTextScale then 
      self.renderTo[i].setTextScale(scale)
    end
  end

  self.width, self.height = getMinRenderTargetSize(self.renderTo)
  self.surface = self.surfaceDriver.create(self.width, self.height, self.bgColor, self.fgColor, " ")
end

function GuiApplication:draw()
  GuiPanel.draw(self)

  for i = 1, #self.renderTo do
    self.surface:output(self.renderTo[i])
  end
end

function GuiApplication:isHidden()
  return false
end

function GuiApplication:consumeEvent()
  self.shouldConsumeEvent = true
end

function GuiApplication:handleMonitorTouched(x, y)
  GuiPanel.handleMonitorTouched(self, x, y)
end

function GuiApplication:handleMousePressed(x, y, button)
  self.mouseButtonStates = self.mouseButtonStates or {}

  if button then
    self.mouseButtonStates[button] = true
  end

  GuiPanel.handleMousePressed(self, x, y, button)
end

function GuiApplication:handleMouseReleased(x, y, button)
  self.mouseButtonStates = self.mouseButtonStates or {}

  if button then
    self.mouseButtonStates[button] = false
  end

  GuiPanel.handleMouseReleased(self, x, y, button)
end

function GuiApplication:handleMouseDrag(x, y)
  GuiPanel.handleMouseDrag(self, x, y)
end

function GuiApplication:handleKeyPressed(keycode, key)
  self.keyStates = self.keyStates or {}

  if key then
    self.keyStates[key] = true
  end

  if keycode then
    self.keyStates[keycode] = true
  end

  GuiPanel.handleKeyPressed(self, keycode, key)
end

function GuiApplication:handleKeyReleased(keycode, key)
  self.keyStates = self.keyStates or {}

  if key then
    self.keyStates[key] = nil
  end

  if keycode then
    self.keyStates[keycode] = nil
  end

  GuiPanel.handleKeyReleased(self, keycode, key)
end

function GuiApplication:handleTextInput(text)
  GuiPanel.handleTextInput(self, text)
end

function GuiApplication:handlePaste(text)
  GuiPanel.handlePaste(self, text)
end

function GuiApplication:isKeyDown(keyOrKeycode)
  if not self.keyStates then
    return false
  end

  if not keyOrKeycode then
    return #self.keyStates > 0
  end

  return self.keyStates[keyOrKeycode]
end

function GuiApplication:isMouseButtonDown(button)
  return self.mouseButtonStates and self.mouseButtonStates[button]
end

function GuiApplication:start()
  if self.isRunning then
    return
  end

  self.isRunning = true
  self.updateTimer = os.startTimer(self.updateSpeed)
  
  for i = 1, #self.renderTo do
    self.renderTo[i].clear()
    self.renderTo[i].setCursorPos(1, 1)
  end

  self.surface:clear(self.bgColor, self.fgColor, " ")

  while self.isRunning do
    local eventName, a, b, c, d, e

    if self.useRawEvents then
      eventName, a, b, c, d, e = os.pullEventRaw()
    else
      eventName, a, b, c, d, e = os.pullEvent()
    end

    if eventName == "timer" and a == self.updateTimer then
      pcall(handleUpdateTimer, self)
    else
      if eventName == "char" then
        self:handleTextInput(a)
        self:dispatchEvent(GuiApplication.EVENT_TEXT_INPUT, a)
      elseif eventName == "key" then
        self:handleKeyPressed(a, keys.getName(a))
        self:dispatchEvent(GuiApplication.EVENT_KEY_PRESSED, a, keys.getName(a))
      elseif eventName == "key_up" then
        self:handleKeyReleased(a, keys.getName(a))
        self:dispatchEvent(GuiApplication.EVENT_KEY_RELEASED, a, keys.getName(a))
      elseif eventName == "mouse_click" then
        self:handleMousePressed(b, c, a)
        self:dispatchEvent(GuiApplication.EVENT_MOUSE_PRESSED, b, c, a)
      elseif eventName == "mouse_up" then
        self:handleMouseReleased(b, c, a)
        self:dispatchEvent(GuiApplication.EVENT_MOUSE_RELEASED, b, c, a)
      elseif eventName == "monitor_touch" then
        self:handleMonitorTouched(b, c)
        self:dispatchEvent(GuiApplication.EVENT_MONITOR_TOUCHED, b, c)
      elseif eventName == "mouse_drag" then
        self:handleMouseDrag(b, c)
        self:dispatchEvent(GuiApplication.EVENT_MOUSE_DRAG, b, c)
      elseif eventName == "paste" then
        self:handlePaste(a)
        self:dispatchEvent(GuiApplication.EVENT_PASTE, a)
      else
        self:dispatchEvent(eventName, a, b, c, d, e)
      end
    end

    self.shouldConsumeEvent = false
  end
end

function GuiApplication:stop()
  if not self.isRunning then
    return
  end

  self.isRunning = false

  for i = 1, #self.renderTo do
    for j = 1, 10 do
      self.renderTo[i].setBackgroundColour(colours.black)
      self.renderTo[i].setTextColour(colours.white)
      self.renderTo[i].clear()
      self.renderTo[i].setCursorPos(1, 1)
    end
  end
end

return GuiApplication
