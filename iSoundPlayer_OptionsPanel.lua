-- ═════════════════════════
-- ██╗ ███████╗ ██████╗
-- ██║ ██╔════╝ ██╔══██╗
-- ██║ ███████╗ ██████╔╝
-- ██║ ╚════██║ ██╔═══╝
-- ██║ ███████║ ██║
-- ╚═╝ ╚══════╝ ╚═╝
-- ═════════════════════════

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                      Options Panel (Custom Standalone Frame)                  │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local addonName, iSP = ...
local iconPath = iSP.AddonPath .. "Images\\Icons\\Logo_iSP.blp"

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                 │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local function CreateSectionHeader(parent, text, yOffset)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    header:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.6)

    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(1)
    accent:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    accent:SetColorTexture(1, 0.59, 0.09, 0.4)

    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", header, "LEFT", 8, 0)
    label:SetText(text)

    return header, yOffset - 28
end

local function CreateSettingsCheckbox(parent, label, descText, yOffset, settingKey, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    cb.Text:SetText(label)
    cb.Text:SetFontObject(GameFontHighlight)

    if getFunc then
        cb:SetChecked(getFunc())
    else
        cb:SetChecked(iSPSettings[settingKey])
    end

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        if setFunc then
            setFunc(checked)
        else
            iSPSettings[settingKey] = checked
        end
    end)

    local nextY = yOffset - 22
    if descText and descText ~= "" then
        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 48, nextY)
        desc:SetWidth(480)
        desc:SetJustifyH("LEFT")
        desc:SetText(descText)
        local height = desc:GetStringHeight()
        if height < 12 then height = 12 end
        nextY = nextY - height - 6
    end

    return cb, nextY
end

local function CreateSettingsButton(parent, text, width, yOffset, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)
    return btn, yOffset - 34
end

local function CreateInfoText(parent, text, yOffset, fontObj)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObj or "GameFontHighlight")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    fs:SetWidth(500)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    local height = fs:GetStringHeight()
    if height < 14 then height = 14 end
    return fs, yOffset - height - 4
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                            Static Popup Dialogs                               │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

