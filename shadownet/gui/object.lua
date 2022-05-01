local Class = require("shadownet.core.middleclass")

local GuiObject = Class("GuiObject")

GuiObject.static.ALIGNMENT_HORIZONTAL_LEFT = 1
GuiObject.static.ALIGNMENT_HORIZONTAL_CENTER = 2
GuiObject.static.ALIGNMENT_HORIZONTAL_RIGHT = 3
GuiObject.static.ALIGNMENT_VERTICAL_TOP = 4
GuiObject.static.ALIGNMENT_VERTICAL_CENTER = 5
GuiObject.static.ALIGNMENT_VERTICAL_BOTTOM = 6

GuiObject.static.DIRECTION_HORIZONTAL = 7
GuiObject.static.DIRECTION_VERTICAL = 8

GuiObject.static.SIZE_POLICY_RELATIVE = 9
GuiObject.static.SIZE_POLICY_ABSOLUTE = 10

GuiObject.static.MOUSE_BUTTON_LEFT = 11
GuiObject.static.MOUSE_BUTTON_RIGHT = 12
GuiObject.static.MOUSE_BUTTON_MIDDLE = 13
GuiObject.static.TOUCH = 14

GuiObject.static.EVENT_MONITOR_TOUCHED = "monitorTouched"
GuiObject.static.EVENT_MOUSE_PRESSED = "mousePressed"
GuiObject.static.EVENT_MOUSE_RELEASED = "mouseReleased"
GuiObject.static.EVENT_MOUSE_DRAG = "mouseDrag"
GuiObject.static.EVENT_KEY_PRESSED = "keyPressed"
GuiObject.static.EVENT_KEY_RELEASED = "keyReleased"
GuiObject.static.EVENT_TEXT_INPUT = "textInput"
GuiObject.static.EVENT_PASTE = "paste"
GuiObject.static.EVENT_UPDATE = "update"
GuiObject.static.EVENT_DRAW = "draw"

local function removeChildAtIndex(self, childIndex)
  local child = self.children[childIndex]

  table.remove(self.children, childIndex)

  child.application = nil
  child.parent = nil
  child.surface = nil
  child.sendToBack = nil
  child.sendBackward = nil
  child.bringToFront = nil
  child.bringForward = nil
end

function GuiObject.static:getAlignmentCoords(x, y, parentWidth, parentHeight, hAlign, vAlign, objWidth, objHeight)
  if hAlign == GuiObject.ALIGNMENT_HORIZONTAL_CENTER then
    x = x + (parentWidth / 2) - (objWidth / 2)
  elseif hAlign == GuiObject.ALIGNMENT_HORIZONTAL_RIGHT then
    x = x + (parentWidth - objWidth)
  elseif hAlign ~= GuiObject.ALIGNMENT_HORIZONTAL_LEFT then
    error("Unknown horizontal alignment: " .. tostring(hAlign))
  end

  if vAlign == GuiObject.ALIGNMENT_VERTICAL_CENTER then
    y = y + (parentHeight / 2) - (objHeight / 2)
  elseif vAlign == GuiObject.ALIGNMENT_VERTICAL_BOTTOM then
    y = y + (parentHeight - objHeight)
  elseif vAlign ~= GuiObject.ALIGNMENT_VERTICAL_TOP then
    error("Unknown vertical alignment: " .. tostring(vAlign))
  end

  if x < 0 then
    x = 0
  end

  return x, y
end

function GuiObject.static:getMarginCoords(x, y, hAlign, vAlign, hMargin, vMargin)
  if hAlign == GuiObject.ALIGNMENT_HORIZONTAL_RIGHT then
    x = x - hMargin
  else
    x = x + hMargin
  end

  if vAlign == GuiObject.ALIGNMENT_VERTICAL_BOTTOM then
    y = y - vMargin
  else
    y = y + vMargin
  end

  return x, y
end

function GuiObject:initialize(config)
  if config and type(config) == "table" then
    for k, v in pairs(config) do
      self[k] = v
    end
  end

  self.name = self.name or self.class.name
  self.children = {}
end

-- Get local position (X), relative to parent if it has one
function GuiObject:getPositionX()
  return math.floor(self.x or 0)
end

-- Get local position (Y), relative to parent if it has one
function GuiObject:getPositionY()
  return math.floor(self.y or 0)
end

