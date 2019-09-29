local InputUtils = {}

function InputUtils.readLine() 
	return io.stdin:read("*l")
end

function InputUtils.readChar()
	return io.stdin:read(1)
end

return InputUtils
