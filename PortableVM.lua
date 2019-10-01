--[[
--Portable VM by YuutaW <i@yuuta.moe>
--]]

mUtils = require("Utils")
mVM = require("VM")
mInput = require("InputUtils")

DISK_PATH = arg[1]
BOOT_CMD = arg[2]
SNAP_PATH = mUtils.getSnapPath()

if DISK_PATH == nil or BOOT_CMD == nil then
	io.stderr:write("Arguments are missing. Usage: PortableVM <QCOW2 disk absolute path> <VM boot command>\n")
	os.exit(1)
	return
end

print(BOOT_CMD)
BOOT_CMD = string.format(BOOT_CMD, SNAP_PATH)

if mUtils.fileExist(DISK_PATH) ~= true then
	io.stderr:write("Disk " .. DISK_PATH .. " is not exist\n")
	os.exit(1)
	return
end

print("Snap file: " .. SNAP_PATH)

SKIP_CREATE_SNAP = false

if mVM.isSnapExist(SNAP_PATH) then
	io.stderr:write("Snap file " .. SNAP_PATH .. " is exist.\n")
	local backing = mVM.getDiskInfo(SNAP_PATH)["full-backing-filename"]
	local valid = backing ~= nil and mUtils.fileExist(backing)
	if valid == true then
		print("The snap file is a valid snapshot, you may choose to commit it first, delete it, and create a new snapshot.")
		io.write("[C] Commit and delete it, [D] Discard the snapshot, [U] Use the snap file instead, [A] Abort (Default): ")
		local choice = mInput.readLine()
		if choice == "C" or choice == "c" then
			if mVM.commit(SNAP_PATH) == true then
				os.remove(SNAP_PATH)
			else
				io.stderr:write("Cannot commit the snap file, you may manually commit it.")
				os.exit(1)
			end
		elseif choice == "D" or choice == "d" then
			print("Warning: all contents of the snapshot will be deleted! This cannot be undone.")
			os.remove(SNAP_PATH)
        elseif choice == "U" or choice == "u" then
            SKIP_CREATE_SNAP = true
		else
			os.exit(1)
		end	
	else 
		print("The snap file is not a valid snapshot, or its backing file is missing so it cannot be commited at this time. You may manually commit or discard it.")
		io.write("[D] Discard the snapshot, [A] Abort (Default): ")
		local choice = mInput.readLine()
		if choice == "D" or choice == "d" then
			os.remove(SNAP_PATH)
		else
			os.exit(1)
		end
	end
end

if SKIP_CREATE_SNAP ~= true then
    print("Creating snap...")
    if mVM.createSnap(DISK_PATH, SNAP_PATH) ~= true then
	    io.stderr:write("Cannot create the snap disk.\n")
	    os.exit(2)
	    return
    end
end

print("Booting VM...")
if mVM.boot(BOOT_CMD) ~= true then 
	io.stderr:write("Cannot boot the VM. Would you like to delete the snapshot? (It will be likely empty)\n")
	io.write("[D] Delete (Default); [A] Abort: ")
	local choice = mInput.readLine()
	if choice ~= "A" and choice ~= "a" then
		os.remove(SNAP_PATH)
	end
	os.exit(3)
	return
end

print("VM process is end. Commiting to the original disk...")
local function askForCommit() 
	print("Would you like to commit the snapshot? The original disk will be changed. Make sure the last VM session exited correctly, otherwise your data may be broken.")
	io.write("[C] Commit and delete (Default), [D] Discard the last session's data, [A] Abort: ")
	local choice = mInput.readLine()
	if choice == "D" or choice == "d" then
		print("Warning: All data changes during the last VM session will be discarded. This operation cannot be undone.")
		os.remove(SNAP_PATH)
	elseif choice == "A" or choice == "a" then
		os.exit(0)
	else 
		if mVM.commit(SNAP_PATH) ~= true then
			io.stderr:write("Cannot commit to the disk.\n")
            mInput.readLine()
			os.exit(4)
		else
			os.remove(SNAP_PATH)
		end
	end
end
askForCommit()
os.exit(0)
