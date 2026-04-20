local RBXConnection = {}
RBXConnection._Storage = {}

local function GetTagTable(tag)
	if not RBXConnection._Storage[tag] then
		RBXConnection._Storage[tag] = {}
	end

	return RBXConnection._Storage[tag]
end

function RBXConnection.StoreConnection(tag, item)
	local tagTable = GetTagTable(tag)

	table.insert(tagTable, item)
end

function RBXConnection.DestroyConnectionByTag(tag)
	local tagTable = RBXConnection._Storage[tag]
	if not tagTable then return end

	for i, item in (tagTable) do
		if typeof(item) == "RBXScriptConnection" then
			if item.Connected then
				item:Disconnect()
			end

		elseif typeof(item) == "function" then
			-- opcional: executa cleanup
			pcall(item)

		elseif typeof(item) == "table" then
			-- suporta objetos com Destroy ou Disconnect
			if item.Destroy then
				pcall(function() item:Destroy() end)
			elseif item.Disconnect then
				pcall(function() item:Disconnect() end)
			end
		end
	end

	RBXConnection._Storage[tag] = nil
end

function RBXConnection.Remove(tag, itemToRemove)
	local tagTable = RBXConnection._Storage[tag]
	if not tagTable then return end

	for i = #tagTable, 1, -1 do
		if tagTable[i] == itemToRemove then
			table.remove(tagTable, i)
			break
		end
	end
end

function RBXConnection.DestroyAll()
	for tag in (RBXConnection._Storage) do
		RBXConnection.DestroyConnectionByTag(tag)
	end
end

return RBXConnection