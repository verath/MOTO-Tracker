--###################################
--   Core setups and functions
--###################################

-- The "..." passed by wow is explained over at
-- http://www.wowinterface.com/forums/showthread.php?t=36308
local addonName, addonTable = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("MOTOTracker", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")
local locale = LibStub("AceLocale-3.0"):GetLocale("MOTOTracker", true)
local info = { -- Static global values
	versionName = GetAddOnMetadata(addonName, "Version"),
	--@debug@
	versionName = '0.0.0-dev',
	--@end-debug@
	addonName = addonName,
}


addonTable[1] = addon
addonTable[2] = locale
addonTable[3] = info

-- Make methods accessible from outside of addon.
_G[addonName] = addonTable

-- addon, locale, info
local A,L,I = addon, locale, info--unpack(select(2, ...))

local AceTimer = LibStub("AceTimer-3.0")

-- Local versions are faster
local tRemove = table.remove
local tInsert = table.insert
local sSub = string.sub
local sUpper = string.upper
local sSplit = strsplit
local tonumber = tonumber
local tinsert = tinsert

--###################################
--	Helper Functions
--###################################

-- Parses a version string (major.minor.build-status)
local function parseVersionString( versionString )
	local versionString = versionString or I.versionName

	local major, minor, buildStatus = sSplit('.', versionString)
	local build, status = sSplit('-', buildStatus)

	major, minor, build = tonumber(major), tonumber(minor), tonumber(build)

	if status == 'release' or status == 'stable' then
		status = 3
	elseif status == 'beta' or status == 'b' then
		status = 2
	elseif status == 'alpha' or status == 'a' then
		status = 1
	else
		status = -1
	end

	return {
		major = major,
		minor = minor,
		build = build,
		status = status,
	}
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
			-- If removed char has a main, unset alt data of that main
			if chars[charName].main ~= nil then
				A:RemoveAltFromMain( charName, chars[charName].main )
			end

			-- If char has alts, unset main data for all of them
			if chars[charName].alts then
				for i = 1, #chars[charName].alts do
					A:RemoveAltFromMain( chars[charName].alts[i], charName )
				end
			end

			-- Remove the char from the db
			chars[charName] = nil
		end
	end
end

--###################################
--	Global Core Methods
--###################################

-- Initializes the DB
function A:SetupDB()
	self:SetupDefaults()
	self.db = LibStub("AceDB-3.0"):New("MOTOTrackerDB", A.defaults, true)
end

-- Checks if we have a new version, or if version is provided
-- compares it to our version and sets the new version flag
function A:CheckVersion(version)
	local version = version or self.db.global.core.newestVersion
	if version == nil then return false end
	
	local localVersion = parseVersionString()
	local newVersion = parseVersionString(version)

	-- Release, Beta, Alpha
	if newVersion.status < localVersion.status then return false end

	-- MAJOR.minor.build
	if localVersion.major < newVersion.major then 
		self.db.global.core.newestVersion = version
		return true, version 
	elseif localVersion.major > newVersion.major then
		return false
	end

	-- major.MINOR.build
	if localVersion.minor < newVersion.minor then
		self.db.global.core.newestVersion = version
		return true, version
	elseif localVersion.minor > newVersion.minor then
		return false
	end

	-- major.minor.BUILD
	if localVersion.build < newVersion.build then
		self.db.global.core.newestVersion = version
		return true, version
	elseif localVersion.build > newVersion.build then
		return false
	end 
end

-- Removes an alt/main relationship
function A:RemoveAltFromMain( altName, mainName )
	-- First unset the main data of the alt
	local altData = self.db.global.guilds[I.guildName].chars[altName]
	if not altData or not altData.main then return end
	altData.main = nil

	-- Now remove our alt from the alt data of the main
	local mainData = self.db.global.guilds[I.guildName].chars[mainName]
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
function A:ChangeCharMain( charName, newMainName )
	local charData = self.db.global.guilds[I.guildName].chars[charName]

	-- Remove alt from old main and main from alt. providing a 
	-- non-existing main will only unset the current main
	self:RemoveAltFromMain(charData.name, charData.main)

	-- Validate new main
	if charName == newMainName then return '' end

	-- If adding to an alt, add to the alt's main
	local newMain = self.db.global.guilds[I.guildName].chars[newMainName]
	if newMain.main ~= nil then 
		newMain = self.db.global.guilds[I.guildName].chars[newMain.main] 
	end
	
	if newMain.name == '' then return '' end
	
	-- Set new main-alt data
	charData.main = newMain.name
	if newMain.alts == nil then newMain.alts = {} end
	tInsert(newMain.alts, charData.name)

	return newMain.name
end

-- Sets/Changes the main of a player
function A:SetMainChar( charName ) 
	local charData = self.db.global.guilds[I.guildName].chars[charName]

	-- If the character is main or doesn't exist, stop
	if charData.name == '' or charData.main == nil then return end

	-- Get current main/alts
	local oldMain = self.db.global.guilds[I.guildName].chars[charData.main]
	local oldAlts = oldMain.alts
	
	local newAlts = {}
	local i = 1
	while oldAlts and oldAlts[i] do
		if ( oldAlts[i] ~= charName ) then
			-- Set the new main
			self.db.global.guilds[I.guildName].chars[oldAlts[i]].main = charName
			tInsert(newAlts, oldAlts[i])
		end
		i = i+1
	end

	-- Unset oldMain's alt table and add oldMain to alt table
	tInsert(newAlts, oldMain.name)
	oldMain.alts = nil
	oldMain.main = charName

	-- Set new mains alt table and unset its main value
	charData.alts = newAlts
	charData.main = nil
end

-- Finds a char by a player (Main + alts) by looking for a specified value
function A:FindPlayerChar( charName, key, value )
	local charData = self.db.global.guilds[I.guildName].chars[charName]
	if charData[key] and charData[key] == value then return charData.name end

	-- Get the main
	if charData.main ~= nil then
		charData = A.db.global.guilds[I.guildName].chars[charData.main]
		if charData[key] and charData[key] == value then return charData.name end
	end

	if charData.alts == nil then return false end

	-- Go trough alts
	local i = 1
	while charData.alts[i] do
		local alt = self.db.global.guilds[I.guildName].chars[charData.alts[i]]
		if alt[key] and alt[key] == value then return alt.name end
		i = i+1
	end
	
	return false
end

-- Returns the char with the highest value for key among main/alts of player
-- The value in key must be compareable
function A:GetPlayerCharByCompareValue( charName, key, lowestValue, invert )
	local highestValue = lowestValue or 0
	local highestName = ''
	local invert = invert and true or false
	
	-- Get the main
	local charData = self.db.global.guilds[I.guildName].chars[charName]
	if charData.main ~= nil then
		charData = A.db.global.guilds[I.guildName].chars[charData.main]
	end

	-- Test the main
	if charData[key] then
		if (not invert and charData[key] > highestValue) or (invert and charData[key] < highestValue) then 
			highestValue = charData[key]
			highestName	= charData.name
		end
	end
	
	if charData.alts == nil then
		return highestName, highestValue
	end

	-- Go trough alts
	local i = 1
	while charData.alts[i] do
		local alt = self.db.global.guilds[I.guildName].chars[charData.alts[i]]
		if alt[key] then
			if (not invert and alt[key] > highestValue) or (invert and alt[key] < highestValue) then
				highestValue = alt[key]
				highestName	= alt.name
			end
		end
		i = i+1
	end
	

	return highestName, highestValue
end

-- Updates/Adds guild memeber to our db
function A:UpdateGuildMemeberFromRoster( index )
	local name, rank, rankIndex, level, _, zone, note, officerNote, online, status, class = GetGuildRosterInfo(index)
	local P = self.db.global.guilds[I.guildName].chars[name]

	if not P then return end
	
	-- Update guild info
	P.name, P.rank, P.rankIndex, P.level, P.zone, P.note, P.class, P.guildIndex, P.online, P.status = name, rank, rankIndex, level, zone, note, class, index, online, status

	if not online then
		local yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(index);
		P.offlineFor = {
			hours = hoursOffline, 
			days = daysOffline,
			months = monthsOffline,
			years = yearsOffline,
		}
	end

	if I.canViewOfficerNote then
		P.officerNote = officerNote
	end

	return name, rank, rankIndex, level, zone, note, class, index, online, status, class
end

-- Updates the entier guild roster
function A:UpdateGuildRoster()
	I.numGuildMembers, I.numGuildOnline = GetNumGuildMembers()
	I.numGuildAFK = 0
	I.guildMembers, I.guildOnline, I.guildAFK = {}, {}, {}

	for i = 1, I.numGuildMembers do
		local name,_,_,_,_,_,_,_, online, status = self:UpdateGuildMemeberFromRoster(i)
		
		tinsert(I.guildMembers, name)
		
		if online then
			tinsert(I.guildOnline, name)
		end

		if status == 1 then
			I.numGuildAFK = I.numGuildAFK + 1
			tinsert(I.guildAFK, name)
		end

	end
end

-- Updates the current characters main spec and off spec by
-- looking at talent trees
function A:UpdatePlayerTalents()
	if not I.hasGuild then return end
	if not self.db.global.settings.general.updateOwnSpec then return end
	if not I.guildName then
		-- Delay check until we have a guildName (after logged in)
		local that = self
		AceTimer:ScheduleTimer((function() that:UpdatePlayerTalents() end), 2) 
		return
	end

	local mainSpecGroup = GetSpecialization(false, false, 1)
	local offSpecGroup = GetSpecialization(false, false, 2)

	if mainSpecGroup ~= nil then
		local id, n, d, i, b, r = GetSpecializationInfo(mainSpecGroup)
		self.db.global.guilds[I.guildName].chars[I.charName].mainSpec = id
	end

	if offSpecGroup ~= nil then
		local id, n, d, i, b, r = GetSpecializationInfo(offSpecGroup)
		self.db.global.guilds[I.guildName].chars[I.charName].offSpec = id
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
	self:RegisterEvent('GUILD_ROSTER_UPDATE', 'OnGuildRosterUpdate')
	self:RegisterEvent('PLAYER_GUILD_UPDATE', 'OnGuildRosterUpdate')
	self:RegisterEvent('PLAYER_TALENT_UPDATE', 'OnPlayerTalentUpdate')
	self:RegisterChatCommand('MOTOT', "SlashHandler")
	self:RegisterChatCommand('MOTOTracker', "SlashHandler")
	
	-- Request guild roster from server
	GuildRoster()
	
	-- Set up the options UI
	self:SetupOptions()

	-- Set up the GUI
	self.GUI:SetupGUI()

	-- Set up the syncing
	self.sync:SetupSync()
end

-- Gets called if the addon is disabled
function A:OnDisable()
	-- Unregister Events
	self:UnregisterEvent('GUILD_ROSTER_UPDATE')
	self:UnregisterEvent('PLAYER_GUILD_UPDATE')
	self:UnregisterEvent('PLAYER_TALENT_UPDATE')
	self:UnregisterChatCommand('MOTOT')
	self:UnregisterChatCommand('MOTOTracker')
end


-- When guild roster is updated
local firstRosterUpdate = true
function A:OnGuildRosterUpdate( event, arg1, ... )
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

	
	A:UpdateGuildRoster()

	-- Pass event onto the GUI handler
	A.GUI:OnRosterUpdate(event, arg1, ...)

	firstRosterUpdate = false
end

function A:OnPlayerTalentUpdate( ... )
	self:UpdatePlayerTalents()
end


-- Slash handler
function A:SlashHandler(input)
	if input == '' then
		self.GUI:ShowMainFrame()
	end
end

