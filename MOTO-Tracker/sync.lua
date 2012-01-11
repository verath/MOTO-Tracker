--###################################
--   Syncing (sending data between players)
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

local AceTimer = LibStub("AceTimer-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressEncode = LibCompress:GetAddonEncodeTable()

local tInsert = table.insert
local sSub = string.sub

A.sync = {}
local syncSettings
local sharedCharDataString = ''
local sharedCharName = ''
local isSharingChar = false

-- Popups
StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'] = {
	text = '',
	button1 = YES,
	button2 = NO,
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 15,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs['MOTOTracker_Sync_Already_Sharing'] = {
	text = L['Already sharing a character!|n|nPlease wait at least 20 seconds after sending a character before sending another one.'],
	button1 = OKAY,
	timeout = 20,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs['MOTOTracker_Sync_Sharing'] = {
	button1 = CANCEL,
	text = '',
	timeout = 20,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}


--###################################
--   Helper Functions
--###################################

-- Reverse of compressObject
local function decompressString( str )
	local decoded = LibCompressEncode:Decode(str)

	--Decompress the decoded data
	local decompressed, message = LibCompress:Decompress(decoded)
	if(not decompressed) then
		A:Print("error decompressing: " .. message)
		return nil
	end

	-- Deserialize the decompressed data
	local success, final = AceSerializer:Deserialize(decompressed)
	if (not success) then
		A:Print("error deserializing: " .. message)
		return nil
	end

	return final
end

-- Serializes, encodes and compresses a value
local function compressObject( data )
	local serialized = AceSerializer:Serialize(data)
	local compressed = LibCompress:Compress(serialized)
	local final = LibCompressEncode:Encode(compressed)
	return final
end

-- Asks user for confirmation for reccieving something from another player
local function ConfirmReceiveChar( charName, sentBy, OnAccept, OnCancel )
	if A.GUI.mainFrame == nil and A.db.global.settings.sync.onlyWhenFrame then 
		OnCancel(); 
		return 
	end

	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].text = format( L['%s is sharing data for %s.|n|nDo you want to recceive this data (this will overwrite your own data for %s)?'],  LIGHTYELLOW_FONT_COLOR_CODE .. sentBy .. FONT_COLOR_CODE_CLOSE, GREEN_FONT_COLOR_CODE .. charName .. FONT_COLOR_CODE_CLOSE, GREEN_FONT_COLOR_CODE .. charName .. FONT_COLOR_CODE_CLOSE)
	
	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].OnAccept = OnAccept
	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].OnCancel = OnCancel
	
	StaticPopup_Show('MOTOTracker_Sync_Confirm_Receive')
end

--###################################
--   Char Sending
--###################################

-- Called when user clicks the share button in the ui.
function A.sync:SendChar( charName )
	if not syncSettings.enabled then return end

	if isSharingChar then
		-- We only allow sharing of one char at a time,
		-- not going to spam data.
		StaticPopup_Show('MOTOTracker_Sync_Already_Sharing')
		return
	end

	do -- Display info pop-up while we are sharing.
		StaticPopupDialogs['MOTOTracker_Sync_Sharing'].text = format(L['Sharing %s for 20 seconds.'], GREEN_FONT_COLOR_CODE .. charName .. FONT_COLOR_CODE_CLOSE)
		-- OnAccept is on button one, and we only have one button.
		StaticPopupDialogs['MOTOTracker_Sync_Sharing'].OnAccept = function() A.sync:StopSharingChar() end
		StaticPopup_Show('MOTOTracker_Sync_Sharing')
	end

	local charData = A.db.global.guilds[I.guildName].chars[charName]
	-- TODO: Ask user for what to send
	local keysToSend = {'name', 'alts', 'main', 'mainSpec', 'offSpec'}

	local dataToSend = {}
	for _, key in ipairs(keysToSend) do
		dataToSend[key] = charData[key]
	end
	
	-- Serializes and compresses the object into a more
	-- easily/faster sharable string
	sharedCharDataString = compressObject(dataToSend)
	sharedCharName = charName
	
	startSharingChar()
	isSharingChar = true
	
	AceTimer:ScheduleTimer( function() A.sync:StopSharingChar() end, 20)
end

-- Starts sharing a character
local function startSharingChar()
	-- Brodcast to guild that we are sharing
	A:SendCommMessage('MOTOTChar', 'Sharing|' .. sharedCharName, 'GUILD', '', 'NORMAL')
end

-- Sends a shared char object to a player that requested it
local function sendSharedCharTo( target )
	if not isSharingChar then return end
	A:Print( format(L['Sent data for %s to %s.'], sharedCharName, target) )
	A:SendCommMessage('MOTOTCharData', sharedCharDataString, 'WHISPER', target, 'NORMAL')
end

-- Stops listening for requests for the char we were sharing
function A.sync:StopSharingChar()
	isSharingChar = false
end


--###################################
--   Char Receiving
--###################################

-- Someone is sharing a char, ask user if we want it
local function charSharedWithMe( charName, sharedBy )
	if not syncSettings.enabled then return end

	ConfirmReceiveChar( charName, sharedBy, function() requestSharedChar(charName, sharedBy) end)
end

-- User wants the shared char, request it from the player sharing it
local function requestSharedChar(charName, sharer)
	local message = 'WantChar' .. charName
	A:SendCommMessage('MOTOTChar', message, 'WHISPER', sharer, 'NORMAL')
end


--Handler for receiving charData
function A:OnCommCharReceived(prefix, message, distribution, sender)
	-- Don't want to react on our own messages
	if sender == I.charName then return end

	local data = decompressString(message)
	if data == nil then return end

	local charName = data.name
	local localData = A.db.global.guilds[I.guildName].chars[charName]
	
	do-- Handle alt/main
		-- Remove our local char from any alt/main relations
		if localData.main then
			local mainName = localData.main
			A:RemoveAltFromMain(charName, mainName)
		end

		-- If our local char has any alt data, unset them
		if localData.alts then
			for i, altName in ipairs(localData.alts) do
				A:RemoveAltFromMain(altName, charName)
			end
		end

		-- If char received has alts
		if data.alts then
			for _,alt in ipairs(data.alts) do
				-- Set each alt to the char
				A:ChangeMain(alt, charName)
			end
		elseif data.main then
			-- If char received is an alt
			A:ChangeMain(charName, data.main)	
		end

		-- Remove from our data table
		data.main = nil
		data.alts = nil
	end
	
	-- Just loop trough the rest and set the values
	for k,v in pairs(data) do
		localData[k] = v
	end

	-- Update our frame
	A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end

--###################################
--   CommHandler
--###################################

-- Handler for all communication
function A:OnCommReceived( prefix, message, distribution, sender )
	-- Don't want to react on our own messages
	if sender == I.charName then return end
	
	if prefix == 'MOTOTChar' then
		if distribution == 'GUILD' then
			if #message > 8 and sSub(message, 1, 8) == 'Sharing|' then 
				-- Someone is sharing a char
				charSharedWithMe( sSub(message, 9), sender )
			end
		elseif distribution == 'WHISPER' then
			if isSharingChar and message == 'WantChar' .. sharedCharName then
				-- Someone want the char we are sharing
				sendSharedCharTo( sender )
			end
		end
	end
end

--###################################
--   Set Up
--###################################

function A.sync:SetupSync()
	syncSettings = A.db.global.settings.sync
	A:RegisterComm('MOTOTChar', 'OnCommReceived')
	A:RegisterComm('MOTOTCharData', 'OnCommCharReceived')
end

