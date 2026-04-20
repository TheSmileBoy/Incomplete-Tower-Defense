--!strict
export type NPCEntry = {
	Name: string,
	BaseQuantity: number,       -- initial amount of NPCs spawned
	QuantityGrowth: number,     -- increase in quantity per wave
	TimeBetween: number,        -- delay between each spawn
	Attributes: {[string]: any}, -- custom attributes applied to the NPC(Not avaliabe)
}

export type MapConfig = {
	Health :number,
	
	NPCs: {NPCEntry},
	WaveCount: number,           -- total number of waves
	TimeBetweenWaves: number,    -- delay between each wave
	BossEvery: number?,          -- spawns a boss every N waves (optional)
	BossNPCs: {NPCEntry}?,       -- NPC entries used for boss waves
}

return {}