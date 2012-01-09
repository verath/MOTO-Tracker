local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")

--###################################
--	Roster Info tab
--###################################
local tIns = table.insert
local tRemove = table.remove
local sUpper = string.upper
local sLower = string.lower
local sFind = string.find
local sSub = string.sub
local sFormat = string.format

local rosterInfoDB = {}
local searchString = ''
local treeGroupFrame

-- Sorts by primary > secondary
local function primarySecondarySort( a, b )
	local sortByPrimary = rosterInfoDB.sortByPrimary
	local sortBySecondary = rosterInfoDB.sortBySecondary
	if a and b then
		if a[sortByPrimary] == b[sortByPrimary] and sortByPrimary ~= sortBySecondary then
			return a[sortBySecondary] < b[sortBySecondary]
		else
			return a[sortByPrimary] < b[sortByPrimary]
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
		return sUpper(first)..sLower(rest)
	end)
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
		if sSub(char[targetAttr], 1, searchStrLen) == searchStr then
			tIns(matches, char[targetAttr])
		end
	end

	if #matches == 1 then
		return matches[1]
	end
	return str
end

-- Takes a list of alts and returns it as a comma-seperated string
local function altsToString( altList, highlightOnline )
	local sortedAlts = altList
	sort(sortedAlts, primarySecondarySortAlts)
	local s = ''
	for _,v in ipairs(sortedAlts) do
		if A.db.global.guilds[I.guildName].chars[v].online and highlightOnline then
			v = GREEN_FONT_COLOR_CODE .. v .. FONT_COLOR_CODE_CLOSE
		end
		s = s .. v .. ', '
	end
	return sSub(s, 1, -3)
end

-- Sets/updates a characters main and that main's alt table
local function changeMain( charData, newMainName )
	local currentMain = A.db.global.guilds[I.guildName].chars[charData.main]
	
	-- Remove alt from old main
	if currentMain and currentMain.alts then
		local newAltTable = {}
		for i = 1, #currentMain.alts do
			if currentMain.alts[i] ~= charData.name then
				tIns(newAltTable, currentMain.alts[i])
			end
		end
		currentMain.alts = newAltTable
	end
	
	-- Clear current main data
	charData.main = nil

	-- Validate new main
	local newMain = A.db.global.guilds[I.guildName].chars[newMainName]
	if newMain.name == '' then return end
	if newMain.main ~= nil then return end
	
	-- Set new main-alt data
	charData.main = newMainName
	if newMain.alts == nil then newMain.alts = {} end
	tIns(newMain.alts, charData.name)
end

