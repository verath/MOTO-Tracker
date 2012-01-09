local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")

--###################################
--	Roster Info tab
--###################################
local tIns = table.insert
local tRemove = table.remove
local sUpper = string.upper
local sFind = string.find
local sSub = string.sub
local sFormat = string.format

local rosterInfoDB = {}
local searchString = ''

-- Returns a hex version of the class color codes provided by blizz
local function formatClassColor( str, class )
	local class = sUpper(class)
	local classColor = RAID_CLASS_COLORS[class]
	if not classColor then return str end
	return "|c" .. sFormat("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. str .. FONT_COLOR_CODE_CLOSE;
end

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

	do -- General info container
		generalInfoContainer =  AceGUI:Create("InlineGroup")
		generalInfoContainer:SetLayout("Flow")
		generalInfoContainer:SetTitle('')
		generalInfoContainer:SetFullWidth(true)
		container:AddChild(generalInfoContainer)

		do -- Main or alt editbox
			-- TODO: More UI help
			local function changeMain(container, event, val)
				local currentMain = A.db.global.guilds[I.guildName].chars[charData.main]
				
				-- Remove alt from old main
				if currentMain and currentMain.alts then
					for i, v in ipairs(currentMain.alts) do
						if v == charData.name then
							currentMain.alts[i] = nil
						end
					end
				end
				
				-- Clear current main data
				charData.main = nil

				-- Validate new main
				local newMain = A.db.global.guilds[I.guildName].chars[val]
				if newMain.name == '' then return end
				if newMain.main ~= nil then return end
				
				-- Set new main-alt data
				charData.main = val
				if newMain.alts == nil then newMain.alts = {} end
				tIns(newMain.alts, charData.name)
			end

			local function altsToString( altList )
				local s = ''
				for _,v in ipairs(altList) do 
					s = s .. ' ' .. v .. ','
				end
				return sSub(s, 1, -2)
			end

			if charData.alts == nil or #charData.alts == 0 then
				local label = AceGUI:Create("Label")
				label:SetText(L['Main'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				local editBox = AceGUI:Create("EditBox")
				editBox:SetText(charData.main)
				--editBox:SetDisabled(not I.canEditPublicNote)
				editBox:SetMaxLetters(12)
				editBox:SetRelativeWidth(0.7)
				editBox:SetCallback("OnEnterPressed", changeMain)
				generalInfoContainer:AddChild(editBox)
			else
				local label = AceGUI:Create("Label")
				label:SetText(L['Alts'] .. ':')
				label:SetRelativeWidth(0.3)
				generalInfoContainer:AddChild(label)

				local editBox = AceGUI:Create("EditBox")
				editBox:SetText(altsToString(charData.alts))
				editBox:SetDisabled(true)
				editBox:SetRelativeWidth(0.7)
				editBox:SetCallback("OnEnterPressed", changeMain)
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
local function rosterInfoGenTree( treeG )
	local isSearching = (searchString ~= '') and true or false
	searchString = isSearching and sUpper(searchString) or ''

	-- Sorting
	-- Needs to be numeric keys to sort
	local i, chars = 1, {}
	for charName, charData in pairs(A.db.global.guilds[I.guildName].chars) do
		chars[i] = charData
		i = i+1
	end

	-- Sort by primary > secondary
	local sortByPrimary = rosterInfoDB.sortByPrimary
	local sortBySecondary = rosterInfoDB.sortBySecondary
	sort(chars, function(a, b)
		if a and b then
			if a[sortByPrimary] == b[sortByPrimary] and sortByPrimary ~= sortBySecondary then
				return a[sortBySecondary] < b[sortBySecondary]
			else
				return a[sortByPrimary] < b[sortByPrimary]
			end
		end
	end)

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
			charEntry.children = {}
			for _, altName in ipairs(charData.alts) do
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

	treeG:SetTree(tree)
end

-- Draw the tab
local treeGroupFrame
function A.GUI.tabs.rosterInfo:DrawTab(container)
	rosterInfoDB = A.db.global.core.GUI.rosterInfo

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
		searchTextbox:SetText('')
		searchTextbox:DisableButton(true)
		searchTextbox:SetCallback("OnTextChanged", function(container, event, val)
				searchString = val
				rosterInfoGenTree( treeG )
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
				rosterInfoGenTree( treeG )
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
				rosterInfoGenTree( treeG )
			end)
		container:AddChild(secondarySortDropdown)
	end

	do -- Hide below 85 checkbox
		local onlyMaxCheckbox = AceGUI:Create("CheckBox")
		onlyMaxCheckbox:SetLabel(L['Only 85s'])
		onlyMaxCheckbox:SetValue(rosterInfoDB.showOnlyMaxLvl)
		onlyMaxCheckbox:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.showOnlyMaxLvl = val
				rosterInfoGenTree( treeG )
			end)
		container:AddChild(onlyMaxCheckbox)	
	end

	do -- Hide offline checkbox
		local hideOfflineCheckbox = AceGUI:Create("CheckBox")
		hideOfflineCheckbox:SetLabel(L['Hide offline'])
		hideOfflineCheckbox:SetValue(rosterInfoDB.hideOffline)
		hideOfflineCheckbox:SetCallback("OnValueChanged", function(container, event, val)
				rosterInfoDB.hideOffline = val
				rosterInfoGenTree( treeG )
			end)
		container:AddChild(hideOfflineCheckbox)	
	end

	-- Add the TreeGroup element
	container:AddChild(treeG)

	treeG:SetCallback("OnGroupSelected", function(container, event, group)
		local isSubLvl = sFind(group, "\001")
		local charName = isSubLvl and sSub(group, isSubLvl+1) or group
		drawMainTreeArea(container, charName)
	end)
	
	-- Generate the tree for the TreeGroup
	rosterInfoGenTree( treeG )
end

-- On roster update
function A.GUI.tabs.rosterInfo:OnRosterUpdate()
	if treeGroupFrame then
		rosterInfoGenTree(treeGroupFrame)
	end
end
