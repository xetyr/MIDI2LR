--[[----------------------------------------------------------------------------

Keys.lua
 
This file is part of MIDI2LR. Copyright 2015-2016 by Rory Jaffe.

MIDI2LR is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

MIDI2LR is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
MIDI2LR.  If not, see <http://www.gnu.org/licenses/>. 
------------------------------------------------------------------------------]]
local LrStringUtils = import 'LrStringUtils'
local LrView = import 'LrView'

local legalanswers = {}
local maxlength = 0
local completion = {  
  'backspace',
  'cursor down',
  'cursor left',
  'cursor right',
  'cursor up',
  'delete',
  'end',
  'escape',
  'f1',
  'f10',
  'f11',
  'f12',
  'f13',
  'f14',
  'f15',
  'f16',
  'f17',
  'f18',
  'f19',
  'f2',
  'f20',
  'f3',
  'f4',
  'f5',
  'f6',
  'f7',
  'f8',
  'f9',
  'home',
  'numpad 0',
  'numpad 1',
  'numpad 2',
  'numpad 3',
  'numpad 4',
  'numpad 5',
  'numpad 6',
  'numpad 7',
  'numpad 8',
  'numpad 9',
  'numpad add',
  'numpad decimal',
  'numpad divide',
  'numpad multiply',
  'numpad subtract',
  'page down',
  'page up',
  'return',
  'space',
  'tab',
  }
for _,k in ipairs(completion) do
  maxlength = math.max(k:len(),maxlength)
  legalanswers[k] = true
end

local control, alt
local shift = LOC("$$$/Win/MenuDisplay/KeyboardShortcutElement/Shift=Shift")
if(WIN_ENV) then
  control = LOC("$$$/AgBezels/KeyRemapping/WinControl=Control")
  alt = LOC("$$$/AgBezels/KeyRemapping/WinAlt=Alt")
else
  control = LOC("$$$/AgBezels/KeyRemapping/MacCommand=Command")
  alt = LOC("$$$/AgBezels/KeyRemapping/MacOption=Option")
end

local function validate(_,value)
  if value == nil then return true end
  value = LrStringUtils.trimWhitespace(value)
  local _, count = value:gsub( "[^\128-\193]", "") -- UTF-8 characters
  if count < 2 then return true,value end --one key or empty string
  value = LrStringUtils.lower(value)
  if legalanswers[value] then return true,value end
  return false, '', 'Value must be single character or spell out an F key (F1-F16) or: backspace (means delete in OS X), cursor down, cursor left, cursor right, cursor up, delete (means delete right in OS X), end, escape, home, page down, page up, return, space, tab, or numpad 0 (through numpad 9), numpad add (or decimal, divide, multiply, subtract).'
end



local function StartDialog(obstable,f)
  local internalview1 = {}
  for i = 1,20 do
    obstable['Keyscontrol'..i] = ProgramPreferences.Keys[i]['control']
    obstable['Keysalt'..i] = ProgramPreferences.Keys[i]['alt']
    obstable['Keysshift'..i] = ProgramPreferences.Keys[i]['shift']
    obstable['Keyskey'..i] = ProgramPreferences.Keys[i]['key']
    table.insert(internalview1,f:row{
        f:static_text{title = LOC("$$$/MIDI2LR/Keys/Shortcut=Keyboard shortcut")..' '..i,width = LrView.share('key_name')},
        f:checkbox{title = control, value = LrView.bind('Keyscontrol'..i)},
        f:checkbox{title = alt, value = LrView.bind('Keysalt'..i)},
        f:checkbox{title = shift, value = LrView.bind('Keysshift'..i)},
        f:edit_field{value = LrView.bind('Keyskey'..i), validate = validate, completion = completion, width_in_chars = maxlength} } )
  end
  local internalview2 = {}
  for i = 21,40 do
    obstable['Keyscontrol'..i] = ProgramPreferences.Keys[i]['control']
    obstable['Keysalt'..i] = ProgramPreferences.Keys[i]['alt']
    obstable['Keysshift'..i] = ProgramPreferences.Keys[i]['shift']
    obstable['Keyskey'..i] = ProgramPreferences.Keys[i]['key']
    table.insert(internalview2,f:row{
        f:static_text{title = LOC("$$$/MIDI2LR/Keys/Shortcut=Keyboard shortcut")..' '..i,width = LrView.share('key_name')},
        f:checkbox{title = control, value = LrView.bind('Keyscontrol'..i)},
        f:checkbox{title = alt, value = LrView.bind('Keysalt'..i)},
        f:checkbox{title = shift, value = LrView.bind('Keysshift'..i)},
        f:edit_field{value = LrView.bind('Keyskey'..i), validate = validate, completion = completion, width_in_chars = maxlength} } )
  end
  return f:row{ f:column (internalview1), f:column (internalview2) }
end

local function EndDialog(obstable, status)
  if status == 'ok' then
    ProgramPreferences.Keys = {} -- empty out prior settings
    for i = 1,40 do
      ProgramPreferences.Keys[i] = {}
      if obstable['Keyskey'..i] ~= nil and obstable['Keyskey'..i] ~= '' and validate(obstable['Keyskey'..i]) == true then
        ProgramPreferences.Keys[i]['control'] = obstable['Keyscontrol'..i]
        ProgramPreferences.Keys[i]['alt'] = obstable['Keysalt'..i]
        ProgramPreferences.Keys[i]['shift'] = obstable['Keysshift'..i]
        ProgramPreferences.Keys[i]['key'] = obstable['Keyskey'..i]
      else
        ProgramPreferences.Keys[i]['control'] = false
        ProgramPreferences.Keys[i]['alt'] = false
        ProgramPreferences.Keys[i]['shift'] = false
        ProgramPreferences.Keys[i]['key'] = ''
      end
    end
  end
end

local function GetKey(i)
  if i < 1 or i > 40 then return nil end
  local modifiers = 0x0
  if ProgramPreferences.Keys[i]['alt'] then
    modifiers = 0x1
  end
  if ProgramPreferences.Keys[i]['control'] then
    modifiers = modifiers + 0x2
  end
  if ProgramPreferences.Keys[i]['shift'] then
    modifiers = modifiers + 0x4
  end
  return string.format('%u',modifiers) .. ProgramPreferences.Keys[i]['key']
end


return { --table of exports, setting table member name and module function it points to
  EndDialog   = EndDialog,
  StartDialog = StartDialog,
  GetKey = GetKey,
}