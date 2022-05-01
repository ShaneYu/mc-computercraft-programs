local Class = require("shadownet.core.middleclass")
local GuiObject = require("shadownet.gui.objects.object")

local GuiLayout = Class("GuiLayout", GuiObject)

function math.round(num)
  if num >= 0 then
      return math.floor(num + 0.5)
  else
      return math.ceil(num - 0.5)
  end
end

local function createLayoutCell()
  return {
    horizontalAlignment = GuiLayout.ALIGNMENT_HORIZONTAL_CENTER,
    verticalAlignment = GuiLayout.ALIGNMENT_VERTICAL_CENTER,
    horizontalMargin = 0,
    verticalMargin = 0,
    direction = GuiLayout.DIRECTION_VERTICAL,
    spacing = 1
  }
end

local function calculatePercentageSize(changingExistent, array, index)
  if array[index].sizePolicy == GuiLayout.SIZE_POLICY_RELATIVE then
    local allPercents, beforeFromIndexPercents = 0, 0

    for i = 1, #array do
      if array[i].sizePolicy == GuiLayout.SIZE_POLICY_RELATIVE then
        allPercents = allPercents + array[i].size

        if i <= index then
          beforeFromIndexPercents = beforeFromIndexPercents + array[i].size
        end
      end
    end

    local modifier

    if changingExistent then
      if beforeFromIndexPercents > 1 then
        error("Layout summary percentage > 100% at index " .. index)
      end

      modifier = (1 - beforeFromIndexPercents) / (allPercents - beforeFromIndexPercents)
    else
      modifier = (1 - array[index].size) / (allPercents - array[index].size)
    end

    for i = changingExistent and index + 1 or 1, #array do
      if array[i].sizePolicy == GuiLayout.SIZE_POLICY_RELATIVE and i ~= index then
        array[i].size = modifier * array[i].size
      end
    end
  end
end

local function updateCalculatedSize(array, index, dependency)
  if array[index].sizePolicy == GuiLayout.SIZE_POLICY_RELATIVE then
    array[index].calculatedSize = array[index].size * dependency
  else
    array[index].calculatedSize = array[index].size
  end
end

local function getAbsoluteTotalSize(array)
  local absoluteTotalSize = 0

  for i = 1, #array do
    if array[i].sizePolicy == GuiLayout.SIZE_POLICY_ABSOLUTE then
      absoluteTotalSize = absoluteTotalSize + array[i].size
    end
  end

  return absoluteTotalSize
end

local function checkCell(self, column, row)
  if column < 1 or column > #self.columnSizes or row < 1 or row > #self.rowSizes then
    error("Specified grid position (" .. tostring(column) .. "x" .. tostring(row) .. ") is out of layout grid range")
  end
end

function GuiLayout:initialize(config)
  config = config or {}
  config.defaultRow = config.defaultRow or 1
  config.defaultColumn = config.defaultColumn or 1
  config.autoSizeToParent = config.autoSizeToParent or true

  GuiObject.initialize(self, config)

  self:setGridSize(self.rowCount, self.columnCount)
end

function GuiLayout:getWidth()
  return self.width or self.parent:getWidth()
end

function GuiLayout:getHeight()
  return self.height or self.parent:getHeight()
end