StaticPopupDialogs["ISP_RESET_SETTINGS"] = {
    text = "Reset all settings to defaults?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        for key, value in pairs(iSP.SettingsDefault) do
            if key ~= "MinimapButton" then
                iSPSettings[key] = type(value) == "table" and CopyTable(value) or value
            end
        end
        print(iSP.L["PrintPrefix"] .. iSP.Colors.Green .. "Settings reset to defaults!")
        if iSP.RefreshSettingsPanel then
            iSP:RefreshSettingsPanel()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                           Create Options Panel                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

function iSP:CreateOptionsPanel()

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                        Main Frame                             │
    -- ╰───────────────────────────────────────────────────────────────╯
    local settingsFrame = iSP:CreateiSPStyleFrame(UIParent, 750, 520, {"CENTER", UIParent, "CENTER"}, "iSPSettingsFrame")
    settingsFrame:Hide()
    settingsFrame:EnableMouse(true)
    settingsFrame:SetMovable(true)
    settingsFrame:SetFrameStrata("HIGH")
    settingsFrame:SetClampedToScreen(true)
    settingsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    settingsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
    iSP.SettingsFrame = settingsFrame

    -- Shadow
    local shadow = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", settingsFrame, -1, 1)
    shadow:SetPoint("BOTTOMRIGHT", settingsFrame, 1, -1)
    shadow:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 5,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- Drag
    settingsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
    settingsFrame:RegisterForDrag("LeftButton", "RightButton")

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                         Title Bar                             │
    -- ╰───────────────────────────────────────────────────────────────╯
    local titleBar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    titleBar:SetHeight(31)
    titleBar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

    local titleIcon = titleBar:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(20, 20)
    titleIcon:SetPoint("LEFT", titleBar, "LEFT", 12, 0)
    titleIcon:SetTexture(iconPath)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleText:SetText(iSP.Colors.iSP .. "iSoundPlayer" .. iSP.Colors.Green .. " v" .. iSP.Version)

    local closeButton = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() iSP:SettingsClose() end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                     Sidebar Navigation                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    local sidebarWidth = 150

    local sidebar = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    sidebar:SetWidth(sidebarWidth)
    sidebar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -35)
    sidebar:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 10, 10)
    sidebar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    sidebar:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    sidebar:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Content Area                            │
    -- ╰───────────────────────────────────────────────────────────────╯
    local contentArea = CreateFrame("Frame", nil, settingsFrame, "BackdropTemplate")
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 6, 0)
    contentArea:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -10, 10)
    contentArea:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    contentArea:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    contentArea:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

    -- Tab content frames with scroll
    local scrollFrames = {}
    local scrollChildren = {}
    local contentWidth = 550

    local function CreateTabContent()
        local container = CreateFrame("Frame", nil, contentArea)
        container:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 5, -5)
        container:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -5, 5)
        container:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -22, 0)

        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetWidth(contentWidth)
        scrollChild:SetHeight(1)
        scrollFrame:SetScrollChild(scrollChild)

        container:EnableMouseWheel(true)
        container:SetScript("OnMouseWheel", function(_, delta)
            local current = scrollFrame:GetVerticalScroll()
            local maxScroll = scrollChild:GetHeight() - scrollFrame:GetHeight()
            if maxScroll < 0 then maxScroll = 0 end
            local newScroll = current - (delta * 30)
            if newScroll < 0 then newScroll = 0 end
            if newScroll > maxScroll then newScroll = maxScroll end
            scrollFrame:SetVerticalScroll(newScroll)
        end)

        table.insert(scrollFrames, scrollFrame)
        table.insert(scrollChildren, scrollChild)

        return container, scrollChild
    end

    local generalContainer, generalContent = CreateTabContent()
    local soundsContainer, soundsContent = CreateTabContent()
    local triggersContainer, triggersContent = CreateTabContent()
    local aboutContainer, aboutContent = CreateTabContent()

    -- ALWAYS create addon tabs (addon detection happens on window show)
    local iNIFContainer, iNIFContent = CreateTabContent()
    local iWRContainer, iWRContent = CreateTabContent()

    local tabContents = {generalContainer, soundsContainer, triggersContainer, aboutContainer, iNIFContainer, iWRContainer}
    local sidebarButtons = {}
    local activeIndex = 1

    local function ShowTab(index)
        activeIndex = index
        for i, content in ipairs(tabContents) do
            content:SetShown(i == index)
        end
        for i, btn in ipairs(sidebarButtons) do
            if i == index then
                btn.bg:SetColorTexture(1, 0.59, 0.09, 0.25)
                btn.text:SetFontObject(GameFontHighlight)
            else
                btn.bg:SetColorTexture(0, 0, 0, 0)
                btn.text:SetFontObject(GameFontNormal)
            end
        end
    end

    -- Build sidebar with section headers and tabs (iNIF/iWR style)
    local sidebarItems = {
        {type = "header", label = iSP.Colors.iSP .. "iSoundPlayer|r"},
        {type = "tab", label = "General", index = 1},
        {type = "tab", label = "Sounds", index = 2},
        {type = "tab", label = "Triggers", index = 3},
        {type = "tab", label = "About", index = 4},
        {type = "header", label = iSP.Colors.iSP .. "Other Addons|r"},  -- Always show
        {type = "tab", label = "iNeedIfYouNeed", index = 5},  -- Always show
        {type = "tab", label = "iWillRemember", index = 6},  -- Always show
    }

    local sidebarY = -6
    for _, item in ipairs(sidebarItems) do
        if item.type == "header" then
            -- Create section header text
            local headerText = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerText:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, sidebarY - 2)
            headerText:SetText(item.label)
            sidebarY = sidebarY - 20
        else
            -- Create tab button
            local btn = CreateFrame("Button", nil, sidebar)
            btn:SetSize(sidebarWidth - 12, 26)
            btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, sidebarY)

            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(btn)
            bg:SetColorTexture(0, 0, 0, 0)
            btn.bg = bg

            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", btn, "LEFT", 14, 0)
            text:SetText(item.label)
            btn.text = text

            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints(btn)
            highlight:SetColorTexture(1, 1, 1, 0.08)

            btn:SetScript("OnClick", function()
                ShowTab(item.index)
            end)

            table.insert(sidebarButtons, btn)
            sidebarY = sidebarY - 28
        end
    end

    ShowTab(1)

    local checkboxRefs = {}

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      General Tab Content                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    local y = -10

    _, y = CreateSectionHeader(generalContent, iSP.Colors.iSP .. "General Settings", y)

    local infoText
    infoText, y = CreateInfoText(generalContent,
        "|cFF808080iSoundPlayer allows you to play custom MP3 files at specific triggers.|r",
        y, "GameFontDisableSmall")

    y = y - 8
    _, y = CreateSectionHeader(generalContent, iSP.Colors.iSP .. "Interface", y)

    -- Minimap button checkbox
    local cbMinimap
    cbMinimap, y = CreateSettingsCheckbox(generalContent, "Show Minimap Button",
        "|cFF808080Show or hide the minimap button. Changes apply immediately.|r",
        y, nil,
        function() return not iSPSettings.MinimapButton.hide end,
        function(checked)
            iSPSettings.MinimapButton.hide = not checked
            if iSP.ToggleMinimapButton then
                -- Refresh minimap button
                if checked then
                    if LDBIcon then LDBIcon:Show("iSoundPlayer") end
                else
                    if LDBIcon then LDBIcon:Hide("iSoundPlayer") end
                end
            end
        end)
    checkboxRefs.MinimapButton = cbMinimap

    y = y - 8
    _, y = CreateSectionHeader(generalContent, iSP.Colors.iSP .. "Settings", y)

    local resetBtn
    resetBtn, y = CreateSettingsButton(generalContent, "Reset to Defaults", 200, y,
        function()
            StaticPopup_Show("ISP_RESET_SETTINGS")
        end)

    scrollChildren[1]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Sounds Tab Content                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    _, y = CreateSectionHeader(soundsContent, iSP.Colors.iSP .. "Sound Files", y)

    local soundInfo
    soundInfo, y = CreateInfoText(soundsContent,
        "|cFF808080Place your MP3 or OGG files in:|r\n|cFFFFFFFFInterface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n|cffff9716Sample Sounds:|r |cFF808080Browse the iSoundPlayer\\_Samples folder, copy your favorites to the sounds folder, then register them here using their filename. Test before assigning!|r\n\n|cFFFF9716IMPORTANT:|r |cFF808080Use /reload after adding files (no restart needed)|r",
        y, "GameFontDisableSmall")

    y = y - 10
    _, y = CreateSectionHeader(soundsContent, iSP.Colors.iSP .. "Add Sound File", y)

    y = y - 8

    local soundNameLabel = soundsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundNameLabel:SetPoint("TOPLEFT", soundsContent, "TOPLEFT", 25, y)
    soundNameLabel:SetText("|cFFFFFFFFFilename:|r |cFF808080(e.g., mysound or mysound.mp3)|r")

    y = y - 20

    -- Sound file name input
    local soundNameBox = CreateFrame("EditBox", nil, soundsContent, "InputBoxTemplate")
    soundNameBox:SetSize(350, 22)
    soundNameBox:SetPoint("TOPLEFT", soundsContent, "TOPLEFT", 25, y)
    soundNameBox:SetAutoFocus(false)
    soundNameBox:SetFontObject(GameFontHighlight)
    soundNameBox:SetMaxLetters(100)

    y = y - 30

    -- Forward declare UpdateSoundList so buttons can reference it
    local UpdateSoundList

    local addSoundBtn = CreateFrame("Button", nil, soundsContent, "UIPanelButtonTemplate")
    addSoundBtn:SetSize(120, 24)
    addSoundBtn:SetPoint("TOPLEFT", soundsContent, "TOPLEFT", 25, y)
    addSoundBtn:SetText("Add Sound")
    addSoundBtn:SetScript("OnClick", function()
        local fileName = soundNameBox:GetText()
        if fileName and fileName ~= "" then
            if not iSPSettings.SoundFiles then
                iSPSettings.SoundFiles = {}
            end

            -- Auto-add .mp3 if no extension
            if not fileName:match("%.mp3$") and not fileName:match("%.ogg$") then
                fileName = fileName .. ".mp3"
            end

            -- Check if already exists
            for _, sound in ipairs(iSPSettings.SoundFiles) do
                if sound == fileName then
                    print(iSP.L["DebugWarning"] .. "Sound already registered!")
                    return
                end
            end

            table.insert(iSPSettings.SoundFiles, fileName)
            print(iSP.L["PrintPrefix"] .. iSP.Colors.Green .. "Added: " .. fileName)
            soundNameBox:SetText("")
            UpdateSoundList()
        end
    end)

    local testSoundBtn = CreateFrame("Button", nil, soundsContent, "UIPanelButtonTemplate")
    testSoundBtn:SetSize(120, 24)
    testSoundBtn:SetPoint("LEFT", addSoundBtn, "RIGHT", 6, 0)
    testSoundBtn:SetText("Test Sound")
    testSoundBtn:SetScript("OnClick", function()
        local fileName = soundNameBox:GetText()
        if fileName and fileName ~= "" then
            -- Auto-add .mp3 if no extension
            if not fileName:match("%.mp3$") and not fileName:match("%.ogg$") then
                fileName = fileName .. ".mp3"
            end
            iSP:TestSound(fileName)
        else
            print(iSP.L["DebugError"] .. "Enter a filename first!")
        end
    end)

    y = y - 28

    y = y - 8
    _, y = CreateSectionHeader(soundsContent, iSP.Colors.iSP .. "Registered Sounds", y)

    -- Container for sound list items
    local soundListContainer = CreateFrame("Frame", nil, soundsContent)
    soundListContainer:SetPoint("TOPLEFT", soundsContent, "TOPLEFT", 20, y)
    soundListContainer:SetWidth(520)
    soundListContainer:SetHeight(1)

    local soundListFrames = {}

    -- Define UpdateSoundList function
    UpdateSoundList = function()
        -- Clear existing frames
        for _, frame in ipairs(soundListFrames) do
            frame:Hide()
            frame:SetParent(nil)
        end
        soundListFrames = {}

        local listY = 0

        if not iSPSettings.SoundFiles or #iSPSettings.SoundFiles == 0 then
            local emptyText = soundListContainer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            emptyText:SetPoint("TOPLEFT", soundListContainer, "TOPLEFT", 5, listY)
            emptyText:SetText("|cFF808080No sound files registered yet.|r")
            table.insert(soundListFrames, emptyText)
        else
            for i, sound in ipairs(iSPSettings.SoundFiles) do
                -- Create frame for each sound
                local soundFrame = CreateFrame("Frame", nil, soundListContainer, "BackdropTemplate")
                soundFrame:SetSize(500, 28)
                soundFrame:SetPoint("TOPLEFT", soundListContainer, "TOPLEFT", 0, listY)
                soundFrame:SetBackdrop({
                    bgFile = "Interface\\BUTTONS\\WHITE8X8",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 8,
                    insets = {left = 2, right = 2, top = 2, bottom = 2},
                })
                soundFrame:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
                soundFrame:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.5)

                -- Sound name text
                local soundText = soundFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                soundText:SetPoint("LEFT", soundFrame, "LEFT", 8, 0)
                soundText:SetText(iSP.Colors.Green .. i .. ".|r " .. sound)

                -- Test button
                local testBtn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
                testBtn:SetSize(50, 20)
                testBtn:SetPoint("RIGHT", soundFrame, "RIGHT", -60, 0)
                testBtn:SetText("Test")
                testBtn:SetScript("OnClick", function()
                    iSP:TestSound(sound)
                end)

                -- Remove button
                local removeBtn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
                removeBtn:SetSize(60, 20)
                removeBtn:SetPoint("RIGHT", soundFrame, "RIGHT", -4, 0)
                removeBtn:SetText("Remove")
                removeBtn:SetScript("OnClick", function()
                    -- Remove from table
                    for j, s in ipairs(iSPSettings.SoundFiles) do
                        if s == sound then
                            table.remove(iSPSettings.SoundFiles, j)
                            break
                        end
                    end
                    -- Refresh list
                    UpdateSoundList()
                    print(iSP.L["PrintPrefix"] .. iSP.Colors.Yellow .. "Removed sound: " .. sound)
                end)

                table.insert(soundListFrames, soundFrame)
                listY = listY - 30
            end
        end

        -- Update container height
        soundListContainer:SetHeight(math.abs(listY) + 10)
    end

    UpdateSoundList()
    iSP.UpdateSoundList = UpdateSoundList

    y = y - 300

    scrollChildren[2]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      Triggers Tab Content                     │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    _, y = CreateSectionHeader(triggersContent, iSP.Colors.iSP .. "Triggers", y)

    local triggerInfo
    triggerInfo, y = CreateInfoText(triggersContent,
        "|cFF808080Configure when sounds should play. Connect in-game events to your sound files.|r",
        y, "GameFontDisableSmall")

    y = y - 8

    -- Loop through all trigger categories
    if iSP.TriggerCategories then
        for _, category in ipairs(iSP.TriggerCategories) do
            -- Category header
            _, y = CreateSectionHeader(triggersContent,
                iSP.Colors.iSP .. category.name .. "|r |cFF808080- " .. category.desc .. "|r",
                y)

            -- Loop through triggers in this category
            for _, triggerID in ipairs(category.triggers) do
                local meta = iSP.TriggerMeta[triggerID]
                if meta then
                    local triggerFrame = CreateFrame("Frame", nil, triggersContent, "BackdropTemplate")
                    triggerFrame:SetSize(520, 90)
                    triggerFrame:SetPoint("TOPLEFT", triggersContent, "TOPLEFT", 20, y)
                    triggerFrame:SetBackdrop({
                        bgFile = "Interface\\BUTTONS\\WHITE8X8",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 8,
                        insets = {left = 2, right = 2, top = 2, bottom = 2},
                    })
                    triggerFrame:SetBackdropColor(0.08, 0.08, 0.1, 0.8)
                    triggerFrame:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

                    -- Trigger icon
                    if meta.icon then
                        local icon = triggerFrame:CreateTexture(nil, "ARTWORK")
                        icon:SetSize(24, 24)
                        icon:SetPoint("TOPLEFT", triggerFrame, "TOPLEFT", 6, -6)

                        -- Try to set the texture, use fallback if it fails
                        local success = icon:SetTexture(meta.icon)
                        if not success then
                            -- Fallback to a generic icon if the specified one doesn't exist
                            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                        end

                        -- Add border to icon
                        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    end

                    -- Trigger name
                    local nameLabel = triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    nameLabel:SetPoint("TOPLEFT", triggerFrame, "TOPLEFT", 36, -8)
                    nameLabel:SetText(iSP.Colors.iSP .. meta.name)

                    -- Trigger description with threshold inline
                    local descLabel = triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                    descLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)

                    -- Build description text with threshold if available
                    local descText = meta.desc
                    if meta.threshold then
                        descText = descText .. " |cFF808080(Threshold: " .. meta.threshold .. " kills)|r"
                    end
                    descLabel:SetText(descText)

                    -- Enable checkbox (moved to top-right)
                    local enableCB = CreateFrame("CheckButton", nil, triggerFrame, "InterfaceOptionsCheckButtonTemplate")
                    enableCB:SetPoint("TOPRIGHT", triggerFrame, "TOPRIGHT", -80, -6)
                    enableCB.Text:SetText("Enabled")
                    enableCB.Text:SetFontObject(GameFontNormalSmall)

                    if iSPSettings.Triggers[triggerID] then
                        enableCB:SetChecked(iSPSettings.Triggers[triggerID].enabled)
                    end

                    enableCB:SetScript("OnClick", function(self)
                        if iSPSettings.Triggers[triggerID] then
                            iSPSettings.Triggers[triggerID].enabled = self:GetChecked() and true or false
                        end
                    end)

                    -- Sound selection label
                    local soundLabel = triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    soundLabel:SetPoint("TOPLEFT", triggerFrame, "TOPLEFT", 10, -48)
                    soundLabel:SetText("Sound:")

                    -- Sound dropdown button
                    local soundDropdown = CreateFrame("Button", nil, triggerFrame, "UIPanelButtonTemplate")
                    soundDropdown:SetSize(200, 22)
                    soundDropdown:SetPoint("LEFT", soundLabel, "RIGHT", 5, 0)

                    -- Get current sound or "None"
                    local currentSound = ""
                    if iSPSettings.Triggers[triggerID] then
                        currentSound = iSPSettings.Triggers[triggerID].sound
                    end
                    if not currentSound or currentSound == "" then
                        soundDropdown:SetText("None")
                    else
                        soundDropdown:SetText(currentSound)
                    end

                    soundDropdown:SetScript("OnClick", function(self)
                        -- Check if any sounds are registered
                        if not iSPSettings.SoundFiles or #iSPSettings.SoundFiles == 0 then
                            print(iSP.L["DebugWarning"] .. "No sounds registered! Add sounds in the Sounds tab first.")
                            return
                        end

                        -- Create temporary dropdown frame
                        local menuFrame = CreateFrame("Frame", "iSP_TriggerSoundMenu_" .. triggerID, UIParent, "UIDropDownMenuTemplate")

                        -- Initialize function for dropdown
                        local function InitializeDropdown(frame, level)
                            local info = UIDropDownMenu_CreateInfo()

                            -- Add "None" option
                            info.text = "None"
                            info.func = function()
                                iSPSettings.Triggers[triggerID].sound = ""
                                soundDropdown:SetText("None")
                            end
                            info.checked = (iSPSettings.Triggers[triggerID].sound == "")
                            UIDropDownMenu_AddButton(info)

                            -- Add all registered sounds
                            for _, sound in ipairs(iSPSettings.SoundFiles) do
                                info = UIDropDownMenu_CreateInfo()
                                info.text = sound
                                info.func = function()
                                    iSPSettings.Triggers[triggerID].sound = sound
                                    soundDropdown:SetText(sound)
                                end
                                info.checked = (iSPSettings.Triggers[triggerID].sound == sound)
                                UIDropDownMenu_AddButton(info)
                            end
                        end

                        UIDropDownMenu_Initialize(menuFrame, InitializeDropdown, "MENU")
                        ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
                    end)

                    -- Test sound button
                    local testSoundBtn = CreateFrame("Button", nil, triggerFrame, "UIPanelButtonTemplate")
                    testSoundBtn:SetSize(50, 22)
                    testSoundBtn:SetPoint("LEFT", soundDropdown, "RIGHT", 5, 0)
                    testSoundBtn:SetText("Test")
                    testSoundBtn:SetScript("OnClick", function()
                        local sound = iSPSettings.Triggers[triggerID].sound
                        if sound and sound ~= "" then
                            iSP:TestSound(sound)
                        else
                            print(iSP.L["DebugError"] .. "No sound selected for this trigger!")
                        end
                    end)

                    y = y - 94
                end
            end

            y = y - 4  -- Extra spacing between categories
        end
    else
        -- Fallback if TriggerData.lua not loaded yet
        local errorText = triggersContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        errorText:SetPoint("TOP", triggersContent, "TOP", 0, y)
        errorText:SetText("|cFFFF0000Trigger data not loaded!|r")
        y = y - 30
    end

    scrollChildren[3]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       About Tab Content                       │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    _, y = CreateSectionHeader(aboutContent, "|cffff9716About|r", y)

    y = y - 4

    local aboutIcon = aboutContent:CreateTexture(nil, "ARTWORK")
    aboutIcon:SetSize(48, 48)
    aboutIcon:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutIcon:SetTexture(iconPath)
    y = y - 56

    local aboutTitle = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutTitle:SetText(iSP.Colors.iSP .. "iSoundPlayer|r " .. iSP.Colors.Green .. "v" .. iSP.Version .. "|r")
    y = y - 20

    local aboutAuthor = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutAuthor:SetText("Created by |cFF00FFFF" .. iSP.Author .. "|r")
    y = y - 16

    local aboutGameVer = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutGameVer:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutGameVer:SetText(iSP.GameVersionName or "")
    y = y - 20

    local aboutInfo = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutInfo:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    aboutInfo:SetWidth(500)
    aboutInfo:SetJustifyH("LEFT")
    aboutInfo:SetText("Play custom MP3 files at specific triggers in World of Warcraft.\n\nEarly development version.")
    local aih = aboutInfo:GetStringHeight()
    if aih < 14 then aih = 14 end
    y = y - aih - 8

    y = y - 4
    _, y = CreateSectionHeader(aboutContent, "|cffff9716Developer|r", y)

    local cbDebug
    cbDebug, y = CreateSettingsCheckbox(aboutContent, "Enable Debug Mode",
        "|cFF808080Enables verbose debug messages in chat.|r",
        y, "DebugMode")
    checkboxRefs.DebugMode = cbDebug

    scrollChildren[4]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   iNIF Tab Content (Static)                   │
    -- ╰───────────────────────────────────────────────────────────────╯
    -- Create BOTH variants at init, toggle visibility in OnShow

    -- iNIF Installed View
    local iNIFInstalledFrame = CreateFrame("Frame", nil, iNIFContent)
    iNIFInstalledFrame:SetAllPoints(iNIFContent)
    iNIFInstalledFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iNIFInstalledFrame, iSP.Colors.iSP .. "iNeedIfYouNeed Settings", y)
    local iNIFDesc
    iNIFDesc, y = CreateInfoText(iNIFInstalledFrame,
        iSP.Colors.iSP .. "iNeedIfYouNeed" .. iSP.Colors.Reset .. " is installed! You can access iNIF settings from here.\n\n" ..
        iSP.Colors.Gray .. "Note: These settings are managed by iNIF and will affect the iNIF addon.|r",
        y, "GameFontHighlight")
    y = y - 10
    local iNIFButton = CreateFrame("Button", nil, iNIFInstalledFrame, "UIPanelButtonTemplate")
    iNIFButton:SetSize(180, 28)
    iNIFButton:SetPoint("TOPLEFT", iNIFInstalledFrame, "TOPLEFT", 25, y)
    iNIFButton:SetText("Open iNIF Settings")
    iNIFButton:SetScript("OnClick", function()
        local iNIFFrame = _G["iNIFSettingsFrame"]
        if iNIFFrame then
            local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
            iNIFFrame:ClearAllPoints()
            iNIFFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
            settingsFrame:Hide()
            iNIFFrame:Show()
        else
            print(iSP.L["DebugError"] .. "iNIF settings not found!")
        end
    end)

    -- iNIF Promo View
    local iNIFPromoFrame = CreateFrame("Frame", nil, iNIFContent)
    iNIFPromoFrame:SetAllPoints(iNIFContent)
    iNIFPromoFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iNIFPromoFrame, iSP.Colors.iSP .. "iNeedIfYouNeed", y)
    local iNIFPromo
    iNIFPromo, y = CreateInfoText(iNIFPromoFrame,
        iSP.Colors.iSP .. "iNeedIfYouNeed" .. iSP.Colors.Reset .. " is a smart looting addon. It automatically rolls Need when party members need items, otherwise Greeds. Never miss the chance on random BoE loot that should have been greeded by all.\n\n" ..
        iSP.Colors.Reset .. "Simple checkbox on loot frames — check it and click Greed to enable monitoring.",
        y, "GameFontHighlight")
    y = y - 4
    local iNIFPromoLink
    iNIFPromoLink, y = CreateInfoText(iNIFPromoFrame,
        "Available on the CurseForge App and at curseforge.com/wow/addons/ineedifyouneed",
        y, "GameFontDisableSmall")

    scrollChildren[5]:SetHeight(200)  -- Static height

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   iWR Tab Content (Static)                    │
    -- ╰───────────────────────────────────────────────────────────────╯
    -- iWR Installed View
    local iWRInstalledFrame = CreateFrame("Frame", nil, iWRContent)
    iWRInstalledFrame:SetAllPoints(iWRContent)
    iWRInstalledFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iWRInstalledFrame, iSP.Colors.iSP .. "iWillRemember Settings", y)
    local iWRDesc
    iWRDesc, y = CreateInfoText(iWRInstalledFrame,
        iSP.Colors.iSP .. "iWillRemember" .. iSP.Colors.Reset .. " is installed! You can access iWR settings from here.\n\n" ..
        iSP.Colors.Gray .. "Note: These settings are managed by iWR and will affect the iWR addon.|r",
        y, "GameFontHighlight")
    y = y - 10
    local iWRButton = CreateFrame("Button", nil, iWRInstalledFrame, "UIPanelButtonTemplate")
    iWRButton:SetSize(180, 28)
    iWRButton:SetPoint("TOPLEFT", iWRInstalledFrame, "TOPLEFT", 25, y)
    iWRButton:SetText("Open iWR Settings")
    iWRButton:SetScript("OnClick", function()
        local iWRFrame = _G["iWRSettingsFrame"]
        if iWRFrame then
            local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
            iWRFrame:ClearAllPoints()
            iWRFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
            settingsFrame:Hide()
            iWRFrame:Show()
        else
            print(iSP.L["DebugError"] .. "iWR settings not found!")
        end
    end)

    -- iWR Promo View
    local iWRPromoFrame = CreateFrame("Frame", nil, iWRContent)
    iWRPromoFrame:SetAllPoints(iWRContent)
    iWRPromoFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iWRPromoFrame, iSP.Colors.iSP .. "iWillRemember", y)
    local iWRPromo
    iWRPromo, y = CreateInfoText(iWRPromoFrame,
        iSP.Colors.iSP .. "iWillRemember" .. iSP.Colors.Reset .. " is an addon designed to help you track and easily share player notes with friends.\n\n" ..
        iSP.Colors.Reset .. "Keep notes on players you meet — who to avoid, who's reliable, and share this knowledge with your guild.",
        y, "GameFontHighlight")
    y = y - 4
    local iWRPromoLink
    iWRPromoLink, y = CreateInfoText(iWRPromoFrame,
        "Available on the CurseForge App and at curseforge.com/wow/addons/iwillremember",
        y, "GameFontDisableSmall")

    scrollChildren[6]:SetHeight(200)  -- Static height

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      Show First Tab                           │
    -- ╰───────────────────────────────────────────────────────────────╯
    ShowTab(1)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       OnShow Refresh                          │
    -- ╰───────────────────────────────────────────────────────────────╯
    settingsFrame:HookScript("OnShow", function()
        for key, cb in pairs(checkboxRefs) do
            if iSPSettings[key] ~= nil then
                cb:SetChecked(iSPSettings[key])
            end
        end

        -- Update sound list
        if iSP.UpdateSoundList then
            iSP.UpdateSoundList()
        end

        -- Toggle addon tab visibility based on detection (like iWR does)
        local iNIFLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iNeedIfYouNeed")
        iNIFInstalledFrame:SetShown(iNIFLoaded)
        iNIFPromoFrame:SetShown(not iNIFLoaded)

        local iWRLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iWillRemember")
        iWRInstalledFrame:SetShown(iWRLoaded)
        iWRPromoFrame:SetShown(not iWRLoaded)
    end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                   Refresh Settings Panel                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    function iSP:RefreshSettingsPanel()
        for key, cb in pairs(checkboxRefs) do
            if iSPSettings[key] ~= nil then
                cb:SetChecked(iSPSettings[key])
            end
        end
    end
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                          Toggle / Open / Close                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

function iSP:SettingsToggle()
    if iSP.State.InCombat then
        print("|cFFFF0000Cannot open settings while in combat!|r")
        return
    end
    if iSP.SettingsFrame and iSP.SettingsFrame:IsVisible() then
        iSP.SettingsFrame:Hide()
    elseif iSP.SettingsFrame then
        iSP.SettingsFrame:Show()
    end
end

function iSP:SettingsOpen()
    if iSP.State.InCombat then
        print("|cFFFF0000Cannot open settings while in combat!|r")
        return
    end
    if iSP.SettingsFrame then
        iSP.SettingsFrame:Show()
    end
end

function iSP:SettingsClose()
    if iSP.SettingsFrame then
        iSP.SettingsFrame:Hide()
    end
end
