-- Program: Installer
-- Version: 1

local width, height = term.getSize()
local cursor, offset = 1, 0
local baseUrl = "https://raw.githubusercontent.com/ShaneYu/mc-computercraft-programs/main/"
local programsList = {}

local function refreshProgramsList()
  programsList = textutils.unserialiseJSON(http.get(baseUrl ..'programs/programs.json').readAll())

  for index, programInfo in pairs(programsList) do
    if fs.exists(programInfo.fileTarget) then
      local fileContent = fs.open(programInfo.fileTarget, "r")
      fileContent.readLine()
      programsList[index].installedVersion = tonumber(string.sub(fileContent.readLine(), 12))
    end
  end
end

local function installProgram(index)
  local programInfo = programsList[index]

  if programInfo.installedVersion then
    if programInfo.version == programInfo.installedVersion then
      return -- latest version is installed already
    end

    fs.delete(programInfo.fileTarget)
  end

  local programSource = http.get(string.format("%sprograms/%s", baseUrl, programInfo.fileSource), nil, true).readAll()
  local programFile = fs.open(programInfo.fileTarget, "wb")

  programFile.write(programSource)
  programFile.close()

  refreshProgramsList()
end

local function getStartupProgramPath()
  if fs.exists("/startup.lua") then
    local file = fs.open("/startup.lua", "r")
    local startupFile = string.match(file.readLine() or "", "[^'\"]+\.lua")

    file.close()

    return startupFile
  end

  return nil
end

local function toggleStartupProgram(index)
  local programInfo = programsList[index]
  local command = ""

  if programInfo.fileTarget ~= getStartupProgramPath() then
    if not programInfo.installedVersion then
      installProgram(index)
    end

    command = string.format("shell.run('%s')", programInfo.fileTarget)
  end

  local file = fs.open("/startup.lua", "w")

  file.write(command)
  file.close()
end

local function uninstallProgram(index)
  local programInfo = programsList[index]

  if programInfo.installedVersion and fs.exists(programInfo.fileTarget) then
    if programInfo.fileTarget == getStartupProgramPath() then
      toggleStartupProgram(index)
    end

    fs.delete(programInfo.fileTarget)
  end

  refreshProgramsList()
end

local function updateAll()
  for index, programInfo in pairs(programsList) do
    if programInfo.installedVersion and programInfo.installedVersion < programInfo.version then
      installProgram(index)
    end
  end
end

local function updateOffset(lines)
  if cursor > offset + lines then
      offset = cursor - lines
  end
  if cursor <= offset then
      offset = cursor - 1
  end
end

local function displayListStandard()
  local startupProgramPath = getStartupProgramPath()

  term.clear()
  term.setCursorPos(3, 1)
  term.write("ShadowNet Installer")
  term.setCursorPos(2,3)
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  term.write('  Name                      Version   Installed ')
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  for line = 1, height - 4 do
    if (line == cursor - offset) then
      term.setCursorPos(1, line + 3)
      term.write('>')
    end
    
    if (line + offset <= table.getn(programsList)) then
      local programInfo = programsList[line + offset]
      
      if programInfo.fileTarget == startupProgramPath then
        term.setCursorPos(2, line + 3)
        term.write('*')
      end
      
      term.setCursorPos(4, line + 3)
      term.write(programInfo.name)
      term.setCursorPos(30, line + 3)
      term.write(string.format("%d", programInfo.version))
      
      if programInfo.installedVersion then
        term.setCursorPos(40, line + 3)
        term.write(string.format("%d", programInfo.installedVersion))
      end
    end
  end

  term.setCursorPos(4, height)
  term.blit('i', 'f', '0')
  term.write('nstall  ')
  term.blit('a', 'f', '0')
  term.write('utostart  ')
  term.blit('d', 'f', '0')
  term.write('elete  ')
  term.blit('u', 'f', '0')
  term.write('pdate all  ')
  term.blit('q', 'f', '0')
  term.write('uit')
end

function displayPocket()
  local startupProgramPath = getStartupProgramPath()

  term.clear()
  term.setCursorPos(3,1)
  term.write('ShadowNet Installer')
  term.setCursorPos(2,3)
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  term.write('                        ')
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  for line = 1, 8 do
    if line == cursor - offset then
      term.setCursorPos(1, line * 3 + 1)
      term.write('>')
    end

    if (line + offset <= table.getn(programsList)) then
      local programInfo = programsList[line + offset]

      if programInfo == startupProgramPath then
        term.setCursorPos(2, line * 3 + 1)
        term.write('*')
      end

      term.setCursorPos(3, line * 3 + 1)
      term.write(programInfo.name)
      term.setCursorPos(2, line * 3 + 2)
      term.setBackgroundColor(colors.white)
      term.setTextColor(colors.black)
      term.write('                        ')
      term.setCursorPos(3, line * 3 + 2)
      term.write(string.format("Version: %d ", programInfo.version))

      if programInfo.localVersion then 
        term.write(string.format("Local: %d", programInfo.localVersion))
      end

      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
    end
  end

  term.setCursorPos(1, 20)
  term.blit('i', 'f', '0')
  term.write('nstall ')
  term.blit('r', 'f', '0')
  term.write('emove ')
  term.blit('u', 'f', '0')
  term.write('pdate ')
  term.blit('q', 'f', '0')
  term.write('uit')
end

local function displayList()
  if pocket then
    updateOffset(8)
    displayListPocket()
  else
    updateOffset(height - 4)
    displayListStandard()
  end
end

function keyListener()
  while true do
    local event, key = os.pullEvent('key')

    if key == keys.up and cursor > 1 then
      cursor = cursor - 1
    end

    if key == keys.down and cursor < table.getn(programsList) then
      cursor = cursor + 1
    end

    if key == keys.i or key == keys.enter then
      installProgram(cursor)
    end

    if key == keys.u then
      updateAll()
    end

    if key == keys.d or key == keys.delete then
      uninstallProgram(cursor)
    end

    if key == keys.a then
      toggleStartupProgram(cursor)
    end

    if key == keys.q then
      term.clear()
      term.setCursorPos(1,1)
      sleep(0.05)

      return
    end

    displayList()
  end
end

refreshProgramsList()
displayList()

parallel.waitForAll(keyListener)
