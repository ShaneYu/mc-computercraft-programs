local Fonts = require("shadownet.gui.fonts")
local GuiApplication = require("shadownet.gui.objects.application")

local GUI = {}

function GUI.createApplication(opts)
  opts = opts or {}
  opts.surfaceDriver = dofile("/shadownet/gui/surface.lua")
  opts.fonts = Fonts:new()

  if not opts.renderTo then
    opts.renderTo = { term }
  elseif type(opts.renderTo) == "table" and opts.renderTo.blit then
    opts.renderTo = { opts.renderTo }
  end

  return GuiApplication:new(opts)
end

return GUI
