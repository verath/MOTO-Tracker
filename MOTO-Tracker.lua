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

	-- Start listening for events
	A:RegisterEvent('GUILD_ROSTER_UPDATE', 'OnGuildRosterUpdate')
	
	-- Request guild roster from server
	GuildRoster()

	-- Static values
	I.hasGuild = IsInGuild()
	if I.hasGuild then
		I.guildName, _ = GetGuildInfo("player")
	end

	-- Set up the options UI
	self:SetupOptions()
end

-- Gets called if the addon is disabled
function A:OnDisable()

	-- Unregister Events
	A:UnregisterEvent('GUILD_ROSTER_UPDATE')
end


-- When guild roster is updated
local firstRosterUpdate = true
function A:OnGuildRosterUpdate( event, change )
	if not I.hasGuild then return end

	-- We only need to update our DB if a change did occur
	-- or if this is first update after login.
	if change == nil and firstRosterUpdate ~= true then return end
	firstRosterUpdate = false

	local numGuildMembers, _ = GetNumGuildMembers()
	A:Print(numGuildMembers)
	A:Print(change)

end
