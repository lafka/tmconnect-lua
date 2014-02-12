LUAROCKS ?= $(shell command -v luarocks-5.1 || command -v luarocks)
LUA ?= $(shell command -v lua5.1 || command -v lua)

all:
	$(LUAROCKS) make

run:
	$(LUAROCKS) make --local && $(LUA) src/tmconnect.lua -r 31.169.50.42 -p 7001 -d /dev/ttyUSB0
