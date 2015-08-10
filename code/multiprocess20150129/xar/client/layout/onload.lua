local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")

-----------------

function LoadIPCFile()
	local strIPCFilePath = __document.."\\..\\ipc.lua"
	XLLoadModule(strIPCFilePath)
end


function Main() 
	LoadIPCFile()	
end

Main()



