local application = "ShadowNet Library"
local baseUrl = "https://raw.githubusercontent.com/ShaneYu/mc-computercraft-programs/main/"


local dlTbl = {
  -- Core
  {
    link = baseUrl .. "shadownet/core/middleclass.lua",
    file = "/shadownet/core/middleclass.lua"
  },
  {
    link = baseUrl .. "shadownet/core/surface.lua",
    file = "/shadownet/core/surface.lua"
  },
  {
    link = baseUrl .. "shadownet/core/fonts.lua",
    file = "/shadownet/core/fonts.lua"
  },

  -- i18n
  {
    link = baseUrl .. "shadownet/core/i18n/init.lua",
    file = "/shadownet/core/i18n/init.lua"
  },
  {
    link = baseUrl .. "shadownet/core/i18n/interpolate.lua",
    file = "/shadownet/core/i18n/interpolate.lua"
  },
  {
    link = baseUrl .. "shadownet/core/i18n/plural.lua",
    file = "/shadownet/core/i18n/plural.lua"
  },
  {
    link = baseUrl .. "shadownet/core/i18n/variants.lua",
    file = "/shadownet/core/i18n/variants.lua"
  },
  {
    link = baseUrl .. "shadownet/core/i18n/version.lua",
    file = "/shadownet/core/i18n/version.lua"
  },

  -- mixins
  {
    link = baseUrl .. "shadownet/core/mixins/stateful.lua",
    file = "/shadownet/core/mixins/stateful.lua"
  },

  -- GUI
  {
    link = baseUrl .. "shadownet/gui/application.lua",
    file = "/shadownet/gui/application.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/button.lua",
    file = "/shadownet/gui/button.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/init.lua",
    file = "/shadownet/gui/init.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/label.lua",
    file = "/shadownet/gui/label.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/layout.lua",
    file = "/shadownet/gui/layout.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/object.lua",
    file = "/shadownet/gui/object.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/panel.lua",
    file = "/shadownet/gui/panel.lua"
  },
  {
    link = baseUrl .. "shadownet/gui/progressBar.lua",
    file = "/shadownet/gui/progressBar.lua"
  },

  -- root
  {
    link = baseUrl .. "shadownet.lua",
    file = "/shadownet.lua"
  },
  {
    link = baseUrl .. "programs/installer.lua",
    file = "/shadownet/installer.lua"
  }
}

-- internal

local function splitString(str, delimiter)
  local result = {}

  for match in (str..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end

  return result
end

local function writeFile(data, name)
  if fs.exists(name) then
    fs.delete(name)
  else
    local path = fs.getDir(name)

    if path then
      local pSeg = splitString(path, "/")
      local pCur = "/"

      for _, seg in pairs(pSeg) do
        pCur = fs.combine(pCur, seg)

        if not fs.exists(pCur) then
          fs.makeDir(pCur)
        end
      end
    end
  end

  local file = fs.open(name, "wb")

  if not file then
    return false
  end

  file.write(data)
  file.close()

  return true
end

term.clear()
term.setCursorPos(1, 1)

print("Downloading " .. application)

local termW, termH = term.getSize()
local termY = 1
term.setCursorPos(1, termY)

if termY + 5 >= termH then
  termY = termH - 5

  for _ = 1, 5 do
    print("")
  end
end

local step = 100 / #dlTbl
local percent = 0
local barMlen = (termW - 8)
local cstep = barMlen / 100

term.setCursorPos(1, termY + 2)
term.write(string.format("% 5.1f%% ", percent) .. string.rep("\127", barMlen))

for _, pk in pairs(dlTbl) do
  term.setCursorPos(1, termY + 3)
  term.clearLine()
  term.write(pk.file)

  local content = http.get(pk.link, nil, true).readAll()

  if not content or #content == 0 then
    error("Error while downloading " .. pk.link)
  end

  if not writeFile(content, pk.file) then
    term.setCursorPos(1, termY + 5)
    error("Error while writing " .. pk.file)

    return
  end

  percent = percent + step
  term.setCursorPos(1, termY + 2)

  local barLen = math.floor(percent * cstep + 0.5)
  term.write(string.format("%5.1f%% ", percent))
  
  local bgColor = term.getBackgroundColor()
  term.setBackgroundColor(colors.white)
  term.write(string.rep(" ", barLen))
  term.setBackgroundColor(bgColor)
  term.write(string.rep("\127", barMlen - barLen))
end

term.setCursorPos(1, termY + 5)

shell.run("shadownet install")