-- Get local position (X, Y), relative to parent if it has one
function GuiObject:getPosition()
  return self:getPositionX(), self:getPositionY()
end

-- Get size (width), defaults to parent's width when it has one and no defined width
function GuiObject:getWidth()
  if not self.width and self.parent then
    return self.parent:getWidth()
  end

  return math.floor(self.width or 0)
end

-- Get size (height), defaults to parent's height when it has one and no defined height
function GuiObject:getHeight()
  if not self.height and self.parent then
    return self.parent:getHeight()
  end

  return math.floor(self.height or 0)
end

-- Get size (width, height), defaults to parent's size when it has one and no defined size
function GuiObject:getSize()
  return self:getWidth(), self.getHeight()
end

-- Get absolute position (X), relative to the render target (terminal or monitor)
function GuiObject:getAbsolutePositionX()
  if self.parent then
    return self.parent:getAbsolutePositionX() + self:getPositionX()
  end

  return self:getPositionX()
end

-- Get absolute position (Y), relative to the render target (terminal or monitor)
function GuiObject:getAbsolutePositionY()
  if self.parent then
    return self.parent:getAbsolutePositionY() + self:getPositionY()
  end

  return self:getPositionY()
end

-- Get absolute position (X, Y), relative to the render target (terminal or monitor)
function GuiObject:getAbsolutePosition()
  return self:getAbsolutePositionX(), self:getAbsolutePositionY()
end

-- Get absolute size (width), relative to the render target (terminal or monitor)
-- This is the absolute position + it's width
function GuiObject:getAbsoluteWidth()
  return self:getAbsolutePositionX() + self:getWidth()
end

-- Get absolute size (height), relative to the render target (terminal or monitor)
-- This is the absolute position + it's height
function GuiObject:getAbsoluteHeight()
  return self:getAbsolutePositionY() + self:getHeight()
end

-- Get absolute size (width, height), relative to the render target (terminal or monitor)
-- This is the absolute position + it's width and height
function GuiObject:getAbsoluteSize()
  return self:getAbsoluteWidth(), self:getAbsoluteHeight()
end

-- Checks if the x, y position is within the bounds of this object (in absolute space)
function GuiObject:isWithinBounds(x, y)
  local minX, minY = self:getAbsolutePosition()
  local maxX, maxY = self:getAbsoluteSize()

  return x > minX and x <= maxX and y > minY and y <= maxY
end

-- Sets the parent for this object
-- Will remove itself from an existing parent if it already has one
function GuiObject:setParent(parent, withChildIndex)
  if not parent or not parent.isContainer then
    error("Parent provided is not a container object")
  end

  if self.parent and self.parent ~= parent then
    self.parent:removeChild(self)
  end

  return parent:addChild(self, withChildIndex)
end

function GuiObject:dispatchEvent(eventName, ...)
  if not self.eventHandlers or not self.eventHandlers[eventName] then
    return
  end

  for i = 1, #self.eventHandlers[eventName] do
    self.eventHandlers[eventName][i](self, ...)
  end

  return self
end

function GuiObject:addEventHandler(eventName, eventHandlerFn)
  self.eventHandlers = self.eventHandlers or {}
  self.eventHandlers[eventName] = self.eventHandlers[eventName] or {}
  table.insert(self.eventHandlers[eventName], eventHandlerFn)

  return self
end

function GuiObject:update(deltaTime)
  if #self.children then
    for i = 1, #self.children do
      self.children[i]:update(deltaTime)
    end
  end

  self:dispatchEvent(GuiObject.EVENT_UPDATE, deltaTime)
end

function GuiObject:draw()
  if #self.children then
    for i = 1, #self.children do
      if not self.children[i]:isHidden() then
        self.surface:push(self.children[i]:getPositionX(), self.children[i]:getPositionY(), self.children[i]:getWidth(), self.children[i]:getHeight())
        self.children[i]:draw()
        self.surface:pop()
      end
    end
  end

  self:dispatchEvent(GuiObject.EVENT_DRAW)
end

function GuiObject:isHidden()
  return self.hidden or false
end

