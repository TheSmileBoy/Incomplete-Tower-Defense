--!strict
export type NPCSendData = {
	Quantity: number,
	Attributes: {[string] :{}},
}

export type SendTableType = {
	NPCS: {[string]: NPCSendData},
	Base :string,
	DefenseUID :string,
	TickStart: number,
	TimeBetween :number,
}

export type NPCInfo = {
	Name :string, 
	
	Attributes :any,
	Index :number,
	Map :string,
	
	TickStart :number,
	DefenseUID :string,	
	
	Health :number?,
	DropCash :number?,
	Speed :number?,
	Damage :number?,
}

export type RenderNPC = {
	Path :number?, 
	
	Part :BasePart?,
	
	Height :number?, 
	TickSegment :number?,
	
	NPCIndex :number?,
	TickStart :number?,
	
	Attributes :any,
	
	Map :string,
	Model :Model?,
	
	Started :boolean?,
	CanMove :boolean?,
	
	NPCConfig :NPCInfo?,
	Died :boolean?,
	
	Health :number,
	MaxHealth :number,
	PreviewHealth :number,
	
	UID :string,
}

export type RenderData = {
	[string] :{ 
		[number] :RenderNPC
	}
}

return {}