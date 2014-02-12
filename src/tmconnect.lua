#!/usr/bin/env lua
--- ex: expandtab tabstop=2

require "luarocks.loader"
local util       = require "tmconnect.util"
local concurrent = require "concurrent"

local opts = util.getopt(arg, "rpd")

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

local function channel(chan, sendto, mod, opts)
  local state = mod:open(opts)
  if (state ~= nil and "err" == state.status) then
    concurrent.send("bus", {ev = "err", msg = state, from = concurrent.self()})
    return -1
  end

  concurrent.send("bus", {ev = "link", entity = chan, from = concurrent.self()})
  local msg = concurrent.receive()

  if "ack" == msg.ev then
    local res = mod:loop(function(data)
      print("data: " .. chan .. " -> " .. sendto .. " " .. util.hexdump(data))
      concurrent.send(sendto, {ev = "data", data = data, origin = chan})
    end)

    if (res and "err" == res.status) then
      concurrent.send("bus", {ev = "err", msg = res, from = concurrent.self()})
    end

    concurrent.send("bus", {ev = "unlink", entity = chan, from = concurrent.self()})
    mod:close()
  end
end


local bus = concurrent.spawn(function()
  local downstream = concurrent.spawn(function()
    channel("downstream", "upstream", require("tmconnect.tty"), opts)
  end)
  concurrent.register("downstream", downstream)

  local upstream = concurrent.spawn(function()
    channel("upstream", "downstream", require("tmconnect.socket"), opts)
  end)
  concurrent.register("upstream", upstream)

  while true do
    local msg = concurrent.receive()

    if "link" == msg.ev then
      print("link: " .. msg.entity .. "(pid#" .. msg.from .. "), initiated")
      concurrent.monitor(msg.entity)
      concurrent.send(msg.entity, {ev = "ack", from = concurrent.self()})

    elseif "unlink" == msg.ev then
      print("link: " .. (msg.entity or "unknown") .. "(pid#" .. msg.from .. "), closed")

    elseif "err" == msg.ev then
      print("error: " .. (msg.entity or "unknown") .. "(pid#" .. msg.from .. "): " .. msg.msg.err)

    elseif "DOWN" == msg.signal then
      print("process: pid#" .. msg.from .. " exited with reason " .. msg.reason)

    else
      util.dump(msg)
    end
  end
end)

concurrent.register("bus", bus)

concurrent.loop(p)
