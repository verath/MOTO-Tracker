local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

MOTOTracker.defaults = {
	-- Global Data. All characters on the same account share this database.
	global = {
		core = {},

		guilds = {
			['*'] = {
				players = {
					['*'] = {
						isMain = true,
						alts = {},
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
