--!strict
local CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local BASE = #CHARS
local Counter = 0

return function(): string
	Counter += 1
	local ID = Counter
	local Result = ""

	repeat
		local Index = (ID - 1) % BASE + 1
		Result = string.sub(CHARS, Index, Index) .. Result
		ID = math.floor((ID - 1) / BASE)
	until ID == 0

	return Result
end