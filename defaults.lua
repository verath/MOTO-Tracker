local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

function A:SetupDefaults()

	A.defaults = {
		-- Global Data. All characters on the same account share this database.
		global = {
			core = {},

			guilds = {
				['*'] = {
					players = {
						['*'] = {
							alts = {},
							main = {},
							mainSpec = '',
							offSpec = '',
						},
					},
				},
			},
		},

		-- Character-specific data. Every character has its own database.
		char = {
			loadMessage = true,
		},
	}

end