function GuiLayout:update(deltaTime)
  local columnPercentageTotalSize, rowPercentageTotalSize = self:getWidth() - getAbsoluteTotalSize(self.columnSizes), self:getHeight() - getAbsoluteTotalSize(self.rowSizes)

  for row = 1, #self.rowSizes do
    updateCalculatedSize(self.rowSizes, row, rowPercentageTotalSize)

    for column = 1, #self.columnSizes do
      updateCalculatedSize(self.columnSizes, column, columnPercentageTotalSize)
      self.cells[row][column].childrenWidth, self.cells[row][column].childrenHeight = 0, 0
    end
  end

  local child, layoutRow, layoutColumn, cell

  for i = 1, #self.children do
    child = self.children[i]

    if not child.hidden then
      layoutRow, layoutColumn = child.layoutRow, child.layoutColumn

      if layoutRow >= 1 and layoutRow <= #self.rowSizes and layoutColumn >= 1 and layoutColumn <= #self.columnSizes then
        cell = self.cells[layoutRow][layoutColumn]

        if cell.horizontalFitting then
          child.width = math.round(self.columnSizes[layoutColumn].calculatedSize - cell.horizontalFittingRemove)
        end

        if cell.verticalFitting then
          child.height = self.rowSizes[layoutRow].calculatedSize - cell.verticalFittingRemove
        end

        if cell.direction == GuiLayout.DIRECTION_HORIZONTAL then
          cell.childrenWidth = cell.childrenWidth + child:getWidth() + cell.spacing
          cell.childrenHeight = math.max(cell.childrenHeight, child:getHeight())
        else
          cell.childrenWidth = math.max(cell.childrenWidth, child:getWidth())
          cell.childrenHeight = cell.childrenHeight + child:getHeight() + cell.spacing
        end

      else
        error("Layout child with index " .. i .. " has been assigned to cell (" .. layoutColumn .. "x" .. layoutRow .. ") out of layout grid range")
      end
    end
  end

  local x, y = 0, 0

  for row = 1, #self.rowSizes do
    for column = 1, #self.columnSizes do
      cell = self.cells[row][column]

      cell.x, cell.y = GuiLayout:getAlignmentCoords(
        x,
        y,
        self.columnSizes[column].calculatedSize,
        self.rowSizes[row].calculatedSize,
        cell.horizontalAlignment,
        cell.verticalAlignment,
        cell.childrenWidth - (cell.direction == GuiLayout.DIRECTION_HORIZONTAL and cell.spacing or 0),
        cell.childrenHeight - (cell.direction == GuiLayout.DIRECTION_VERTICAL and cell.spacing or 0)
      )

      if cell.horizontalMargin ~= 0 or cell.verticalMargin ~= 0 then
        cell.x, cell.y = GuiLayout:getMarginCoords(
          cell.x,
          cell.y,
          cell.horizontalAlignment,
          cell.verticalAlignment,
          cell.horizontalMargin,
          cell.verticalMargin
        )
      end

      x = x + self.columnSizes[column].calculatedSize
    end

    x, y = 0, y + self.rowSizes[row].calculatedSize
  end

  for i = 1, #self.children do
    child = self.children[i]

    if not child.hidden then
      cell = self.cells[child.layoutRow][child.layoutColumn]

      child.x, child.y = GuiLayout:getAlignmentCoords(
        cell.x,
        cell.y,
        cell.childrenWidth,
        cell.childrenHeight,
        cell.horizontalAlignment,
        cell.verticalAlignment,
        child:getWidth(),
        child:getHeight()
      )

      if cell.direction == GuiLayout.DIRECTION_HORIZONTAL then
        child.x, child.y = math.floor(cell.x), child:getPositionY()
        cell.x = cell.x + child:getWidth() + cell.spacing
      else
        child.x, child.y = child:getPositionX(), math.floor(cell.y)
        cell.y = cell.y + child:getHeight() + cell.spacing
      end
    end
  end

  GuiObject.update(self, deltaTime)
end

function GuiLayout:addChild(childOrChildClass, configOrAtIndex, atIndex)
  local child = GuiObject.addChild(self, childOrChildClass, configOrAtIndex, atIndex)

  configOrAtIndex = configOrAtIndex or {}
  child.layoutRow = configOrAtIndex.layoutRow or self.defaultRow
  child.layoutColumn = configOrAtIndex.layoutColumn or self.defaultColumn

  return child
end

function GuiLayout:setGridSize(columnCount, rowCount)
  self.cells = {}
  self.rowSizes = {}
  self.columnSizes = {}

  local rowSize, columnSize = 1 / rowCount, 1 / columnCount

  for i = 1, rowCount do
    self:addRow(GuiLayout.SIZE_POLICY_RELATIVE, rowSize)
  end

  for i = 1, columnCount do
    self:addColumn(GuiLayout.SIZE_POLICY_RELATIVE, columnSize)
  end

  return self
end

