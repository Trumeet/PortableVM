local Utils = {}
function Utils.exec(command)
	if os.getenv("DEBUG") == "1" then
		print("(Debug) Execute " .. command .. " (Status only)")
	end
	return os.execute(command)
end
function Utils.exec2(command)
	if os.getenv("DEBUG") == "1" then
		print("(Debug) Execute " .. command .. " (With output)")
	end
        local handle = io.popen(command)
        local result = handle:read("*a")
        handle:close()
        return result
end

function Utils.fileExist(file)
	local f = io.open(file, "r")
   	if f ~= nil then io.close(f) return true else return false end
end

function Utils.isWindows() 
	return package.config:sub(1,1) == "\\"
end

function Utils.getSnapPath()
	if mUtils.isWindows() then 
        	return os.getenv("USERPROFILE") .. "\\vm.qcow2" 
	else 
        	return os.getenv("HOME") .. "/vm.qcow2" 
	end
end

return Utils
