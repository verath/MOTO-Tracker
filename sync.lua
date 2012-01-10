local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

local AceTimer = LibStub("AceTimer-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressEncode = LibCompress:GetAddonEncodeTable()

local tInsert = table.insert

A.sync = {}
local syncSettings

-- Popups
StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'] = {
	text = '',
	button1 = YES,
	button2 = NO,
	OnAccept = function() end,
	OnCancel = function() end,
	timeout = 30,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs['MOTOTracker_Sync_Already_Sharing'] = {
	text = L['Already sharing a character!|n|nPlease wait at least 15 seconds after sending a character before sending another one.'],
	button1 = OKAY,
	timeout = 15,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

-- Reverse of compressForSending
local function decompressString( str )
	local decoded = LibCompressEncode:Decode(str)

	--Decompress the decoded data
	local decompressed, message = LibCompress:Decompress(decoded)
	if(not two) then
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


-- Asks user for confirmation for reccieving a char from another player
local function ConfirmReceiveChar( charName, sentBy, OnAccept, OnCancel )
	-- We are not going to show pop-ups if our guild frame is not open.
	if A.GUI.mainFrame == nil then OnCancel(); return end

	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].text = format( L['%s is sharing data for %s.|n|nDo you want to recceive this data (this will overwrite your own data for %s)?'],  LIGHTYELLOW_FONT_COLOR_CODE .. sentBy .. FONT_COLOR_CODE_CLOSE, GREEN_FONT_COLOR_CODE .. charName .. FONT_COLOR_CODE_CLOSE, GREEN_FONT_COLOR_CODE .. charName .. FONT_COLOR_CODE_CLOSE)
	
	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].OnAccept = OnAccept
	StaticPopupDialogs['MOTOTracker_Sync_Confirm_Receive'].OnCancel = OnCancel
	
	StaticPopup_Show('MOTOTracker_Sync_Confirm_Receive')
end

function A.sync:SetupSync()
	syncSettings = A.db.global.settings.sync
	A:RegisterComm('MOTOTracker', 'OnCommReceived')
end

local sharedCharDataString = ''
local isSharingChar = false
function A.sync:SendChar( charName )
	if not syncSettings.enabled then return end

	A:SendCommMessage('MOTOTracker', 'TEsting testing', 'GUILD', '', prio)

	if isSharingChar then
		-- We only allow sharing of one char at a time,
		-- not going to spam data.
		StaticPopup_Show('MOTOTracker_Sync_Already_Sharing')
		return
	end

	local charData = A.db.global.guilds[I.guildName].chars[charName]
	-- TODO: Ask user for what to send
	local keysToSend = {'name', 'alts', 'main', 'mainSpec', 'offSpec'}

	local dataToSend = {}
	for _, key in ipairs(keysToSend) do
		tInsert(dataToSend, {[key] = charData[key]})
	end
	
	-- Serializes and compresses the object into a more
	-- easily/faster sharable string
	sharedCharDataString = compressObject(dataToSend)

	isSharingChar = true
	AceTimer:ScheduleTimer( function() A.sync:StopSharing() end, 15)

end

-- Starts sharing a character
function A.sync:StartSharing()
	-- Brodcast to guild that we are sharing
	--AceComm
	-- Listen for incomming requests to get our shared data
end

-- Stops listening for requests for the char we were sharing
function A.sync:StopSharing()
	isSharingChar = false
end

-- Handler for all received data
function A:OnCommReceived( prefix, message, distribution, sender )
	print( prefix )
	print( message )
	print(distribution )
	print(sender)
end