function GuiLayout:addRow(sizePolicy, size)
  local row = {}

  for i = 1, #self.columnSizes do
    table.insert(row, createLayoutCell())
  end

  table.insert(self.cells, row)
  table.insert(self.rowSizes, {
    sizePolicy = sizePolicy,
    size = size
  })

  calculatePercentageSize(false, self.rowSizes, #self.rowSizes)

  return self
end

function GuiLayout:removeRow(row)
  table.remove(self.cells, row)

  self.rowSizes[row].size = 0
  calculatePercentageSize(false, self.rowSizes, row)

  table.remove(self.rowSizes, row)

  return self
end

function GuiLayout:addColumn(sizePolicy, size)
  for i = 1, #self.rowSizes do
    table.insert(self.cells[i], createLayoutCell())
  end

  table.insert(self.columnSizes, {
    sizePolicy = sizePolicy,
    size = size
  })

  return self
end

function GuiLayout:removeColumn(column)
  for i = 1, #self.rowSizes do
    table.remove(self.cells[i], column)
  end

  self.columnSizes[column].size = 0
  calculatePercentageSize(false, self.columnSizes, column)

  table.remove(self.columnSizes, column)

  return self
end

function GuiLayout:setPosition(column, row, child)
  checkCell(self, column, row)

  child.layoutRow = row
  child.layoutColumn = column

  return child
end

function GuiLayout:setDirection(column, row, direction)
  checkCell(self, column, row)

  self.cells[row][column].direction = direction

  return self
end

function GuiLayout:setSpacing(column, row, spacing)
  checkCell(self, column, row)

  self.cells[row][column].spacing = spacing

  return self
end

function GuiLayout:setAlignment(column, row, horizontalAlignment, verticalAlignment)
  checkCell(self, column, row)

  self.cells[row][column].horizontalAlignment = horizontalAlignment
  self.cells[row][column].verticalAlignment = verticalAlignment

  return self
end

function GuiLayout:setMargin(column, row, horizontalMargin, verticalMargin)
  checkCell(self, column, row)

  self.cells[row][column].horizontalMargin = horizontalMargin
  self.cells[row][column].verticalMargin = verticalMargin

  return self
end

function GuiLayout:getMargin(column, row)
  checkCell(self, column, row)

  return self.cells[row][column].horizontalMargin, self.cells[row][column].verticalMargin
end

function GuiLayout:setRowHeight(row, sizePolicy, size)
  self.rowSizes[row].sizePolicy = sizePolicy
  self.rowSizes[row].size = size

  calculatePercentageSize(true, self.rowSizes, row)

  return self
end

function GuiLayout:setColumnWidth(column, sizePolicy, size)
  self.columnSizes[column].sizePolicy = sizePolicy
  self.columnSizes[column].size = size

  calculatePercentageSize(true, self.columnSizes, column)

  return self
end

function GuiLayout:fitToChildrenSize(column, row)
  self.width, self.height = 0, 0

  if self.children then
    for i = 1, #self.children do
      if not self.children[i]:isHidden() then
        if self.cells[row][column].direction == GuiLayout.DIRECTION_HORIZONTAL then
          self.width = self.width + self.children[i]:getWidth() + self.cells[row][column].spacing
          self.height = math.max(self.height, self.children[i]:getHeight())
        else
          self.width = math.max(self.width, self.children[i]:getWidth())
          self.height = self.height + self.children[i]:getHeight() + self.cells[row][column].spacing
        end
      end
    end
  end

  if self.cells[row][column].direction == GuiLayout.DIRECTION_HORIZONTAL then
    self.width = self.width - self.cells[row][column].spacing
  else
    self.height = self.height - self.cells[row][column].spacing
  end

  return self
end

function GuiLayout:setFitting(column, row, horizontal, vertical, horizontalRemove, verticalRemove)
  checkCell(self, column, row)

  self.cells[row][column].horizontalFitting = horizontal
  self.cells[row][column].verticalFitting = vertical
  self.cells[row][column].horizontalFittingRemove = horizontalRemove or 0
  self.cells[row][column].verticalFittingRemove = verticalRemove or 0

  return self
end

return GuiLayout
