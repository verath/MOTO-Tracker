--###################################
--   Set Up
--###################################
MOTOTracker = {
	addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0"),
	locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true),
	info = { -- Static global values
		versionName = '0.01a',
		addonName = 'MOTOTracker',
	}
}

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info




--###################################
--   Helper Functions
--###################################

local function UpdateGuildRoster()
	
end

function A:SetupDB()
	self:SetupDefaults()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", A.defaults, true)
end


--###################################
--   Event functions
--###################################

-- Called by ace3 once saved variables are available
function A:OnInitialize()
	self:SetupDB()
end

-- Gets called during the PLAYER_LOGIN event or
-- when addon is enabled.
function A:OnEnable()
	if self.db.char.settings.loadMessage then
		A:Print(L['MOTO Tracker enabled.'])
	end

	I.hasGuild = IsInGuild()

	if I.hasGuild then
		I.guildName, _ = GetGuildInfo("player")
	end

	self:SetupOptions()
end


