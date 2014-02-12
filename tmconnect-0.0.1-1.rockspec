package = "TMConnect"
version = "0.0.1-1"
source = {
	url = "https://github.com/tinymesh/tm-connect-lua"
}
description = {
	summary = "Connect RS232 <> TCP",
	detailed = "",
	license = "BSD"
}
dependencies = {
	"lua ~> 5.1",
	"luars232 ~> 1.0",
	"luasocket ~> 2.0.2",
	"concurrentlua ~> 1.0",
}
build = {
	type = "builtin",
	modules = {
		tmconnect = "src/tmconnect.lua",
		["tmconnect.util"] = "src/tmconnect/util.lua",
		["tmconnect.tty"] = "src/tmconnect/tty.lua",
		["tmconnect.socket"] = "src/tmconnect/socket.lua"
	}
}
