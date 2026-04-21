return {
	Health = 2000, 
	
	WaveCount = 999,
	TimeBetweenWaves = 10,
	BossEvery = 5,

	NPCs = {
		{
			Name = "Noob 01",
			BaseQuantity = 1,
			QuantityGrowth = 10,  -- spawn rate is 1 + Wave*QuantityGrowth
			TimeBetween = 0.3, -- Time between npcc spawn
			Attributes = {},
		},
	},

	BossNPCs = {
		{
			Name = "Glitch Boss",
			BaseQuantity = 1,
			QuantityGrowth = 1,
			TimeBetween = 2,
			Attributes = {},
		},
	},
}