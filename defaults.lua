local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

function A:SetupDefaults()

	self.defaults = {
		-- Global Data. All characters on the same account share this database.
		global = {
			core = {},

			guilds = {
				['*'] = {
					players = {
						['*'] = {
							name = '',
							alts = {},
							main = {},
							mainSpec = '',
							offSpec = '',
							rank = '',
							rankIndex = -1,
							level = -1,
							zone = '',
							note = '',
							officerNote = '',
							class = '',
						},
					},
				},
			},

			settings = {
				
			},
		},

		-- Character-specific data. Every character has its own database.
		char = {
			settings = {
				loadMessage = true,
			},
		},
	}

end
