json = require("json")

local VMUtils = {}
function VMUtils.createSnap(back, snap)
	return mUtils.exec("qemu-img create -f " .. VMUtils.getDiskInfo(back)["format"] .. " -b " .. back .. " " .. snap)
end

function VMUtils.boot(command)
	return mUtils.exec(command)
end

function VMUtils.commit(snap)
	return mUtils.exec("qemu-img commit " .. snap)
end

function VMUtils.isSnapExist(snap)
	return mUtils.fileExist(snap)
end

function VMUtils.getDiskInfo(path)
	return json.decode(mUtils.exec2("qemu-img info --output json " .. path))
end

return VMUtils
