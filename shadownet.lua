args = {...}

local commands = {
  { name = "install", description = "opens the ShadowNet installer program" }
}

local function padRight(text, desiredLength)
  return text .. string.rep(" ", desiredLength - #text)
end

local function showHelp()
  local nameMaxLen, descriptionMaxLen = 0, 0

  for _, commandInfo in pairs(commands) do
    nameMaxLen = math.max(nameMaxLen, #commandInfo.name)
    descriptionMaxLen = math.max(descriptionMaxLen, #commandInfo.description)
  end

  nameMaxLen = nameMaxLen + 10

  local writeLine = function(columns)
    term.write(string.rep(" ", 3))

    for i, col in pairs(columns) do
      term.write(padRight(col.text, col.width))

      if i < #columns then
        term.write(string.rep(" ", 3))
      end
    end
  end

  term.clear()

  term.setCursorPos(1, 1)
  term.write("ShadowNet Command Line")

  term.setCursorPos(1, 4)
  writeLine({ { text = "Command", width = nameMaxLen }, { text = "Description", width = descriptionMaxLen } })

  term.setCursorPos(1, 5)
  writeLine({ { text = string.rep("-", nameMaxLen), width = nameMaxLen }, { text = string.rep("-", descriptionMaxLen), width = descriptionMaxLen } })

  local y = 7

  for _, commandInfo in pairs(commands) do
    term.setCursorPos(1, y)
    writeLine({ { text = "shadownet " .. commandInfo.name, width = nameMaxLen }, { text = commandInfo.description, width = descriptionMaxLen } })

    y = y + 1
  end

  term.setCursorPos(1, y + 2)
end

if #args == 0 then
  showHelp()
else
  local command = args[1]:lower()

  if command == "install" then
    shell.run("/shadownet/installer.lua")
  else
    showHelp()
  end
end
