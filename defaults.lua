local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

function A:SetupDefaults()

	self.defaults = {
		-- Global Data. All characters on the same account share this database.
		global = {
			core = {
				newestVersion = nil,
				GUI = {
					rosterInfo = {
						showAlts = true,
						showOnlyMaxLvl = false,
						hideOffline = false,
						sortByPrimary = 'rankIndex',
						sortBySecondary = 'name',
						sortByPrimaryInvert = false,
						sortBySecondaryInvert = false,
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
							mainSpec = 'NONE',
							offSpec = 'NONE',
							mainSpecDPS = 0,
							offSpecDPS = 0,
							rank = '',
							rankIndex = -1,
							level = -1,
							zone = '',
							note = '',
							officerNote = '',
							privateNote = '',
							online = nil,
							offlineFor = {
								hours = nil, 
								days = nil,
								months = nil,
								years = nil,
							},
							status = '',
							class = '',
							guildIndex = -1,
						},
					},
				},
			},

			settings = {
				GUI = {
					useAutoComplete = true,
					LDBShowEvents = true,
					LDBDefaultMain = false,
				},
				sync = {
					enabled = true,
					onlyWhenFrame = true,
					onlyHighOrSameRank = true,
				},
				general = {
					updateOwnSpec = true,
					updateSpecsOnInspect = true,
				}
			},
		},

		-- Character-specific data. Every character has its own database.
		char = {
			settings = {
				loadMessage = true,
			},
			GUI = {
				savedMainFramePos = nil
			}
		},
	}

end
