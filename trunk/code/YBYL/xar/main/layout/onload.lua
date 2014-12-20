local mima = "fvSem9Rt6w000000"
local apiUtil = XLGetObject("API.Util")
local apiAsyn = XLGetObject("GS.AsynUtil")
--[[
local str = apiUtil:ReadFileToString("f:\\lazy.txt")
apiUtil:EncryptAESToFile("f:\\e_lazy.dat",str,mima);
--]]
---[[
local str = apiUtil:DecryptFileAES("f:\\e_lazy.dat",mima);
apiUtil:WriteStringToFile("f:\\d_lazy.txt",str)
--]]
XLMessageBox(11)



