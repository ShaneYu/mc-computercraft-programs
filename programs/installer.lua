-- Program: Installer
-- Version: 2

local baseUrl = "https://raw.githubusercontent.com/ShaneYu/mc-computercraft-programs/main/"
local programsList = {}
local selectedProgram = 1

local width, height = term.getSize()
local listWidth = width - 3
local listHeight = height - 5

local installerName = "ShadowNet Installer"
local installerVersion = 0

local nameHeading = "Name"
local versionHeading = "Version  "
local installedHeading = "Installed  "

if pocket or turtle then
  listHeight = listHeight - 1
  versionHeading = "V  "
  installedHeading = "I  "
end

local function refreshProgramsList()
  local response = http.get(baseUrl ..'programs/programs.json', { ["Cache-Control"] = "no-cache" })

  programsList = textutils.unserialiseJSON(response.readAll())
  response.close()

  for index, programInfo in pairs(programsList) do
    if fs.exists(programInfo.fileTarget) then
      local fileContent = fs.open(programInfo.fileTarget, "r")
      fileContent.readLine()
      programsList[index].installedVersion = tonumber(string.sub(fileContent.readLine(), 12))
      fileContent.close()
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

  local programSource = http.get(string.format("%sprograms/%s", baseUrl, programInfo.fileSource), { ["Cache-Control"] = "no-cache" }).readAll()
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

local function displayList()
  local startupProgramPath = getStartupProgramPath()

  for _, programInfo in pairs(programsList) do
    if programInfo.name == 'Installer' then
      installerVersion = programInfo.installedVersion or 1
    end
  end

  term.clear()

  term.setCursorPos(2, 1)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.write(installerName)
  term.setCursorPos(width - #tostring(installerVersion) - 1, 1)
  term.write("v" .. installerVersion)
  
  term.setCursorPos(2, 3)
  term.setTextColor(colors.black)
  term.setBackgroundColor(colors.white)
  term.write(" Name" .. string.rep(" ", listWidth - #versionHeading - #installedHeading - 4))
  term.write(versionHeading.. installedHeading)

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)

  local programOffset = 0

  if #programsList > listHeight then
    programOffset = math.max(selectedProgram - listHeight, 0)
  end

  for i = 1, math.min(listHeight, #programsList) do

    if (i == selectedProgram - programOffset) then
      term.setCursorPos(1, i + 3)
      term.write('>')
    end
    
    local programInfo = programsList[i + programOffset]
    
    if programInfo.fileTarget == startupProgramPath then
      term.setCursorPos(2, i + 3)
      term.write('*')
    end
    
    term.setCursorPos(3, i + 3)
    term.write(programInfo.name .. string.rep(" ", listWidth - #versionHeading - #installedHeading - #programInfo.name))
    term.write(string.format("%d", programInfo.version) .. string.rep(" ", #versionHeading - #tostring(programInfo.version)))
    
    if programInfo.installedVersion then
      term.write(string.format("%d", programInfo.installedVersion))
    end
  end

  if pocket or turtle then
    term.setCursorPos(2, height - 1)
  else
    term.setCursorPos(2, height)
  end

  term.blit('i', 'f', '0')
  term.write('nstall  ')

  if pocket then
    term.write("   ")
  end

  term.blit('a', 'f', '0')
  term.write('utostart  ')

  if pocket then
    term.setCursorPos(2, height)
  end

  term.blit('u', 'f', '0')
  term.write('pdate all  ')

  if turtle then
    term.setCursorPos(2, height)
  end
  
  if (programsList[selectedProgram].name ~= "Installer") then
    term.blit('d', 'f', '0')
    term.write('elete  ')

    if turtle then
      term.write(" ")
    end
  end

  term.blit('q', 'f', '0')
  term.write('uit')
end

function keyListener()
  while true do
    local event, key = os.pullEvent('key')

    if key == keys.up and selectedProgram > 1 then
      selectedProgram = selectedProgram - 1
    end

    if key == keys.down and selectedProgram < #programsList then
      selectedProgram = selectedProgram + 1
    end

    if key == keys.i or key == keys.enter then
      installProgram(selectedProgram)
    end

    if key == keys.u then
      updateAll()
    end

    if key == keys.d or key == keys.delete then
      if (programsList[selectedProgram].name ~= "Installer") then
        uninstallProgram(selectedProgram)
      end
    end

    if key == keys.a then
      toggleStartupProgram(selectedProgram)
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