-- Returns a hex version of the class color codes provided by blizz
local function formatClassColor( str, class )
	local class = sUpper(class)
	local classColor = RAID_CLASS_COLORS[class]
	if not classColor then return str end
	return "|c" .. sFormat("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. str .. FONT_COLOR_CODE_CLOSE;
end

-- Returns a color coded Online/Offline (Status)
local function formatOnlineStatusText( online, status )
	local str = ''
	if online ~= nil then
		str = GREEN_FONT_COLOR_CODE..L['Online']..FONT_COLOR_CODE_CLOSE
		if status and status ~= '' then
			str = str .. ' (' .. LIGHTYELLOW_FONT_COLOR_CODE .. status .. FONT_COLOR_CODE_CLOSE .. ')'
		end
	else
		str = RED_FONT_COLOR_CODE .. L['Offline'] .. FONT_COLOR_CODE_CLOSE
	end

	return str
end

-- Draw the main area when a character is selected
local function drawMainTreeArea( treeContainer, charName )
	local charData = A.db.global.guilds[I.guildName].chars[charName]
	local classColor = RAID_CLASS_COLORS[charData.class]

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
	

	do -- Header
		-- Rank Name (level level) - online/offline (status)
		local headerText = sFormat('%s %s (%s %d) - %s', charData.rank, formatClassColor(charData.name, charData.class), L['Level'], charData.level, formatOnlineStatusText(charData.online, charData.status))
		local headerLabel = AceGUI:Create("Label")
		headerLabel:SetFontObject(SystemFont_Large)
		headerLabel:SetText(headerText)
		headerLabel:SetFullWidth(true)
		container:AddChild(headerLabel)
	end
	
	do -- SubHeader
		-- Zone info
		local headerText = ''
		if charData.online then
			headerText = L['Currently in']
		else
			headerText = L['Last seen in']
		end
		headerText = headerText .. ': ' .. LIGHTYELLOW_FONT_COLOR_CODE .. charData.zone .. FONT_COLOR_CODE_CLOSE
		local headerLabel = AceGUI:Create("Label")
		headerLabel:SetFontObject(SystemFont_Med1)
		headerLabel:SetText(headerText)
		headerLabel:SetFullWidth(true)
		container:AddChild(headerLabel)
	end

	do -- General info container
		generalInfoContainer =  AceGUI:Create("InlineGroup")
		generalInfoContainer:SetLayout("Flow")
		generalInfoContainer:SetTitle('')
		generalInfoContainer:SetFullWidth(true)
		container:AddChild(generalInfoContainer)

		do -- Main or alt editbox
			-- If char doesn't have any alts, only then can a main be choosen.
			if charData.alts == nil or #charData.alts == 0 then
				local label = AceGUI:Create("Label")
				label:SetText(L['Main'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				local editBox = AceGUI:Create("EditBox")
				editBox:SetText(charData.main)
				editBox:SetMaxLetters(12)
				editBox:SetRelativeWidth(0.7)
				editBox:SetCallback("OnEnterPressed", function( c, e, value ) 
					changeMain(charData, value) -- Change main to value
					c:SetText(charData.main)
					A.GUI.tabs.rosterInfo:GenerateTreeStructure() -- Update tree
				end)
				editBox:DisableButton( A.db.global.settings.GUI.useAutoComplete )
				-- AutoComplete
				editBox:SetUserData('prevText', editBox:GetText())
				editBox:SetUserData('isAutoCompleting', false)
				editBox:SetCallback("OnTextChanged", function( c, e, value )
					local prevText = c:GetUserData('prevText')
					if not c:GetUserData('isAutoCompleting') then
						if A.db.global.settings.GUI.useAutoComplete and #value > #prevText then
							c:SetUserData('isAutoCompleting', true)
							local aCResult = autoCompleteCharData(value, 'name', wordCapitalize)
							if aCResult ~= value then 
								changeMain(charData, aCResult) -- Change main to value
								c:SetText(charData.main)
								c:ClearFocus()
								A.GUI.tabs.rosterInfo:GenerateTreeStructure() -- Update tree
							end
							c:SetUserData('isAutoCompleting', false)
						end
					end
					c:SetUserData('prevText', value)
				end)
				generalInfoContainer:AddChild(editBox)
			else -- If the char is a main, show alts but don't allow editing.
				local label = AceGUI:Create("Label")
				label:SetText(L['Alts'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				local editBox = AceGUI:Create("Label")
				editBox:SetText('  ' .. altsToString(charData.alts, true))
				--editBox:SetDisabled(true)
				editBox:SetRelativeWidth(0.7)
				generalInfoContainer:AddChild(editBox)
			end
		end

		do -- Guild Note
			local label = AceGUI:Create("Label")
			label:SetText(L['Guild Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

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
			local label = AceGUI:Create("Label")
			label:SetText(L['Officer Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

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
			local label = AceGUI:Create("Label")
			label:SetText(L['Private Note'] .. ':')
			label:SetRelativeWidth(0.3)
			generalInfoContainer:AddChild(label)

			local editBox = AceGUI:Create("MultiLineEditBox")
			editBox:SetText(charData.privateNote)
			editBox:SetNumLines(4)
			editBox:SetMaxLetters(300)
			editBox:SetRelativeWidth(0.7)
			editBox:DisableButton(true)
			editBox:SetLabel('')
			editBox:SetCallback("OnTextChanged", function(container, event, val)
					charData.privateNote = val
				end)
			generalInfoContainer:AddChild(editBox)
		end
	end	
end

-- Generates the tree element, alts under mains + sorting.
function A.GUI.tabs.rosterInfo:GenerateTreeStructure()
	local isSearching = (searchString ~= '') and true or false
	searchString = isSearching and sUpper(searchString) or ''

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
	tree = {}
	for _, charData in ipairs(chars) do
		-- Used for main coloring when online alts
		local mainHasAltOnline = false

		-- MainChar list-item
		local charEntry = {
			value = charData.name,
			text = formatClassColor(charData.name, charData.class) .. 
					(charData.online and ' - ' .. formatOnlineStatusText(true) or ''),
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
							(alt.online and ' - ' .. formatOnlineStatusText(true) or ''),
				}

				tIns(charEntry.children, altEntry)
				mainHasAltOnline = (alt.online and true or mainHasAltOnline)
			end
		end

		-- Filter checking
		local passedFilters = (function()
			-- Some errorChecking
			if charData.name == '' then return false end

			-- showOnlyMaxLvl
			if (rosterInfoDB.showOnlyMaxLvl and charData.level < 85) then return false end
					
			-- Searching
			if isSearching then
				-- HideOffline, when searching alt-main relations are disregarded
				if ( rosterInfoDB.hideOffline and not(charData.online) ) then return false end
				-- SearchString in name
				return ( sFind(sUpper(charData.name), searchString) ~= nil )
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
				charEntry.text = formatClassColor(charData.name, charData.class) .. (showCharOnline and ' - ' .. formatOnlineStatusText(true) or '')
			end

			tIns(tree, charEntry)
		end
	end

	treeGroupFrame:SetTree(tree)
end

-- Draw the tab
function A.GUI.tabs.rosterInfo:DrawTab(container)
	rosterInfoDB = A.db.global.core.GUI.rosterInfo

	searchString = ''

	do -- Setup the tree element
		treeG = AceGUI:Create("TreeGroup")
		treeG:SetTree(tree)
		treeG:SetFullWidth(true)
		treeG:SetFullHeight(true)
	end
	treeGroupFrame = treeG

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
		local primarySortDropdown = AceGUI:Create("Dropdown")
		primarySortDropdown:SetLabel(L['Primary sort by'])
		primarySortDropdown:SetValue(rosterInfoDB.sortByPrimary)
		primarySortDropdown:SetText(I.guildSortableBy[rosterInfoDB.sortByPrimary])
		primarySortDropdown:SetList(I.guildSortableBy)
		primarySortDropdown:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.sortByPrimary = val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(primarySortDropdown)
	end

	do -- Dropdown for secondary sorting
		local secondarySortDropdown = AceGUI:Create("Dropdown")
		secondarySortDropdown:SetLabel(L['Secondary sort by'])
		secondarySortDropdown:SetValue(rosterInfoDB.sortBySecondary)
		secondarySortDropdown:SetText(I.guildSortableBy[rosterInfoDB.sortBySecondary])
		secondarySortDropdown:SetList(I.guildSortableBy)
		secondarySortDropdown:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.sortBySecondary = val
				A.GUI.tabs.rosterInfo:GenerateTreeStructure()
			end)
		container:AddChild(secondarySortDropdown)
	end

	do -- Hide below 85 checkbox
		local onlyMaxCheckbox = AceGUI:Create("CheckBox")
		onlyMaxCheckbox:SetLabel(L['Only 85s'])
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
		local isSubLvl = sFind(group, "\001")
		local charName = isSubLvl and sSub(group, isSubLvl+1) or group
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
