local L,A,I = MOTOTracker.locale, MOTOTracker.addon, MOTOTracker.info
local AceGUI = LibStub("AceGUI-3.0")

local tIns = table.insert
local sUpper = string.upper
local sFind = string.find

-- Returns a hex version of the class color codes provided by blizz
local function formatClassColor( str, class )
	local class = sUpper(class)
	local classColor = RAID_CLASS_COLORS[class]
	return "|c" .. format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255) .. str .. FONT_COLOR_CODE_CLOSE;
end

-- Tab group drawers
local TGDraw = {}


--###################################
--	Roster Info tab
--###################################

local rosterInfoDB = {}
local searchString = ''

-- Generates the tree element, alts under mains + sorting.
local function rosterInfoGenTree( treeG )
	local isSearching = (searchString ~= '') and true or false
	searchString = isSearching and sUpper(searchString) or ''

	-- Sorting
	-- Needs to be numeric key to sort
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
		if isSearching then
			if sFind( sUpper(charData.name), searchString) ~= nil then
				if not(rosterInfoDB.showOnlyMaxLvl and charData.level < 85) then
					local charEntry = {
						value = charData.name,
						text = formatClassColor(charData.name, charData.class),
						children = nil,
					}
					tIns(tree, charEntry)
				end
			end
		else
			-- Only add an entry if not an alt (alts are added under mains)
			if charData.main == nil then
				if not(rosterInfoDB.showOnlyMaxLvl and charData.level < 85) then
					local charEntry = {
						value = charData.name,
						text = formatClassColor(charData.name, charData.class),
						children = nil,
					}

					-- If char doesn't have a main (is a main itself) and have alts
					if charData.main == nil and charData.alts ~= nil and rosterInfoDB.showAlts then
						charEntry.children = {}
						for _, alt in ipairs(charData.alts) do 
							tIns(charEntry.children, {
								value = alt.name, 
								text = formatClassColor(alt.name, alt.class)
							})
						end
					end
					tIns(tree, charEntry)

				end
			end
		end
	end

	treeG:SetTree(tree)
end

-- Draw the tab
TGDraw["rosterInfo"] = function(container)
	rosterInfoDB = A.db.global.core.GUI.rosterInfo

	do -- Setup the tree element
		treeG = AceGUI:Create("TreeGroup")
		treeG:SetTree(tree)
		treeG:SetFullWidth(true)
		treeG:SetFullHeight(true)
	end

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


	-- Add the TreeGroup element
	container:AddChild(treeG)

	local editbox = AceGUI:Create("EditBox")
	editbox:SetLabel("Insert text:")
	editbox:SetWidth(200)
	treeG:AddChild(editbox)

	treeG:SetCallback("OnGroupSelected", function(container, event, group)
		print(group)
		-- Saniera?Illier
	end)
	
	-- Generate the tree for the TreeGroup
	rosterInfoGenTree( treeG )
end


--###################################
--	Main Frame
--###################################

-- Callback function for OnGroupSelected
function SelectGroup(container, event, group)
	container:ReleaseChildren()
	if type(TGDraw[group]) == "function" then
		TGDraw[group]( container )
	end
end

-- Shows the main frame, also creates it if it doesn't exist yet.
function A:ShowMainFrame()
	-- No point in creating it before we want to show it
	-- And since it is realease on close we need to
	-- create it every time.
	self:CreateMainFrame()
	self.mainFrame:Show()
end

function A:CreateMainFrame()
	A.mainFrame = AceGUI:Create("Frame")
	local f = A.mainFrame
	
	-- Main frame settings
	f:Hide()
	f:SetTitle( format(L['MOTO Tracker, version: %s'], I.versionName) )
	f:SetLayout("Fill")
	f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

	if I.hasGuild then
		local numMembers = GetNumGuildMembers()
		f:SetStatusText(I.guildName .. ' - ' .. numMembers .. ' '.. L['Members'])
	else
		f:SetStatusText(L['<Not in a guild>'])
	end



	-- Create the TabGroup
	local tab = AceGUI:Create("TabGroup")
	tab:SetLayout("Flow")
	tab:SetTabs({
		{text=L['Roster Info'], value="rosterInfo"}, 
		{text=L['Something Else'], value="SomethingElse"} 
	})
	tab:SetCallback("OnGroupSelected", SelectGroup)
	tab:SelectTab("rosterInfo")

	f:AddChild(tab)
end

