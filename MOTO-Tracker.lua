--###################################
--   Set Up
--###################################
MOTOTracker = {
	addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0"),
	locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true),
	info = { -- Static global values
		versionName = '1.0.0-beta',
		addonName = 'MOTOTracker',
	}
}
local AceTimer = LibStub("AceTimer-3.0")

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

local tRemove = table.remove
local tInsert = table.insert
local sSub = string.sub
local sUpper = string.upper

--###################################
--	Helper Functions
--###################################

-- Initializes the DB
function A:SetupDB()
	self:SetupDefaults()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", A.defaults, true)
end

-- Removes an alt/main relationship
function A:RemoveAltFromMain( altName, mainName )
	-- First unset the main data of the alt
	local altData = A.db.global.guilds[I.guildName].chars[altName]
	altData.main = nil

	-- Now remove our alt from the alt data of the main
	local mainData = A.db.global.guilds[I.guildName].chars[mainName]
	if not mainData or not mainData.alts then return end

	-- Find our alt and remove it
	local i = 1;
	while mainData.alts[i] do
		if ( mainData.alts[i] == altName ) then
			tRemove( mainData.alts, i )
			break
		end
		i = i + 1;
	end
	
	if #mainData.alts == 0 then
		mainData.alts = nil
	end
end

-- Sets/updates a character's main and that main's alt table
function A:ChangeMain( charName, newMainName )
	local charData = A.db.global.guilds[I.guildName].chars[charName]
	-- Remove alt from old main and main from alt
	A:RemoveAltFromMain(charData.name, charData.main)

	-- Validate new main
	local newMain = A.db.global.guilds[I.guildName].chars[newMainName]
	if newMain.name == '' then return end
	if newMain.main ~= nil then return end
	
	-- Set new main-alt data
	charData.main = newMainName
	if newMain.alts == nil then newMain.alts = {} end
	tInsert(newMain.alts, charData.name)
end

-- Updates/Adds guild memeber to our db
function A:UpdateGuildMemeberFromRoster( index )
	local name, rank, rankIndex, level, _, zone, note, officerNote, online, status, class = GetGuildRosterInfo(index)

	local P = A.db.global.guilds[I.guildName].chars[name]
	
	-- Update guild info
	P.name, P.rank, P.rankIndex, P.level, P.zone, P.note, P.class, P.guildIndex, P.online, P.status = name, rank, rankIndex, level, zone, note, class, index, online, status

	if I.canViewOfficerNote then
		P.officerNote = officerNote
	end

end

-- Updates the entier guild roster (Do not use too much...)
function A:UpdateGuildRoster()
	local numGuildMembers, _ = GetNumGuildMembers()

	for i = 1, numGuildMembers do
		A:UpdateGuildMemeberFromRoster( i )
	end
end

-- Checks local guild DB against roster and
-- removes members no longer in the guild
local function removeNoLongerGuildMemebers()
	if not I.hasGuild or not I.guildName then return end
	
	-- Seems like we don't always get the numbere here.
	local numMembers = GetNumGuildMembers()
	if numMembers == 0 then return end

	local chars = A.db.global.guilds[I.guildName].chars
	
	-- Create a roster table with name as key
	local charsInGuild = {}
	for i = 1, numMembers do
		local name,_ = GetGuildRosterInfo(i)
		charsInGuild[name] = true
	end

	for charName,_ in pairs(chars) do
		if charsInGuild[charName] ~= true then
			chars[charName] = nil
		end
	end
end

-- Returns the name of tree in group (primary/secondary spec) 
-- with most points
function A:GetTalentSpecForGroup( talentGroup, inspect )
	if GetNumTalentGroups(inspect, false) < talentGroup then return nil end
	
	local mostPoints, spec = 0, nil
	for i = 1, GetNumTalentTabs(inspect, false) do
		local pointSpent = select(5, GetTalentTabInfo(i, inspect, false, talentGroup)) 
		local tabName = select(2, GetTalentTabInfo(i, inspect, false, talentGroup)) -- TODO: Localize
		if pointSpent and pointSpent > mostPoints then 
			spec = sUpper(tabName)
			mostPoints = pointSpent
		end
	end

	return spec
end

-- Updates the current characters main spec and off spec by looking at
-- talent trees
function A:UpdatePlayerTalents()
	if not I.hasGuild then return end
	if not I.guildName then
		-- Delay check untill we have a guildName (after logged in)
		local that = self
		AceTimer:ScheduleTimer((function() that:UpdatePlayerTalents() end), 2) 
		return
	end
	if not A.db.global.settings.general.updateOwnSpec then return end
	
	local class = I.charClass
	local mainSpec = A:GetTalentSpecForGroup( 1, false )
	local offSpec = A:GetTalentSpecForGroup( 2, false )

	-- For now I got no good way to handle localized talent names,
	-- so if not in table they will not get updated. Sorry.
	if mainSpec and I.classSpecs[class][mainSpec] then
		A.db.global.guilds[I.guildName].chars[I.charName].mainSpec = mainSpec
	end
	if offSpec and I.classSpecs[class][offSpec] then
		A.db.global.guilds[I.guildName].chars[I.charName].offSpec = offSpec
	end

end

--###################################
--	Event functions
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

	-- Static values
	self:LoadStaticValues()

	-- Start listening for events
	A:RegisterEvent('GUILD_ROSTER_UPDATE', 'OnGuildRosterUpdate')
	A:RegisterEvent('PLAYER_GUILD_UPDATE', 'OnGuildRosterUpdate')
	A:RegisterEvent('PLAYER_TALENT_UPDATE', 'OnPlayerTalentUpdate')
	A:RegisterChatCommand('MOTOT', "SlashHandler")
	A:RegisterChatCommand('MOTOTracker', "SlashHandler")
	
	-- Request guild roster from server
	GuildRoster()
	
	-- Set up the options UI
	self:SetupOptions()

	-- Set up the syncing
	A.sync:SetupSync()
end

-- Gets called if the addon is disabled
function A:OnDisable()
	-- Unregister Events
	A:UnregisterEvent('GUILD_ROSTER_UPDATE')
	A:UnregisterEvent('PLAYER_GUILD_UPDATE')
	A:UnregisterChatCommand('MOTOT')
	A:UnregisterChatCommand('MOTOTracker')
end


-- When guild roster is updated
local firstRosterUpdate = true
function A:OnGuildRosterUpdate( event,_ )
	if not I.hasGuild then return end
	
	-- Do once update on login
	if firstRosterUpdate or event == 'PLAYER_GUILD_UPDATE' then
		-- Get guild specific info now, as it should all be loaded
		I.guildName, _ = GetGuildInfo("player")
		I.canViewOfficerNote = CanViewOfficerNote() ~= nil and true or false
		I.canEditOfficerNote = CanEditOfficerNote() ~= nil and true or false
		I.canEditPublicNote = CanEditPublicNote() ~= nil and true or false

		removeNoLongerGuildMemebers()
	end

	if event == 'GUILD_ROSTER_UPDATE' then
		A:UpdateGuildRoster()
	end

	-- Pass event onto the GUI handler
	A.GUI:OnRosterUpdate()

	firstRosterUpdate = false

end

function A:OnPlayerTalentUpdate( ... )
	A:UpdatePlayerTalents()
end


-- Slash handler
function A:SlashHandler(input)
	if input == '' then
		A.GUI:ShowMainFrame()
	end
end

