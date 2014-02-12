--- ex: expandtab tabstop=2

local M = {}

--- from: lua-users.org/wiki/AlternativeGetOpt
function M.getopt(arg, options)
  local tab = {}
  for k, v in ipairs(arg) do
    if string.sub( v, 1, 2) == "--" then
      local x = string.find( v, "=", 1, true )
      if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
      else      tab[ string.sub( v, 3 ) ] = true
      end
    elseif string.sub( v, 1, 1 ) == "-" then
      local y = 2
      local l = string.len(v)
      local jopt
      while ( y <= l ) do
        jopt = string.sub( v, y, y )
        if string.find( options, jopt, 1, true ) then
          if y < l then
            tab[ jopt ] = string.sub( v, y+1 )
            y = l
          else
            tab[ jopt ] = arg[ k + 1 ]
          end
        else
          tab[ jopt ] = true
        end
        y = y + 1
      end
    end
  end
  return tab
end

function M.help(opts)
  if true == opts.h then
    print [[
    Tinymesh Connect - Lua help
    ---------------------------

    -h  show this help page
    -r  specify the remote host/ip address
    -p  the remote port to connect to
    -d  the serial port device
    ]]
    return 0
  end
end

function M.dump(value, depth, key)
  local linePrefix = ""
  local spaces = ""

  if key ~= nil then
    linePrefix = "["..key.."] = "
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      M.dump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or
      type(value)  == 'thread' or
      type(value)  == 'userdata' or
      value    == nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end

function M.hexdump(str,spacer)
  return (string.gsub(str,"(.)",
    function (c)
      return string.format("%02X%s",string.byte(c), spacer or "")
    end)
  )
end

return M