function GuiObject:addChild(childOrChildClass, configOrAtIndex, atIndex)
  -- If a Class is passed in, create child and then call add child with it
  if childOrChildClass.new and childOrChildClass.subclass then
    return self:addChild(childOrChildClass:new(configOrAtIndex), atIndex)
  end

  -- If we get to here then child is a child and not a Class
  local child = childOrChildClass

  if child.parent then
    error("Child already belongs to another container object")
  end

  child.parent = self
  child.surface = self.surface
  child.application = self.application

  child.sendToBack = function()
    self:moveChildToBack(child)

    return child
  end

  child.sendBackward = function()
    self:moveChildBackward(child)

    return child
  end

  child.bringToFront = function()
    self:moveChildToFront(child)

    return child
  end

  child.bringForward = function()
    self:moveChildForward(child)

    return child
  end

  if configOrAtIndex then
    table.insert(self.children, configOrAtIndex, child)
  else
    table.insert(self.children, child)
  end

  return child
end

function GuiObject:getChildIndex(child)
  if not child.parent then
    error("Child does not have a parent/container")
  end

  if child.parent ~= self then
    error("Child does not belong to this parent/container")
  end

  for k, v in pairs(self.children) do
    if v == child then
      return k
    end
  end

  error("Unable to determine the child index")
end

function GuiObject:removeChild(child)
  removeChildAtIndex(self, self:getChildIndex(child))

  return self
end

function GuiObject:removeChildren(fromIndex, toIndex)
  fromIndex = fromIndex or 1

  for childIndex = fromIndex, toIndex or #self.children do
    removeChildAtIndex(self, fromIndex)
  end

  return self
end

function GuiObject:moveChildToBack(child)
  table.remove(self.children, self:getChildIndex(child))
  table.insert(self.children, 1, child)

  return self
end

function GuiObject:moveChildBackward(child)
  local index = self:getChildIndex(child)

  if index > 1 then
    self.children[index], self.children[index - 1] = self.children[index - 1], self.children[index]
  end

  return self
end

function GuiObject:moveChildToFront(child)
  table.remove(self.children, self:getChildIndex(child))
  table.insert(self.children, child)

  return self
end

function GuiObject:moveChildForward(child)
  local index = self:getChildIndex(child)

  if index < #self.children then
    self.children[index], self.children[index + 1] = self.children[index + 1], self.children[index]
  end

  return self
end

function GuiObject:handleMonitorTouched(x, y, withinBounds)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleMonitorTouched(x, y, self.children[i]:isWithinBounds(x, y))
    end
  end
end

function GuiObject:handleMousePressed(x, y, button, withinBounds)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleMousePressed(x, y, self.children[i]:isWithinBounds(x, y))
    end
  end
end

function GuiObject:handleMouseReleased(x, y, button, withinBounds)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleMouseReleased(x, y, self.children[i]:isWithinBounds(x, y))
    end
  end
end

function GuiObject:handleMouseDrag(x, y, withinBounds)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleMouseDrag(x, y, self.children[i]:isWithinBounds(x, y))
    end
  end
end

function GuiObject:handleKeyPressed(keycode, key)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleKeyPressed(keycode, key)
    end
  end
end

function GuiObject:handleKeyReleased(keycode, key)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleKeyReleased(keycode, key)
    end
  end
end

function GuiObject:handleTextInput(text)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handleTextInput(text)
    end
  end
end

function GuiObject:handlePaste(text)
  if self.children then
    for i = 1, #self.children do
      self.children[i]:handlePaste(text)
    end
  end
end

function GuiObject:onMonitorTouched(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_MONITOR_TOUCHED, eventHandlerFn)
end

function GuiObject:onMousePressed(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_MOUSE_PRESSED, eventHandlerFn)
end

function GuiObject:onMouseReleased(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_MOUSE_RELEASED, eventHandlerFn)
end

function GuiObject:onMouseDrag(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_MOUSE_DRAG, eventHandlerFn)
end

function GuiObject:onKeyPressed(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_KEY_PRESSED, eventHandlerFn)
end

function GuiObject:onKeyReleased(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_KEY_RELEASED, eventHandlerFn)
end

function GuiObject:onTextInput(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_TEXT_INPUT, eventHandlerFn)
end

function GuiObject:onPaste(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_PASTE, eventHandlerFn)
end

function GuiObject:onUpdate(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_UPDATE, eventHandlerFn)
end

function GuiObject:onDraw(eventHandlerFn)
  self:addEventHandler(GuiObject.EVENT_DRAW, eventHandlerFn)
end

return GuiObject
