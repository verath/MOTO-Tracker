local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

-- Options
function A:SetupOptions()
	
	A.options = {
		name = L["MOTO Tracker"],
		type = 'group',
		args = {
			MOTO_Header = {
				order = 1,
				type = "header",
				name = L["Version"] .. ": " .. I.versionName,
				width = "Full",
			},


			LoadMessage = {
				order = 2,
				type = 'toggle',
				name = L['Show load message'],
				desc = L['Display a message when the addon is loaded or enabled.'],
				get = function(info) return A.db.char.settings.loadMessage end,
				set = function(info, value) A.db.char.settings.loadMessage = value end,
			},

			RestoreDefaults = {
				order = 3,
				type = 'execute',
				name = L['Restore Defaults'],
				desc = L['Restores ALL settings to their default values. Does not clear the database.'],
				confirm = function() return L['Are you sure you want to restore ALL settings?'] end,
				func = function() A.db.char.settings = nil; A.db.global.settings = nil; A:SetupDB() end,
			},

			ResetDB = {
				order = 4,
				type = 'execute',
				name = L['Reset Database'],
				desc = L['Resets the whole database (including settings).'],
				confirm = function() return L['Are you sure you want to reset the whole database? This can not be undone!'] end,
				func = function() A.db:ResetDB('Default'); A:SetupDB() end,
			},

			GeneralSettings = {
				name = L['General Settings'],
				type = "group",
				inline = true,
				args = {
					UpdateOwnSpec = {
						order = 1,
						type = 'toggle',
						name = L['Auto update own specs'],
						desc = L['Automatically updates your characters main spec and off spec to your current talent specs when loggin in and/or changing specs.'],
						get = function(info) return A.db.global.settings.general.updateOwnSpec end,
						set = function(info, value) A.db.global.settings.general.updateOwnSpec = value end,
					},
					UseAutoComplete = {
						order = 5,
						type = 'toggle',
						name = L['Use auto-complete'],
						desc = L['Use auto-complete for a few fields in the addon (mostly when entering character names).'],
						get = function(info) return A.db.global.settings.GUI.useAutoComplete end,
						set = function(info, value) A.db.global.settings.GUI.useAutoComplete = value end,
					},
					
				},
				order = 20,
			},

			Sync = {
				name = L['Sync Settings'],
				type = "group",
				inline = true,
				args = {
					SyncEnabled = {
						order = 1,
						type = 'toggle',
						width = 'full',
						name = L['Enabled'],
						desc = L['Enable or disable syncing.'],
						get = function(info) return A.db.global.settings.sync.enabled end,
						set = function(info, value) A.db.global.settings.sync.enabled = value end,
					},
					SyncOnlyHighOrSameRank = {
						order = 2,
						type = 'toggle',
						name = L['Only my rank or higher'],
						desc = L['Only receive data from players with the same or higher guild rank.'],
						get = function(info) return A.db.global.settings.sync.onlyHighOrSameRank end,
						set = function(info, value) A.db.global.settings.sync.onlyHighOrSameRank = value end,
					},
					SyncOnlyWhenFrame = {
						order = 5,
						type = 'toggle',
						name = L['Only receive when open'],
						desc = L['Only show popoups about sharing if the addon frame is opened.'],
						get = function(info) return A.db.global.settings.sync.onlyWhenFrame end,
						set = function(info, value) A.db.global.settings.sync.onlyWhenFrame = value end,
					},
				},
				order = 21,
			},
			
			LayoutSettings = {
				name = L['Layout Settings'],
				type = "group",
				inline = true,
				args = {
					RestoreFrame = {
						order = 3,
						type = 'execute',
						name = L['Reset Frame'],
						desc = L['Resets the position and size of the main frame.'],
						func = function() A.GUI:HideMainFrame(); A.db.char.GUI.savedMainFramePos = nil; A:Print(L['Frame position reset.']) end,
					},
				},
				order = 25,
			}

			LDBSettings = {
				name = L['LDB Settings'],
				type = "group",
				inline = true,
				args = {
					LDBExplain = {
						type = "header",
						name = L['LDB (LibDataBroker) is used by many addons to display data and provide shortcuts. ´Make sure you also assign MOTO Tracker a field within your LDB display addon.'],
						width = "Full",
					},
					FlashLDBText = {
						order = 3,
						type = 'toggle',
						name = L['Display Events'],
						desc = L['Flashes new guild events as the LDB text.'],
						get = function(info) return A.db.global.settings.GUI.LDBShowEvents end,
						set = function(info, value) A.db.global.settings.GUI.LDBShowEvents = value end,
					},
				},
				order = 25,
			}

			--[[CharSpecific = {
				name = L["Character Specific Settings"],
				type = "group",
				inline = true,
				args = {
					
				},
				order = 25,
			}, --]]
		},
	}
	


	LibStub("AceConfig-3.0"):RegisterOptionsTable(I.addonName, A.options)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(I.addonName, A.options)
	A.ConfigFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(I.addonName, L['MOTO Tracker'], nil)
end
