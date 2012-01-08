local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

function A:SetupDefaults()

	self.defaults = {
		-- Global Data. All characters on the same account share this database.
		global = {
			core = {
				GUI = {
					rosterInfo = {
						showAlts = true,
						showOnlyMaxLvl = false,
						hideOffline = false,
						sortByPrimary = 'rankIndex',
						sortBySecondary = 'name'
					},
				},
			},

			guilds = {
				['*'] = {
					chars = {
						['*'] = {
							name = '',
							alts = nil,
							main = nil,
							mainSpec = '',
							offSpec = '',
							rank = '',
							rankIndex = -1,
							level = -1,
							zone = '',
							note = '',
							officerNote = '',
							online = nil,
							status = '',
							class = '',
							guildIndex = -1
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
