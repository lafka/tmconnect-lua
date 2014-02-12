--- ex: expandtab tabstop=2

local M = {
  force = 1,
  timeout = 100,
  size = 120
}

local util = require("tmconnect.util")
local rs232 = require("luars232")

function M.open(module, opts)
  local e, port = rs232.open(opts.d)
  if e ~= rs232.RS232_ERR_NOERROR then
    return {status = "err", err = rs232.error_tostring(e)}
  end

  assert(port:set_baud_rate(rs232.RS232_BAUD_19200) == rs232.RS232_ERR_NOERROR)
  assert(port:set_data_bits(rs232.RS232_DATA_8) == rs232.RS232_ERR_NOERROR)
  assert(port:set_parity(rs232.RS232_PARITY_NONE) == rs232.RS232_ERR_NOERROR)
  assert(port:set_stop_bits(rs232.RS232_STOP_1) == rs232.RS232_ERR_NOERROR)
  assert(port:set_flow_control(rs232.RS232_FLOW_OFF) == rs232.RS232_ERR_NOERROR)

  module.port = port
end

function M.loop(module, fun)
  local concurrent = require("concurrent")
  while true do
    err, buf, size = module.port:read(module.size,
                        module.timeout,
                        module.forced)

    if size > 0 then
      fun(buf)
    end

    local msg = concurrent.receive(0.1)
    if msg and "data" == msg.ev then
       module.port:write(msg.data)
    end

    concurrent.sleep(100)
  end
end

function M.close(module)
  print("channel#uart: closing")
end

return M
