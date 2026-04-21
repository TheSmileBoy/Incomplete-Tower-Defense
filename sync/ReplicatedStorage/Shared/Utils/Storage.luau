local Storage = {}

function Storage:Store(ID, Value)
	Storage[ID] = Value
end

function Storage:Get(ID) :any
	return Storage[ID]
end

return Storage
