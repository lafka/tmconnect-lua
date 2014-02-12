--- ex: expandtab tabstop=2

local M = {}

local util = require("tmconnect.util")
local concurrent = require("concurrent")
local socket = require("socket")
local tcp = assert(socket.tcp())

function M.open(module, opts)
  local sock, err = assert(socket.connect(opts.r, opts.p))

  if nil == sock then
    return {status = "err", err = err}
  end

  module.sock = sock
end

function M.loop(module, fun)
  while true do
    module.sock:settimeout(0)
    local s, status, partial = module.sock:receive(120)
    local buf = s or partial

    if "closed" == status then
      return {status = "err", err = "closed"}
    end

    if string.len(buf) > 0 then
      fun(buf)
    end

    local msg = concurrent.receive(0.1)
    if msg and "data" == msg.ev then
       module.sock:send(msg.data)
    end

    concurrent.sleep(100)
  end
end

function M.close(module, linda)
  tcp:close()
  print("channel#socket: closing")
end

return M
