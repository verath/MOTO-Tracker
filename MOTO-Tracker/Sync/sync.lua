--###################################
--   Main sync file, register prefixes etc.
--###################################

local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info

-- Init our sync object
A.sync = {}

-- Load libs
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibCompress = LibStub:GetLibrary("LibCompress")
local LibCompressEncode = LibCompress:GetAddonEncodeTable()

-- Local versions are faster
local sSub = string.sub


--###################################
--   Helper Functions
--###################################

-- Serializes, encodes and compresses a value
function A.sync:CompressObject( data )
	local serialized = AceSerializer:Serialize(data)
	local compressed = LibCompress:Compress(serialized)
	local final = LibCompressEncode:Encode(compressed)
	return final
end

-- Reverse of compressObject (decomress, unencode and deserialize)
function A.sync:DecompressString( str )
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



--###################################
--   CommHandler
--###################################

-- Handler for all communication
-- NOTE: THIS IS A METHOD DIRECTLY ON THE ADDON CLASS. NOT A.sync!
function A:OnCommReceived( prefix, message, distribution, sender )
	-- Don't want to react on our own messages
	if sender == I.charName then return end
	
	if prefix == 'MOTOTChar' then
		A.sync.char:HandleCommChar( message, distribution, sender )	
	elseif prefix =='MOTOCharData' then
		A.sync.char:HandleCommCharData( message, distribution, sender )	
	elseif prefix == 'MOTOTInfo' then
		if #message > 8 and sSub(message, 1, 8) == 'Version|' then 
			-- Update string sent from someone in guild
			A:CheckVersion( sSub(message, 9) )
		end
	end
end


--###################################
--   Set Up
--###################################

function A.sync:SetupSync()	
	do -- Register prefixes
		-- General info, handled by main file (version checking, etc.)
		A:RegisterComm('MOTOTInfo', 'OnCommReceived')
		-- Char syncing
		A:RegisterComm('MOTOTChar', 'OnCommReceived')
		A:RegisterComm('MOTOTCharData', 'OnCommReceived')
	end

	do -- Call setup on the other sync parts
		A.sync.char:SetupCharSync()
	end

	-- Send our version to the guild
	A:SendCommMessage('MOTOTInfo', 'Version|' .. I.versionName, 'GUILD', '', 'NORMAL')
end

