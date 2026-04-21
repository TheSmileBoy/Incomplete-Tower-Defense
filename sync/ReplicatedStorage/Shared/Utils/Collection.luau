local CollectionService = game:GetService("CollectionService")
return function(TagName :string, AddedFunc, RemovedFunc)
	for _, Object in CollectionService:GetTagged(TagName) do
		AddedFunc(Object)
	end

	CollectionService:GetInstanceAddedSignal(TagName):Connect(AddedFunc)
	
	if RemovedFunc then
		CollectionService:GetInstanceRemovedSignal(TagName):Connect(RemovedFunc)
	end
end