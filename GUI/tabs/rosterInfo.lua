--###################################
--	Roster Info tab
--###################################

-- addon, locale, info
local A,L,I = unpack(select(2, ...))

local AceGUI = LibStub("AceGUI-3.0")

-- Local versions of global functions are faster
local tableInsert = table.insert
local tableRemove = table.remove
local stringUpper = string.upper
local stringLower = string.lower
local stringFind = string.find
local stringSub = string.sub
local stringFormat = string.format
local tonumber = tonumber
local floor = math.floor
local stringSplit = strsplit

local rosterInfoDB = {}
local searchString = ''
local treeGroupFrame
local treeTable

--###################################
--   Helper Functions
--###################################

-- Sorts by primary > secondary
local function primarySecondarySort( a, b )
	local sortByPrimary = rosterInfoDB.sortByPrimary
	local sortBySecondary = rosterInfoDB.sortBySecondary
	local invertPrimary = rosterInfoDB.sortByPrimaryInvert
	local invertSecondary = rosterInfoDB.sortBySecondaryInvert
	if a and b then
		if a[sortByPrimary] == b[sortByPrimary] and sortByPrimary ~= sortBySecondary then
			if invertSecondary then
				return a[sortBySecondary] > b[sortBySecondary]
			else
				return a[sortBySecondary] < b[sortBySecondary]
			end
		else
			if invertPrimary then
				return a[sortByPrimary] > b[sortByPrimary]
			else
				return a[sortByPrimary] < b[sortByPrimary]
			end
		end
	end
end

-- Finds the charData for an alt and then sorts
local function primarySecondarySortAlts( a, b )
	local chars = A.db.global.guilds[I.guildName].chars
	return primarySecondarySort(chars[a], chars[b])
end

-- Word capitalizes a string (every word will start with a big letter)
local function wordCapitalize( str )
	return str:gsub("(%a)([%w_']*)", function( first, rest )
		return stringUpper(first)..stringLower(rest)
	end)
end

-- Takes a list of alts and returns it as a comma-seperated string
local function altsToString( altList, highlightOnline )
	local sortedAlts = altList
	sort(sortedAlts, primarySecondarySortAlts)
	local s = ''
	for _,v in ipairs(sortedAlts) do
		if A.db.global.guilds[I.guildName].chars[v].online and highlightOnline then
			if A.db.global.guilds[I.guildName].chars[v].status > 0 then
				-- AFK or DND
				v = LIGHTYELLOW_FONT_COLOR_CODE .. v .. FONT_COLOR_CODE_CLOSE
			else
				v = GREEN_FONT_COLOR_CODE .. v .. FONT_COLOR_CODE_CLOSE
			end
		end
		s = s .. v .. ', '
	end
	return stringSub(s, 1, -3)
end

-- Returns a hex version of the class color codes provided by blizz
local function formatClassColor( str, class )
	local class = stringUpper(class)
	local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
	if not classColor then return str end
	return "|c" .. stringFormat("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. str .. FONT_COLOR_CODE_CLOSE;
end

-- Returns a color coded Online/Offline (Status)
local function formatOnlineStatusText( online, status, shortStatus )
	local str = ''
	if online then
		str = GREEN_FONT_COLOR_CODE..L['Online']..FONT_COLOR_CODE_CLOSE
		
		if status > 0 then
			local statusStr = status == 1 and L['Away'] or L['DND']
			if shortStatus then -- Just change color of online
				str = LIGHTYELLOW_FONT_COLOR_CODE..L['Online']..FONT_COLOR_CODE_CLOSE
			else -- Add status after online
				str = str .. ' (' .. LIGHTYELLOW_FONT_COLOR_CODE .. statusStr .. FONT_COLOR_CODE_CLOSE .. ')'
			end
		end
	else
		str = RED_FONT_COLOR_CODE .. L['Offline'] .. FONT_COLOR_CODE_CLOSE
	end

	return str
end

-- Auto complete words
local function autoCompleteCharData( str, targetAttr, strModFunc )
	local chars = A.db.global.guilds[I.guildName].chars
	
	-- 2 or less is probably not enough to find
	if #str <= 2 then return str end

	local searchStr = strModFunc(str)
	local searchStrLen = #searchStr
	local matches = {}

	for _, char in pairs(chars) do		
		if stringSub(char[targetAttr], 1, searchStrLen) == searchStr then
			tableInsert(matches, char[targetAttr])
		end
	end

	if #matches == 1 then
		return matches[1]
	end
	return str
end

-- Handles autocompletion for Main input EditText
function handleAutoCompleteEditText( c, e, value )
	local useAutoComplete = A.db.global.settings.GUI.useAutoComplete
	local prevText = c:GetUserData('prevText')

	c:SetUserData('prevText', value)
	
	if not useAutoComplete then return end
	if c:GetUserData('isAutoCompleting') then return end

	-- Only autocomplete if we are writing, not when erasing
	if #value > #prevText then
		c:SetUserData('isAutoCompleting', true)
		local aCResult = autoCompleteCharData(value, 'name', wordCapitalize)
		
		if aCResult ~= value then -- We found a match
			c:SetText(aCResult)
		end
		
		c:SetUserData('isAutoCompleting', false)
	end
end

local function round(num, idp)
	local mult = 10^(idp or 0)
	return floor(num * mult + 0.5) / mult
end

-- formats dps, 1000+ into k
local function formatDPS( number )
	if type(number) ~= "number" then return 0 end
	if number > 1000 then
		return "" .. round(number/1000, 1) .. "k"
	else
		return "" .. number
	end
end

-- unformats dps, 1k -> 1000
local function unformatDPS( dpsStr )
	dpsStr = stringUpper(dpsStr)
	if stringFind(dpsStr, "K") ~= nil then
		local dps = tonumber( stringSub(dpsStr, 1, stringFind(dpsStr, "K")-1) )
		return dps and dps*1000 or 0
	else
		return tonumber(dpsStr)
	end
end

--###################################
--   Main Area (One char)
--###################################

-- Draw the main area when a character is selected
local function drawMainTreeArea( treeContainer, charName )
	-- Request update of GuildRoster
	GuildRoster()

	local charData = A.db.global.guilds[I.guildName].chars[charName]
	local classColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[charData.class]
	
	treeContainer:ReleaseChildren()
	treeContainer:SetLayout("Fill")

	local container
	do -- Add an inner scrolling container
		local scrollContainer = AceGUI:Create("ScrollFrame")
		scrollContainer:SetLayout("Flow")
		scrollContainer:SetFullWidth(true)
		treeContainer:AddChild(scrollContainer)

		-- The scroll frame should be the container
		container = scrollContainer
	end
	

	do -- Header and send player (sync)
		-- Rank Name (level level)
		local headerText = stringFormat('%s %s (%s %d)', charData.rank, formatClassColor(charData.name, charData.class), L['Level'], charData.level)
		local headerLabel = AceGUI:Create("Label")
		headerLabel:SetFontObject(SystemFont_Large)
		headerLabel:SetText(headerText)
		headerLabel:SetRelativeWidth(0.7)
		container:AddChild(headerLabel)

		local sendBtn = AceGUI:Create("Button")
		sendBtn:SetText(L['Share Char'])
		sendBtn:SetDisabled( not A.db.global.settings.sync.enabled )
		sendBtn:SetRelativeWidth(0.3)
		sendBtn:SetCallback('OnClick', function(container, event)
			A.sync.char:SendChar(charData.name)
		end)
		container:AddChild(sendBtn)
	end
	
	do -- SubHeader
		-- Zone info
		local headerText = formatOnlineStatusText(charData.online, charData.status)
		local zone = YELLOW_FONT_COLOR_CODE .. (charData.zone and charData.zone or "N/A") .. FONT_COLOR_CODE_CLOSE
		if charData.online then
			headerText = headerText .. ' - ' .. L['Currently in'] .. ' ' .. zone .. '.'
		else
			local offFor = charData.offlineFor
			headerText = headerText .. ' - ' .. L['Last seen in'] .. ' ' .. zone
			
			if offFor.years and offFor.years > 0 then
				headerText = headerText .. ', ' .. offFor.years .. ' ' .. (offFor.years>1 and L['years'] or L['year']) .. ' ' .. L['ago'] .. '.'
			elseif offFor.months and offFor.months > 0 then
				headerText = headerText .. ', ' .. offFor.months .. ' ' .. (offFor.months>1 and L['months'] or L['month']) .. ' ' .. L['ago'] .. '.'
			elseif offFor.days and  offFor.days > 0 then
				headerText = headerText .. ', ' .. offFor.days .. ' ' .. (offFor.days>1 and L['days'] or L['day']) .. ' ' .. L['ago'] .. '.'
			elseif offFor.hours and offFor.hours > 0 then
				headerText = headerText .. ', ' .. offFor.hours .. ' ' .. (offFor.hours>1 and L['hours'] or L['hour']) .. ' ' .. L['ago'] .. '.'
			else
				headerText = headerText .. ', ' .. L['less than an hour ago']
			end
		end

		local headerLabel = AceGUI:Create("Label")
		headerLabel:SetFontObject(SystemFont_Med1)
		headerLabel:SetText(headerText)
		headerLabel:SetFullWidth(true)
		container:AddChild(headerLabel)
	end

	do -- Whisper/inv buttons
		do -- Whisper player (main/alt that is online)
			local whisperBtn = AceGUI:Create("Button")
			whisperBtn:SetText(WHISPER .. ' ' .. PLAYER)
			whisperBtn:SetRelativeWidth(0.5)
			whisperBtn:SetCallback('OnClick', function(container, event)
				local whispTo = A:FindPlayerChar(charData.name, 'online', 1)
				if whispTo then
					SetItemRef( "player:"..whispTo, ("|Hplayer:%1$s|h[%1$s]|h"):format(whispTo), "LeftButton" )
				end
			end)
			container:AddChild(whisperBtn)
		end

		do -- Invites player (main/alt that is online)
			local inviteBtn = AceGUI:Create("Button")
			inviteBtn:SetText(L['Invite'] .. ' ' .. PLAYER)
			inviteBtn:SetRelativeWidth(0.5)
			inviteBtn:SetCallback('OnClick', function(container, event)
				local invWho = A:FindPlayerChar(charData.name, 'online', 1)
				if invWho then
					InviteUnit(invWho)
				end
			end)
			container:AddChild(inviteBtn)
		end
	end

	do -- General info container
		generalInfoContainer = AceGUI:Create("InlineGroup")
		generalInfoContainer:SetLayout("Flow")
		generalInfoContainer:SetTitle('')
		generalInfoContainer:SetFullWidth(true)
		container:AddChild(generalInfoContainer)

		do -- Main or alt editbox
			-- If char doesn't have any alts, only then can a main be choosen.
			if charData.alts == nil or #charData.alts == 0 then
				local label = AceGUI:Create("InteractiveLabel")
				label:SetText(L['Main'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)
				
				-- Tooltip
				label:SetCallback("OnEnter", function()
					A.GUI:ShowTooltip(L['Name of this character\'s main.']) 
				end)
				label:SetCallback("OnLeave", A.GUI.HideTooltip)

				local editBox = AceGUI:Create("EditBox")
				editBox:SetText(charData.main)
				editBox:SetMaxLetters(12)
				editBox:SetRelativeWidth(0.7)
				editBox:SetCallback("OnEnterPressed", function( c, e, value ) 
					A:ChangeCharMain(charData.name, value) -- Change main to value
					c:SetText(charData.main)
					c:ClearFocus()
					A.GUI.tabs.rosterInfo:GenerateTreeStructure() -- Update tree
				end)
				
				-- AutoComplete
				editBox:SetUserData('prevText', editBox:GetText())
				editBox:SetUserData('isAutoCompleting', false)
				editBox:SetCallback("OnTextChanged", handleAutoCompleteEditText )
				
				generalInfoContainer:AddChild(editBox)
			else -- If the char is a main, show alts but don't allow editing.
				local label = AceGUI:Create("InteractiveLabel")
				label:SetText(L['Alts'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				-- Tooltip
				label:SetCallback("OnEnter", function()
					A.GUI:ShowTooltip(L['The character\'s alts. Edit the alts\' main-value to change this.']) 
				end)
				label:SetCallback("OnLeave", A.GUI.HideTooltip)

				local altsLabel = AceGUI:Create("Label")
				altsLabel:SetText('  ' .. altsToString(charData.alts, true))
				altsLabel:SetRelativeWidth(0.7)
				generalInfoContainer:AddChild(altsLabel)
			end
		end

		do -- Main/Offspec
			local label = AceGUI:Create("InteractiveLabel")
			label:SetText(L['Main Spec/Off Spec'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			-- Tooltip
			label:SetCallback("OnEnter", function()
				A.GUI:ShowTooltip(L['The character\'s main spec and off spec.']) 
			end)
			label:SetCallback("OnLeave", A.GUI.HideTooltip)

			local class = stringUpper(charData.class)
			local charMSVal = charData.mainSpec
			local charOSVal = charData.offSpec
			local charMSText = I.classSpecDropdownList[class][charMSVal]
			local charOSText = I.classSpecDropdownList[class][charOSVal]

			local mainSpec = AceGUI:Create("Dropdown")
			mainSpec:SetList(I.classSpecDropdownList[class], I.classSpecDropdownListOrder[class])
			mainSpec:SetText(charMSText)
			mainSpec:SetValue(charMSVal)
			mainSpec:SetRelativeWidth(0.35)
			mainSpec:SetCallback("OnValueChanged", function(container, event, val)
				charData.mainSpec = val
			end)
			generalInfoContainer:AddChild(mainSpec)

			local offSpec = AceGUI:Create("Dropdown")
			offSpec:SetList(I.classSpecDropdownList[class], I.classSpecDropdownListOrder[class])
			offSpec:SetText(charOSText)
			offSpec:SetValue(charOSVal)
			offSpec:SetRelativeWidth(0.35)
			offSpec:SetCallback("OnValueChanged", function(container, event, val)
				charData.offSpec = val
			end)
			generalInfoContainer:AddChild(offSpec)
		end

		do -- DPS for main/offspec
			local label = AceGUI:Create("InteractiveLabel")
			label:SetText(L['Main Spec/Off Spec DPS'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			-- Tooltip
			label:SetCallback("OnEnter", function()
				A.GUI:ShowTooltip(L['The character\'s DPS in main spec and off spec.']) 
			end)
			label:SetCallback("OnLeave", A.GUI.HideTooltip)


			local charMSRole = GetSpecializationRoleByID(charData.mainSpec)
			local charOSRole = GetSpecializationRoleByID(charData.offSpec)
			local MSNoDPS = (not charMSRole or charMSRole == "HEALER")
			local OSNoDPS = (not charOSRole or charOSRole == "HEALER")

			local MSEditBox = AceGUI:Create("EditBox")
			MSEditBox:SetText(MSNoDPS and "---" or formatDPS(charData.mainSpecDPS) )
			MSEditBox:SetDisabled(MSNoDPS)
			MSEditBox:SetRelativeWidth(0.35)
			MSEditBox:SetCallback("OnEnterPressed", function(container, event, val)
				val = unformatDPS( val )
				charData.mainSpecDPS = val
				MSEditBox:SetText( formatDPS(val) )
			end)
			generalInfoContainer:AddChild(MSEditBox)

			local OSEditBox = AceGUI:Create("EditBox")
			OSEditBox:SetText( OSNoDPS and "---" or formatDPS(charData.offSpecDPS) )
			OSEditBox:SetDisabled(OSNoDPS)
			OSEditBox:SetRelativeWidth(0.35)
			OSEditBox:SetCallback("OnEnterPressed", function(container, event, val)
				val = unformatDPS( val )
				charData.offSpecDPS = val
				OSEditBox:SetText( formatDPS(val) )
			end)
			generalInfoContainer:AddChild(OSEditBox)

		end

		do -- Guild Note
			local label = AceGUI:Create("InteractiveLabel")
			label:SetText(L['Guild Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			-- Tooltip
			label:SetCallback("OnEnter", function()
				A.GUI:ShowTooltip(L['The guild note for the character.']) 
			end)
			label:SetCallback("OnLeave", A.GUI.HideTooltip)

			local editBox = AceGUI:Create("EditBox")
			editBox:SetText(charData.note)
			editBox:SetDisabled(not I.canEditPublicNote)
			editBox:SetMaxLetters(31)
			editBox:SetRelativeWidth(0.7)
			local index = charData.guildIndex
			editBox:SetCallback("OnEnterPressed", function(container, event, val)
				if index ~= -1 then GuildRosterSetPublicNote(index, val) end
			end)
			generalInfoContainer:AddChild(editBox)
		end

		do -- Officer Note
			local label = AceGUI:Create("InteractiveLabel")
			label:SetText(L['Officer Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			-- Tooltip
			label:SetCallback("OnEnter", function()
				A.GUI:ShowTooltip(L['The officer note for the character.']) 
			end)
			label:SetCallback("OnLeave", A.GUI.HideTooltip)

			local editBox = AceGUI:Create("EditBox")
			editBox:SetText(charData.officerNote)
			editBox:SetDisabled(not I.canEditOfficerNote)
			editBox:SetMaxLetters(31)
			editBox:SetRelativeWidth(0.7)
			local index = charData.guildIndex
			editBox:SetCallback("OnEnterPressed", function(container, event, val)
					if index ~= -1 then GuildRosterSetOfficerNote(index, val) end
				end)
			generalInfoContainer:AddChild(editBox)
		end

		do -- Private Note
			local label = AceGUI:Create("InteractiveLabel")
			label:SetText(L['Private Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			-- Tooltip
			label:SetCallback("OnEnter", function()
				A.GUI:ShowTooltip(L['Your own note for the character. This note is never shared.']) 
			end)
			label:SetCallback("OnLeave", A.GUI.HideTooltip)


			local editBox = AceGUI:Create("EditBox")
			editBox:SetText(charData.privateNote)
			editBox:SetMaxLetters(300)
			editBox:SetRelativeWidth(0.7)
			editBox:SetCallback("OnTextChanged", function(container, event, val)
					charData.privateNote = val
				end)
			generalInfoContainer:AddChild(editBox)
		end

		do -- Make main button
			if charData.main ~= nil then -- Make main (only if char is an alr)
				local label = AceGUI:Create("InteractiveLabel")
				label:SetText(L['Roster actions'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				-- Tooltip
				label:SetCallback("OnEnter", function()
					A.GUI:ShowTooltip({
						L['Action that alters the addon\'s guild roster database.'],
						{ 
							text = L[' * Make Main - Sets the selected character as the player\'s main character.'],
							color = {r = 0, g = 0.5, b = 1}
						}
					}) 
				end)
				label:SetCallback("OnLeave", A.GUI.HideTooltip)

				
				local makeMainBtn = AceGUI:Create("Button")
				makeMainBtn:SetText(L['Make Main'])
				makeMainBtn:SetRelativeWidth(0.35)
				makeMainBtn:SetCallback('OnClick', function(container, event)
					A:SetMainChar( charName )
					drawMainTreeArea( treeContainer, charName )
					A.GUI.tabs.rosterInfo:GenerateTreeStructure()
				end)
				generalInfoContainer:AddChild(makeMainBtn)

				local placeholder = AceGUI:Create("Label")
				placeholder:SetRelativeWidth(0.35)
				generalInfoContainer:AddChild(placeholder)
			end
		end

	end	

	-- Refresh the scrollFrame after all childs are loaded
	container:DoLayout()
end


--###################################
--   Tree Container (list of chars)
--###################################

-- Generates the tree element, alts under mains + sorting.
function A.GUI.tabs.rosterInfo:GenerateTreeStructure()
	-- Only if our frame is open
	if A.GUI.mainFrame == nil then return end

	-- And only if we have a guild
	if not I.hasGuild then return end

	local isSearching = (searchString ~= '') and true or false
	searchString = isSearching and stringUpper(searchString) or ''

	-- Sorting
	-- Needs to be numeric keys to sort
	local i, chars = 1, {}
	for _, charData in pairs(A.db.global.guilds[I.guildName].chars) do
		chars[i] = charData
		i = i+1
	end

	-- Sort by primary > secondary
	sort(chars, primarySecondarySort)

	-- Generate the tree
	treeTable = {}
	for _, charData in ipairs(chars) do
		-- Used for main coloring when online alts
		local mainHasAltOnline = false
		-- Also used later for main coloring by alt status
		local mainHasAltStatus = ''

		-- MainChar list-item
		local charEntry = {
			value = charData.name,
			text = formatClassColor(charData.name, charData.class) .. 
					(charData.online and ' - ' .. formatOnlineStatusText(true, charData.status, true) or ''),
			children = nil,
		}

		-- Alts, below MainChar
		if charData.alts ~= nil and #charData.alts >= 1 then
			local alts = charData.alts
			-- Sort by primary > secondary
			sort(alts, primarySecondarySortAlts)

			charEntry.children = {}
			for _, altName in ipairs(alts) do
				local alt = A.db.global.guilds[I.guildName].chars[altName]			
				local altEntry = {
					value = alt.name, 
					text = formatClassColor(alt.name, alt.class) .. 
							(alt.online and ' - ' .. formatOnlineStatusText(true, alt.status, true) or ''),
				}

				tableInsert(charEntry.children, altEntry)
				mainHasAltOnline = (alt.online and true or mainHasAltOnline)
				mainHasAltStatus = (alt.online and alt.status or mainHasAltStatus)
			end
		end

		-- Filter checking
		local passedFilters = (function()
			-- Some errorChecking
			if charData.name == '' then return false end

			-- showOnlyMaxLvl
			if (rosterInfoDB.showOnlyMaxLvl and charData.level < 90) then return false end
					
			-- Searching
			if isSearching then
				-- HideOffline, when searching alt-main relations are disregarded
				if ( rosterInfoDB.hideOffline and not(charData.online) ) then return false end
				-- SearchString in name
				return ( stringFind(stringUpper(charData.name), searchString) ~= nil )
			end

			-- hideOffline, include online status of adds
			if ( rosterInfoDB.hideOffline and not(charData.online or mainHasAltOnline ) ) then return false end

			-- Only display mains, alts are grouped
			if charData.main == nil then return true end
		end)()

		if passedFilters then
			if isSearching then
				-- Don't want alt sub-items when searching
				charEntry.children = nil
			else
				-- Update main list-item with online color of alt
				local showCharOnline = charData.online or mainHasAltOnline
				local showCharStatus = mainHasAltStatus ~= '' and mainHasAltStatus or charData.status
				charEntry.text = formatClassColor(charData.name, charData.class) 
				if showCharOnline then
					charEntry.text = charEntry.text .. ' - ' .. formatOnlineStatusText(true, showCharStatus, true)
					if mainHasAltOnline then
						charEntry.text = charEntry.text .. ' (A)'
					end
				end
			end

			tableInsert(treeTable, charEntry)
		end
	end

	treeGroupFrame:SetTree(treeTable)
end

-- Draw the tab
function A.GUI.tabs.rosterInfo:DrawTab(container)
	-- Only if our frame is open
	if A.GUI.mainFrame == nil then return end

	rosterInfoDB = A.db.global.core.GUI.rosterInfo

	searchString = ''

	do -- Setup the tree element
		local treeG = AceGUI:Create("TreeGroup")
		treeG:SetFullWidth(true)
		treeG:SetFullHeight(true)
		treeG:EnableButtonTooltips(false)
		treeG:SetTree({})
		treeGroupFrame = treeG
	end
	

	do -- Search EditBox
		local searchTextbox = AceGUI:Create("EditBox")
		searchTextbox:SetLabel(L['Search'])
		searchTextbox:SetText()
		searchTextbox:DisableButton(true)
		searchTextbox:SetCallback("OnTextChanged", function(container, event, val)
				searchString = val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(searchTextbox)
	end
	
	do -- Dropdown for primary sorting
		local selPrim = rosterInfoDB.sortByPrimaryInvert and 'INVERT'..rosterInfoDB.sortByPrimary or rosterInfoDB.sortByPrimary
		local primarySortDropdown = AceGUI:Create("Dropdown")
		primarySortDropdown:SetLabel(L['Primary sort by'])
		primarySortDropdown:SetValue(selPrim)
		primarySortDropdown:SetText(I.guildSortableBy[selPrim])
		primarySortDropdown:SetList(I.guildSortableBy, I.guidSortableByOrder)
		primarySortDropdown:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.sortByPrimaryInvert = stringFind(val, 'INVERT') and true or false
				rosterInfoDB.sortByPrimary = stringFind(val, 'INVERT') and stringSub(val, 7) or val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(primarySortDropdown)
	end

	do -- Dropdown for secondary sorting
		local selSec = rosterInfoDB.sortBySecondaryInvert and 'INVERT'..rosterInfoDB.sortBySecondary or rosterInfoDB.sortBySecondary
		local secondarySortDropdown = AceGUI:Create("Dropdown")
		secondarySortDropdown:SetLabel(L['Secondary sort by'])
		secondarySortDropdown:SetValue(selSec)
		secondarySortDropdown:SetText(I.guildSortableBy[selSec])
		secondarySortDropdown:SetList(I.guildSortableBy, I.guidSortableByOrder)
		secondarySortDropdown:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.sortBySecondaryInvert = stringFind(val, 'INVERT') and true or false
				rosterInfoDB.sortBySecondary = stringFind(val, 'INVERT') and stringSub(val, 7) or val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(secondarySortDropdown)
	end

	do -- Hide below 85 checkbox
		local onlyMaxCheckbox = AceGUI:Create("CheckBox")
		onlyMaxCheckbox:SetLabel(L['Only 90s'])
		onlyMaxCheckbox:SetValue(rosterInfoDB.showOnlyMaxLvl)
		onlyMaxCheckbox:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.showOnlyMaxLvl = val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(onlyMaxCheckbox)	
	end

	do -- Hide offline checkbox
		local hideOfflineCheckbox = AceGUI:Create("CheckBox")
		hideOfflineCheckbox:SetLabel(L['Hide offline'])
		hideOfflineCheckbox:SetValue(rosterInfoDB.hideOffline)
		hideOfflineCheckbox:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.hideOffline = val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(hideOfflineCheckbox)	
	end

	-- Add the TreeGroup element
	container:AddChild(treeGroupFrame)

	treeGroupFrame:SetCallback("OnGroupSelected", function(container, event, group)
		local istringSubLvl = stringFind(group, "\001")
		local charName = istringSubLvl and stringSub(group, istringSubLvl+1) or group
		drawMainTreeArea(container, charName)
	end)
	
	-- Generate the tree for the TreeGroup
	A.GUI.tabs.rosterInfo:GenerateTreeStructure()
end

-- On roster update
function A.GUI.tabs.rosterInfo:OnRosterUpdate()
	if treeGroupFrame then
		self:GenerateTreeStructure()
	end
end
