-- ═════════════════════════════════════════════════════════════════════════════════════════════════════════
-- ██╗ ███████╗ ██████╗  ██╗   ██╗ ███╗   ██╗ ██████╗  ██████╗  ██╗      █████╗  ██╗   ██╗ ███████╗ ██████╗
-- ██║ ██╔════╝██╔═══██╗ ██║   ██║ ████╗  ██║ ██╔══██╗ ██╔══██╗ ██║     ██╔══██╗ ╚██╗ ██╔╝ ██╔════╝ ██╔══██╗
-- ██║ ███████╗██║   ██║ ██║   ██║ ██╔██╗ ██║ ██║  ██║ ██████╔╝ ██║     ███████║  ╚████╔╝  █████╗   ██████╔╝
-- ██║ ╚════██║██║   ██║ ██║   ██║ ██║╚██╗██║ ██║  ██║ ██╔═══╝  ██║     ██╔══██║   ╚██╔╝   ██╔══╝   ██╔══██╗
-- ██║ ███████║╚██████╔╝ ╚██████╔╝ ██║ ╚████║ ██████╔╝ ██║      ███████╗██║  ██║    ██║    ███████╗ ██║  ██║
-- ╚═╝ ╚══════╝ ╚═════╝   ╚═════╝  ╚═╝  ╚═══╝ ╚═════╝  ╚═╝      ╚══════╝╚═╝  ╚═╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝
-- ═════════════════════════════════════════════════════════════════════════════════════════════════════════

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                      Options Panel (Custom Standalone Frame)                  │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local addonName, iSP = ...
local L = iSP.L

-- Retail 10.0+ removed InterfaceOptionsCheckButtonTemplate, use UICheckButtonTemplate instead
local CHECKBOX_TEMPLATE = InterfaceOptionsCheckButtonTemplate and "InterfaceOptionsCheckButtonTemplate" or "UICheckButtonTemplate"
-- Retail requires BackdropTemplateMixin for BackdropTemplate
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
local Colors = iSP.Colors
local iconPath = iSP.AddonPath .. "Images\\Icons\\Logo_iSP.blp"

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper Functions                                 │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

local function CreateSectionHeader(parent, text, yOffset)
    local header = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
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
    local cb = CreateFrame("CheckButton", nil, parent, CHECKBOX_TEMPLATE)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    -- UICheckButtonTemplate (retail) doesn't have .Text, create it if missing
    if not cb.Text then
        cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    end
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
    text = L["ResetConfirm"],
    button1 = L["Yes"],
    button2 = L["No"],
    OnAccept = function()
        for key, value in pairs(iSP.SettingsDefault) do
            if key ~= "MinimapButton" then
                iSPSettings[key] = type(value) == "table" and CopyTable(value) or value
            end
        end
        print(L["SettingsResetSuccess"])
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
    local shadow = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
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
    local titleBar = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
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

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(Colors.iSP .. "iSoundPlayer" .. Colors.Green .. " v" .. iSP.Version)

    local closeButton = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() iSP:SettingsClose() end)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                     Sidebar Navigation                        │
    -- ╰───────────────────────────────────────────────────────────────╯
    local sidebarWidth = 150

    local sidebar = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
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
    local contentArea = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
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
    local iNIFTabButton = nil  -- Reference to iNIF tab button
    local iWRTabButton = nil   -- Reference to iWR tab button
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
        {type = "header", label = L["SidebarHeaderiSP"]},
        {type = "tab", label = L["Tab1General"], index = 1},
        {type = "tab", label = L["Tab2Sounds"], index = 2},
        {type = "tab", label = L["Tab3Triggers"], index = 3},
        {type = "tab", label = L["Tab4About"], index = 4},
        {type = "header", label = L["SidebarHeaderOtherAddons"]},
        {type = "tab", label = L["TabINIFPromo"], index = 5},
        {type = "tab", label = L["TabIWRPromo"], index = 6},
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

            -- Save references to addon tab buttons
            if item.index == 5 then
                iNIFTabButton = btn
            elseif item.index == 6 then
                iWRTabButton = btn
            end

            sidebarY = sidebarY - 28
        end
    end

    ShowTab(1)

    local checkboxRefs = {}

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                      General Tab Content                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    local y = -10

    _, y = CreateSectionHeader(generalContent, L["GeneralSettings"], y)

    local infoText
    infoText, y = CreateInfoText(generalContent,
        L["GeneralInfo"],
        y, "GameFontDisableSmall")

    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["InterfaceSettings"], y)

    -- Minimap button checkbox
    local cbMinimap
    cbMinimap, y = CreateSettingsCheckbox(generalContent, L["ShowMinimapButton"],
        L["DescShowMinimapButton"],
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

    -- Show notifications checkbox
    local cbNotifications
    cbNotifications, y = CreateSettingsCheckbox(generalContent, L["ShowNotifications"],
        L["DescShowNotifications"],
        y, "ShowNotifications")
    checkboxRefs.ShowNotifications = cbNotifications

    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["SoundSettings"], y)

    -- Sound Channel label
    local channelLabel = generalContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelLabel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    channelLabel:SetText(L["SoundChannelLabel"])
    y = y - 20

    -- Sound Channel description
    local channelDesc = generalContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    channelDesc:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    channelDesc:SetWidth(480)
    channelDesc:SetJustifyH("LEFT")
    channelDesc:SetText(L["DescSoundChannel"])
    local descH = channelDesc:GetStringHeight()
    if descH < 12 then descH = 12 end
    y = y - descH - 6

    -- Sound Channel dropdown
    local channelOptions = {"Master", "SFX", "Music", "Ambience", "Dialog"}
    local channelDisplayNames = {
        Master = L["ChannelMaster"],
        SFX = L["ChannelSFX"],
        Music = L["ChannelMusic"],
        Ambience = L["ChannelAmbience"],
        Dialog = L["ChannelDialog"],
    }
    local channelCVars = {
        Master = "Sound_MasterVolume",
        SFX = "Sound_SFXVolume",
        Music = "Sound_MusicVolume",
        Ambience = "Sound_AmbienceVolume",
        Dialog = "Sound_DialogVolume",
    }

    local channelDropdown = CreateFrame("Frame", "iSP_ChannelDropdown", generalContent, "UIDropDownMenuTemplate")
    channelDropdown:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 5, y)
    UIDropDownMenu_SetWidth(channelDropdown, 170)

    local currentChannel = iSPSettings.SoundChannel or "Master"
    UIDropDownMenu_SetText(channelDropdown, channelDisplayNames[currentChannel] or currentChannel)

    y = y - 34

    -- Custom volume slider factory (iWR-style: track + fill + ticks + thumb)
    local VSLIDER_WIDTH = 200
    local VSLIDER_HEIGHT = 12

    local function CreateCustomVolumeSlider(parent, anchorPoint, minVal, maxVal, step)
        -- Track (BackdropTemplate)
        local track = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
        track:SetSize(VSLIDER_WIDTH, VSLIDER_HEIGHT)
        track:SetPoint(unpack(anchorPoint))
        track:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1},
        })
        track:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        track:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

        -- Fill bar (left-to-right, iSP orange)
        local fill = track:CreateTexture(nil, "ARTWORK")
        fill:SetHeight(VSLIDER_HEIGHT - 2)
        fill:SetPoint("LEFT", track, "LEFT", 1, 0)
        fill:SetTexture("Interface\\Buttons\\WHITE8x8")
        fill:SetVertexColor(1, 0.59, 0.09, 0.7)

        -- Tick marks every 10% (11 ticks: 0%, 10%, ..., 100%)
        local stepPx = VSLIDER_WIDTH / 10
        for i = 0, 10 do
            local tick = track:CreateTexture(nil, "OVERLAY")
            tick:SetSize(1, VSLIDER_HEIGHT)
            tick:SetPoint("CENTER", track, "LEFT", i * stepPx, 0)
            tick:SetColorTexture(0.5, 0.5, 0.5, 0.6)
        end

        -- Thumb
        local thumb = CreateFrame("Frame", nil, track)
        thumb:SetSize(14, 18)
        thumb:SetPoint("CENTER", track, "LEFT", 0, 0)
        local thumbTex = thumb:CreateTexture(nil, "OVERLAY")
        thumbTex:SetAllPoints()
        thumbTex:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

        -- Min/Max labels below track
        local lowLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        lowLabel:SetPoint("TOPLEFT", track, "BOTTOMLEFT", 0, -2)
        lowLabel:SetText("|cFF999999" .. minVal .. "%|r")

        local highLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        highLabel:SetPoint("TOPRIGHT", track, "BOTTOMRIGHT", 0, -2)
        highLabel:SetText("|cFF999999" .. maxVal .. "%|r")

        -- Value text (to the right of track)
        local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueText:SetPoint("LEFT", track, "RIGHT", 12, 0)

        -- State
        local slider = { value = 0, onValueChanged = nil }

        local function UpdateDisplay(val)
            val = math.floor(val + 0.5)
            if val < minVal then val = minVal end
            if val > maxVal then val = maxVal end
            slider.value = val

            -- Thumb position
            local fraction = (val - minVal) / (maxVal - minVal)
            local thumbX = fraction * VSLIDER_WIDTH
            thumb:ClearAllPoints()
            thumb:SetPoint("CENTER", track, "LEFT", thumbX, 0)

            -- Fill bar width
            if val <= minVal then
                fill:Hide()
            else
                fill:Show()
                fill:SetWidth(math.max(1, thumbX - 1))
            end

            -- Value text
            valueText:SetText(val .. "%")

            -- Callback
            if slider.onValueChanged then
                slider.onValueChanged(val)
            end
        end

        function slider:SetValue(val)
            UpdateDisplay(val)
        end

        function slider:GetValue()
            return self.value
        end

        -- Click on track
        track:EnableMouse(true)
        track:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
                local left = self:GetLeft()
                local fraction = (x - left) / VSLIDER_WIDTH
                local val = minVal + fraction * (maxVal - minVal)
                val = math.floor(val / step + 0.5) * step
                UpdateDisplay(val)
            end
        end)

        -- Drag thumb
        thumb:EnableMouse(true)
        thumb:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then self.dragging = true end
        end)
        thumb:SetScript("OnMouseUp", function(self)
            self.dragging = false
        end)

        track:SetScript("OnUpdate", function(self)
            if thumb.dragging then
                local x = select(1, GetCursorPosition()) / self:GetEffectiveScale()
                local left = self:GetLeft()
                local fraction = (x - left) / VSLIDER_WIDTH
                local val = minVal + fraction * (maxVal - minVal)
                val = math.floor(val / step + 0.5) * step
                if val < minVal then val = minVal end
                if val > maxVal then val = maxVal end
                UpdateDisplay(val)
            end
        end)

        -- Mousewheel
        track:EnableMouseWheel(true)
        track:SetScript("OnMouseWheel", function(self, delta)
            local newVal = slider.value + (delta * step)
            if newVal < minVal then newVal = minVal end
            if newVal > maxVal then newVal = maxVal end
            UpdateDisplay(newVal)
        end)

        return slider
    end

    -- ── Channel Volume ──
    local channelVolLabel = generalContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelVolLabel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    channelVolLabel:SetText(L["VolumeLabel"] or "Channel Volume")
    y = y - 18

    local channelVolDesc = generalContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    channelVolDesc:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    channelVolDesc:SetWidth(480)
    channelVolDesc:SetJustifyH("LEFT")
    channelVolDesc:SetText(L["DescVolume"] or "")
    local cvDescH = channelVolDesc:GetStringHeight()
    if cvDescH < 12 then cvDescH = 12 end
    y = y - cvDescH - 6

    local channelVolSlider = CreateCustomVolumeSlider(
        generalContent, {"TOPLEFT", generalContent, "TOPLEFT", 25, y}, 0, 100, 1
    )

    channelVolSlider.onValueChanged = function(val)
        local ch = iSPSettings.SoundChannel or "Master"
        local cvar = channelCVars[ch] or "Sound_MasterVolume"
        SetCVar(cvar, val / 100)
    end

    -- Helper: update channel volume slider to reflect current channel's volume
    local function UpdateChannelVolumeSlider()
        local ch = iSPSettings.SoundChannel or "Master"
        local cvar = channelCVars[ch] or "Sound_MasterVolume"
        local vol = tonumber(GetCVar(cvar)) or 1.0
        local pct = math.floor(vol * 100 + 0.5)
        channelVolSlider:SetValue(pct)
    end

    UpdateChannelVolumeSlider()

    y = y - 32

    -- ── Soundfile Volume ──
    local sfVolLabel = generalContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sfVolLabel:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    sfVolLabel:SetText(L["SoundfileVolumeLabel"] or "Soundfile Volume")
    y = y - 18

    local sfVolDesc = generalContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sfVolDesc:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 25, y)
    sfVolDesc:SetWidth(480)
    sfVolDesc:SetJustifyH("LEFT")
    sfVolDesc:SetText(L["DescSoundfileVolume"] or "")
    local sfDescH = sfVolDesc:GetStringHeight()
    if sfDescH < 12 then sfDescH = 12 end
    y = y - sfDescH - 6

    local sfVolSlider = CreateCustomVolumeSlider(
        generalContent, {"TOPLEFT", generalContent, "TOPLEFT", 25, y}, 0, 100, 1
    )

    sfVolSlider.onValueChanged = function(val)
        iSPSettings.iSPVolume = val
    end

    local function UpdateSoundfileVolumeSlider()
        local pct = iSPSettings.iSPVolume or 100
        sfVolSlider:SetValue(pct)
    end

    UpdateSoundfileVolumeSlider()

    -- Initialize dropdown (needs slider references)
    UIDropDownMenu_Initialize(channelDropdown, function(self, level)
        for _, ch in ipairs(channelOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channelDisplayNames[ch]
            info.value = ch
            info.checked = (iSPSettings.SoundChannel == ch)
            info.func = function(btn)
                iSPSettings.SoundChannel = btn.value
                UIDropDownMenu_SetText(channelDropdown, channelDisplayNames[btn.value])
                CloseDropDownMenus()
                UpdateChannelVolumeSlider()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    y = y - 32

    y = y - 8
    _, y = CreateSectionHeader(generalContent, L["SettingsHeader"], y)

    local resetBtn
    resetBtn, y = CreateSettingsButton(generalContent, L["ResetToDefaults"], 200, y,
        function()
            StaticPopup_Show("ISP_RESET_SETTINGS")
        end)

    scrollChildren[1]:SetHeight(math.abs(y) + 20)

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       Sounds Tab Content                      │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    _, y = CreateSectionHeader(soundsContent, L["SoundFiles"], y)

    local soundInfo
    soundInfo, y = CreateInfoText(soundsContent,
        L["SoundFilesInfoShort"],
        y, "GameFontDisableSmall")

    y = y - 10
    _, y = CreateSectionHeader(soundsContent, L["AddSoundFile"], y)

    y = y - 8

    local soundNameLabel = soundsContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    soundNameLabel:SetPoint("TOPLEFT", soundsContent, "TOPLEFT", 25, y)
    soundNameLabel:SetText(L["FilenameInputLabel"])

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
    addSoundBtn:SetText(L["AddSound"])
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
                    print(L["DebugWarning"] .. L["SoundAlreadyExists"])
                    return
                end
            end

            table.insert(iSPSettings.SoundFiles, fileName)
            print(string.format(L["SoundAdded"], fileName))
            soundNameBox:SetText("")
            UpdateSoundList()
        end
    end)

    local testSoundBtn = CreateFrame("Button", nil, soundsContent, "UIPanelButtonTemplate")
    testSoundBtn:SetSize(120, 24)
    testSoundBtn:SetPoint("LEFT", addSoundBtn, "RIGHT", 6, 0)
    testSoundBtn:SetText(L["TestSound"])
    testSoundBtn:SetScript("OnClick", function()
        local fileName = soundNameBox:GetText()
        if fileName and fileName ~= "" then
            -- Auto-add .mp3 if no extension
            if not fileName:match("%.mp3$") and not fileName:match("%.ogg$") then
                fileName = fileName .. ".mp3"
            end
            iSP:TestSound(fileName)
        else
            print(L["EnterFilenameFirst"])
        end
    end)

    y = y - 28

    y = y - 8
    _, y = CreateSectionHeader(soundsContent, L["RegisteredSounds"], y)

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
            emptyText:SetText(L["NoSoundsRegistered"])
            table.insert(soundListFrames, emptyText)
        else
            for i, sound in ipairs(iSPSettings.SoundFiles) do
                -- Create frame for each sound
                local soundFrame = CreateFrame("Frame", nil, soundListContainer, BACKDROP_TEMPLATE)
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
                soundText:SetText(Colors.Green .. i .. ".|r " .. sound)

                -- Test button
                local testBtn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
                testBtn:SetSize(50, 20)
                testBtn:SetPoint("RIGHT", soundFrame, "RIGHT", -60, 0)
                testBtn:SetText(L["TestBtn"])
                testBtn:SetScript("OnClick", function()
                    iSP:TestSound(sound)
                end)

                -- Remove button
                local removeBtn = CreateFrame("Button", nil, soundFrame, "UIPanelButtonTemplate")
                removeBtn:SetSize(60, 20)
                removeBtn:SetPoint("RIGHT", soundFrame, "RIGHT", -4, 0)
                removeBtn:SetText(L["RemoveSound"])
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
                    print(string.format(L["SoundRemoved"], sound))
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

    _, y = CreateSectionHeader(triggersContent, L["Triggers"], y)

    local triggerInfo
    triggerInfo, y = CreateInfoText(triggersContent,
        L["TriggersInfo"],
        y, "GameFontDisableSmall")

    y = y - 8

    -- Search box
    local searchBox = CreateFrame("EditBox", nil, triggersContent, "InputBoxTemplate")
    searchBox:SetSize(250, 22)
    searchBox:SetPoint("TOPLEFT", triggersContent, "TOPLEFT", 25, y)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(GameFontHighlight)
    searchBox:SetMaxLetters(50)

    local searchPlaceholder = triggersContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
    searchPlaceholder:SetText(L["SearchTriggers"])

    -- Hide placeholder when typing
    searchBox:SetScript("OnEditFocusGained", function() searchPlaceholder:Hide() end)
    searchBox:SetScript("OnEditFocusLost", function()
        if searchBox:GetText() == "" then searchPlaceholder:Show() end
    end)

    y = y - 30

    -- Collapse/expand state and frame storage (all collapsed by default)
    local categoryCollapsed = {}
    for _, cat in ipairs(iSP.TriggerCategories) do
        categoryCollapsed[cat.id] = true
    end
    local triggerFrameCache = {}  -- triggerID -> frame (created once, reused)
    local categoryHeaderCache = {}  -- categoryID -> {frame, arrow, countLabel, checkbox}
    local searchText = ""
    local triggersStartY = y

    -- ╭───────────────────────────────────────────────────────────────────────────────╮
    -- │                          Sound Picker Popup (Singleton)                      │
    -- ╰───────────────────────────────────────────────────────────────────────────────╯
    local soundPicker = CreateFrame("Frame", "iSP_SoundPicker", UIParent, BACKDROP_TEMPLATE)
    soundPicker:SetSize(260, 300)
    soundPicker:SetFrameStrata("DIALOG")
    soundPicker:SetFrameLevel(100)
    soundPicker:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    soundPicker:SetBackdropColor(0.06, 0.06, 0.08, 0.95)
    soundPicker:SetBackdropBorderColor(1, 0.59, 0.09, 0.7)
    soundPicker:SetClampedToScreen(true)
    soundPicker:Hide()
    soundPicker:EnableMouse(true)

    -- Close on Escape
    tinsert(UISpecialFrames, "iSP_SoundPicker")

    -- Picker state
    soundPicker.activeTriggerID = nil
    soundPicker.activeDropdown = nil

    -- Search box inside picker
    local pickerSearch = CreateFrame("EditBox", nil, soundPicker, "InputBoxTemplate")
    pickerSearch:SetSize(230, 22)
    pickerSearch:SetPoint("TOPLEFT", soundPicker, "TOPLEFT", 14, -10)
    pickerSearch:SetAutoFocus(false)
    pickerSearch:SetFontObject(GameFontHighlight)
    pickerSearch:SetMaxLetters(50)

    local pickerPlaceholder = soundPicker:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    pickerPlaceholder:SetPoint("LEFT", pickerSearch, "LEFT", 6, 0)
    pickerPlaceholder:SetText(L["SearchSounds"])

    pickerSearch:SetScript("OnEditFocusGained", function() pickerPlaceholder:Hide() end)
    pickerSearch:SetScript("OnEditFocusLost", function()
        if pickerSearch:GetText() == "" then pickerPlaceholder:Show() end
    end)
    pickerSearch:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        soundPicker:Hide()
    end)

    -- Scroll frame for sound list
    local pickerScroll = CreateFrame("ScrollFrame", nil, soundPicker, "UIPanelScrollFrameTemplate")
    pickerScroll:SetPoint("TOPLEFT", soundPicker, "TOPLEFT", 6, -38)
    pickerScroll:SetPoint("BOTTOMRIGHT", soundPicker, "BOTTOMRIGHT", -26, 6)

    local pickerScrollChild = CreateFrame("Frame", nil, pickerScroll)
    pickerScrollChild:SetWidth(220)
    pickerScrollChild:SetHeight(1)
    pickerScroll:SetScrollChild(pickerScrollChild)

    -- Sound row cache
    local soundRowCache = {}
    local ROW_HEIGHT = 20

    local function CreateSoundRow(index)
        local row = CreateFrame("Button", nil, pickerScrollChild)
        row:SetSize(220, ROW_HEIGHT)

        -- Highlight on hover
        local highlight = row:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 0.59, 0.09, 0.15)

        -- Checkmark
        local check = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        check:SetPoint("LEFT", row, "LEFT", 4, 0)
        check:SetText("|cFF00FF00✓|r")
        check:Hide()
        row.check = check

        -- Sound name label
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 18, 0)
        label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        row.label = label

        row:SetScript("OnClick", function(self)
            local triggerID = soundPicker.activeTriggerID
            local dropdown = soundPicker.activeDropdown
            if triggerID and dropdown then
                local soundName = self.soundName
                if soundName == "" then
                    iSPSettings.Triggers[triggerID].sound = ""
                    dropdown:SetText(L["None"])
                else
                    iSPSettings.Triggers[triggerID].sound = soundName
                    dropdown:SetText(soundName)
                end
            end
            soundPicker:Hide()
        end)

        return row
    end

    local function RefreshSoundPicker()
        local triggerID = soundPicker.activeTriggerID
        if not triggerID then return end

        local filter = pickerSearch:GetText():lower()
        local currentSound = ""
        if iSPSettings.Triggers[triggerID] then
            currentSound = iSPSettings.Triggers[triggerID].sound or ""
        end

        -- Build filtered sound list: "None" first, then matching sounds
        local filteredSounds = {}
        if filter == "" or string.find(L["None"]:lower(), filter, 1, true) then
            table.insert(filteredSounds, "")  -- "" represents "None"
        end
        if iSPSettings.SoundFiles then
            for _, sound in ipairs(iSPSettings.SoundFiles) do
                if filter == "" or string.find(sound:lower(), filter, 1, true) then
                    table.insert(filteredSounds, sound)
                end
            end
        end

        -- Ensure enough rows exist
        for i = #soundRowCache + 1, #filteredSounds do
            soundRowCache[i] = CreateSoundRow(i)
        end

        -- Position and show matching rows, hide the rest
        for i, soundName in ipairs(filteredSounds) do
            local row = soundRowCache[i]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", pickerScrollChild, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
            row:Show()

            row.soundName = soundName
            if soundName == "" then
                row.label:SetText(Colors.Gray .. L["None"])
            else
                row.label:SetText(soundName)
            end

            -- Show checkmark on currently selected sound
            if soundName == currentSound then
                row.check:Show()
            else
                row.check:Hide()
            end
        end

        -- Hide unused rows
        for i = #filteredSounds + 1, #soundRowCache do
            soundRowCache[i]:Hide()
        end

        -- Update scroll height
        local totalHeight = #filteredSounds * ROW_HEIGHT
        pickerScrollChild:SetHeight(math.max(totalHeight, 1))

        -- Resize picker height based on content (min 80, max 300)
        local contentHeight = totalHeight + 48  -- 38 for search + 10 padding
        local pickerHeight = math.max(80, math.min(contentHeight, 300))
        soundPicker:SetHeight(pickerHeight)
    end

    pickerSearch:SetScript("OnTextChanged", function(self)
        RefreshSoundPicker()
    end)

    -- Close picker when clicking elsewhere (click-outside detection)
    soundPicker:SetScript("OnHide", function()
        pickerSearch:SetText("")
        pickerPlaceholder:Show()
        pickerSearch:ClearFocus()
    end)

    -- Use OnUpdate to detect clicks outside the picker
    soundPicker:SetScript("OnUpdate", function(self)
        if not self:IsShown() then return end
        if IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") then
            if not self:IsMouseOver() then
                self:Hide()
            end
        end
    end)

    -- Public function to open the picker anchored to a dropdown button
    local function OpenSoundPicker(dropdown, triggerID)
        if not iSPSettings.SoundFiles or #iSPSettings.SoundFiles == 0 then
            print(L["DebugWarning"] .. L["NoSoundsWarning"])
            return
        end

        soundPicker.activeTriggerID = triggerID
        soundPicker.activeDropdown = dropdown

        -- Position below the dropdown button
        soundPicker:ClearAllPoints()
        soundPicker:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -2)

        pickerSearch:SetText("")
        pickerPlaceholder:Show()

        soundPicker:Show()
        RefreshSoundPicker()
        pickerSearch:SetFocus()
    end

    -- Create a single trigger frame (called once per trigger, then reused)
    local function CreateTriggerFrame(triggerID, meta)
        local triggerFrame = CreateFrame("Frame", nil, triggersContent, BACKDROP_TEMPLATE)
        triggerFrame:SetSize(520, 90)
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
            local success = icon:SetTexture(meta.icon)
            if not success then
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        end

        -- Trigger name
        local nameLabel = triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameLabel:SetPoint("TOPLEFT", triggerFrame, "TOPLEFT", 36, -8)
        nameLabel:SetText(Colors.iSP .. meta.name)

        -- Trigger description with threshold and cooldown inline
        local descLabel = triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        descLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)

        local descText = meta.desc
        if meta.threshold then
            descText = descText .. " |cFF808080(Threshold: " .. meta.threshold .. " kills)|r"
        end
        if meta.cooldown and meta.cooldown > 0 then
            descText = descText .. " |cFF808080(Cooldown: " .. meta.cooldown .. "s)|r"
        end
        descLabel:SetText(descText)

        -- Enable checkbox
        local enableCB = CreateFrame("CheckButton", nil, triggerFrame, CHECKBOX_TEMPLATE)
        enableCB:SetPoint("TOPRIGHT", triggerFrame, "TOPRIGHT", -80, -6)
        if not enableCB.Text then
            enableCB.Text = enableCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            enableCB.Text:SetPoint("LEFT", enableCB, "RIGHT", 4, 0)
        end
        enableCB.Text:SetText(L["Enabled"])
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
        soundLabel:SetText(L["SoundLabel"])

        -- Sound dropdown button
        local soundDropdown = CreateFrame("Button", nil, triggerFrame, "UIPanelButtonTemplate")
        soundDropdown:SetSize(200, 22)
        soundDropdown:SetPoint("LEFT", soundLabel, "RIGHT", 5, 0)

        local currentSound = ""
        if iSPSettings.Triggers[triggerID] then
            currentSound = iSPSettings.Triggers[triggerID].sound
        end
        if not currentSound or currentSound == "" then
            soundDropdown:SetText(L["None"])
        else
            soundDropdown:SetText(currentSound)
        end

        soundDropdown:SetScript("OnClick", function(self)
            OpenSoundPicker(self, triggerID)
        end)

        -- Test sound button
        local testSoundBtn = CreateFrame("Button", nil, triggerFrame, "UIPanelButtonTemplate")
        testSoundBtn:SetSize(50, 22)
        testSoundBtn:SetPoint("LEFT", soundDropdown, "RIGHT", 5, 0)
        testSoundBtn:SetText(L["TestBtn"])
        testSoundBtn:SetScript("OnClick", function()
            local sound = iSPSettings.Triggers[triggerID].sound
            if sound and sound ~= "" then
                iSP:TestSound(sound)
            else
                print(L["DebugError"] .. L["NoSoundSelected"])
            end
        end)

        triggerFrame.enableCB = enableCB
        triggerFrame.soundDropdown = soundDropdown

        return triggerFrame
    end

    -- Create a category header frame (called once per category, then reused)
    local function CreateCategoryHeader(category)
        local headerFrame = CreateFrame("Button", nil, triggersContent, BACKDROP_TEMPLATE)
        headerFrame:SetHeight(28)
        headerFrame:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
        })
        headerFrame:SetBackdropColor(0.15, 0.15, 0.2, 0.8)

        -- Collapse/expand arrow
        local arrow = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        arrow:SetPoint("LEFT", headerFrame, "LEFT", 8, 0)
        arrow:SetText("-")

        -- Category icon
        local catIcon = headerFrame:CreateTexture(nil, "ARTWORK")
        catIcon:SetSize(18, 18)
        catIcon:SetPoint("LEFT", arrow, "RIGHT", 6, 0)
        catIcon:SetTexture(category.icon)
        catIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- Category name + count label
        local catLabel = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        catLabel:SetPoint("LEFT", catIcon, "RIGHT", 6, 0)

        -- Category-level enable/disable checkbox
        local catCB = CreateFrame("CheckButton", nil, headerFrame, CHECKBOX_TEMPLATE)
        catCB:SetPoint("RIGHT", headerFrame, "RIGHT", -8, 0)
        catCB:SetSize(20, 20)
        if not catCB.Text then
            catCB.Text = catCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            catCB.Text:SetPoint("LEFT", catCB, "RIGHT", 2, 0)
        end
        catCB.Text:SetText("")

        -- Accent line at bottom
        local accent = headerFrame:CreateTexture(nil, "ARTWORK")
        accent:SetHeight(1)
        accent:SetPoint("BOTTOMLEFT", headerFrame, "BOTTOMLEFT", 0, 0)
        accent:SetPoint("BOTTOMRIGHT", headerFrame, "BOTTOMRIGHT", 0, 0)
        accent:SetColorTexture(1, 0.59, 0.09, 0.4)

        return {
            frame = headerFrame,
            arrow = arrow,
            catLabel = catLabel,
            catCB = catCB,
        }
    end

    -- RenderTriggers — repositions and shows/hides frames based on collapse + search state
    local function RenderTriggers()
        local currentY = triggersStartY

        if not iSP.TriggerCategories then
            scrollChildren[3]:SetHeight(math.abs(currentY) + 40)
            return
        end

        for _, category in ipairs(iSP.TriggerCategories) do
            -- Skip categories with no available triggers for this version
            if not iSP:IsCategoryAvailable(category.id) then
                -- Hide cached header if it exists
                if categoryHeaderCache[category.id] then
                    categoryHeaderCache[category.id].frame:Hide()
                end
                -- Hide cached trigger frames
                for _, triggerID in ipairs(category.triggers) do
                    if triggerFrameCache[triggerID] then
                        triggerFrameCache[triggerID]:Hide()
                    end
                end
            else
                local availableTriggers = iSP:GetAvailableTriggersInCategory(category.id)

                -- Filter by search text
                local filteredTriggers = {}
                if searchText ~= "" then
                    local searchLower = string.lower(searchText)
                    for _, triggerID in ipairs(availableTriggers) do
                        local meta = iSP.TriggerMeta[triggerID]
                        if meta then
                            if string.find(string.lower(meta.name), searchLower, 1, true)
                               or string.find(string.lower(meta.desc), searchLower, 1, true)
                               or string.find(string.lower(triggerID), searchLower, 1, true) then
                                table.insert(filteredTriggers, triggerID)
                            end
                        end
                    end
                else
                    filteredTriggers = availableTriggers
                end

                -- Skip category if no triggers match search
                if #filteredTriggers == 0 and searchText ~= "" then
                    if categoryHeaderCache[category.id] then
                        categoryHeaderCache[category.id].frame:Hide()
                    end
                    for _, triggerID in ipairs(availableTriggers) do
                        if triggerFrameCache[triggerID] then
                            triggerFrameCache[triggerID]:Hide()
                        end
                    end
                else
                    -- ── Category Header ──
                    if not categoryHeaderCache[category.id] then
                        categoryHeaderCache[category.id] = CreateCategoryHeader(category)
                    end

                    local header = categoryHeaderCache[category.id]
                    local isCollapsed = categoryCollapsed[category.id]

                    -- Update arrow
                    header.arrow:SetText(isCollapsed and "+" or "-")

                    -- Update enabled count
                    local enabledCount = 0
                    for _, tid in ipairs(availableTriggers) do
                        if iSPSettings.Triggers[tid] and iSPSettings.Triggers[tid].enabled then
                            enabledCount = enabledCount + 1
                        end
                    end
                    header.catLabel:SetText(Colors.iSP .. category.name .. "|r "
                        .. Colors.Gray .. "(" .. enabledCount .. "/" .. #availableTriggers .. " enabled)|r")

                    -- Update category checkbox state
                    local allEnabled = #availableTriggers > 0
                    for _, tid in ipairs(availableTriggers) do
                        if not iSPSettings.Triggers[tid] or not iSPSettings.Triggers[tid].enabled then
                            allEnabled = false
                            break
                        end
                    end
                    header.catCB:SetChecked(allEnabled)

                    -- Category checkbox click handler
                    header.catCB:SetScript("OnClick", function(self)
                        local checked = self:GetChecked() and true or false
                        for _, tid in ipairs(availableTriggers) do
                            if iSPSettings.Triggers[tid] then
                                iSPSettings.Triggers[tid].enabled = checked
                            end
                        end
                        RenderTriggers()
                    end)

                    -- Header click handler (collapse/expand)
                    header.frame:SetScript("OnClick", function(self, button)
                        categoryCollapsed[category.id] = not categoryCollapsed[category.id]
                        RenderTriggers()
                    end)

                    -- Position header
                    header.frame:ClearAllPoints()
                    header.frame:SetPoint("TOPLEFT", triggersContent, "TOPLEFT", 10, currentY)
                    header.frame:SetPoint("TOPRIGHT", triggersContent, "TOPRIGHT", -10, currentY)
                    header.frame:Show()

                    currentY = currentY - 30

                    -- ── Trigger frames (if not collapsed) ──
                    if not isCollapsed then
                        for _, triggerID in ipairs(filteredTriggers) do
                            local meta = iSP.TriggerMeta[triggerID]
                            if meta then
                                -- Create frame once, reuse on subsequent renders
                                if not triggerFrameCache[triggerID] then
                                    triggerFrameCache[triggerID] = CreateTriggerFrame(triggerID, meta)
                                end

                                local tf = triggerFrameCache[triggerID]

                                -- Update checkbox state (may have changed from category toggle)
                                if tf.enableCB and iSPSettings.Triggers[triggerID] then
                                    tf.enableCB:SetChecked(iSPSettings.Triggers[triggerID].enabled)
                                end

                                -- Update sound dropdown text
                                if tf.soundDropdown and iSPSettings.Triggers[triggerID] then
                                    local cs = iSPSettings.Triggers[triggerID].sound
                                    if not cs or cs == "" then
                                        tf.soundDropdown:SetText(L["None"])
                                    else
                                        tf.soundDropdown:SetText(cs)
                                    end
                                end

                                -- Position and show
                                tf:ClearAllPoints()
                                tf:SetPoint("TOPLEFT", triggersContent, "TOPLEFT", 20, currentY)
                                tf:Show()

                                currentY = currentY - 94
                            end
                        end
                    end

                    -- Hide triggers that are filtered out or collapsed
                    for _, triggerID in ipairs(availableTriggers) do
                        local isVisible = false
                        if not isCollapsed then
                            for _, fid in ipairs(filteredTriggers) do
                                if fid == triggerID then isVisible = true; break end
                            end
                        end
                        if not isVisible and triggerFrameCache[triggerID] then
                            triggerFrameCache[triggerID]:Hide()
                        end
                    end

                    currentY = currentY - 4  -- Category spacing
                end
            end
        end

        scrollChildren[3]:SetHeight(math.abs(currentY) + 20)
    end

    -- Connect search box to re-render
    searchBox:SetScript("OnTextChanged", function(self)
        searchText = self:GetText() or ""
        if searchText == "" then
            searchPlaceholder:Show()
        else
            searchPlaceholder:Hide()
        end
        RenderTriggers()
    end)

    -- Initial render
    RenderTriggers()

    -- ╭───────────────────────────────────────────────────────────────╮
    -- │                       About Tab Content                       │
    -- ╰───────────────────────────────────────────────────────────────╯
    y = -10

    _, y = CreateSectionHeader(aboutContent, L["About"], y)

    y = y - 20

    local aboutIcon = aboutContent:CreateTexture(nil, "ARTWORK")
    aboutIcon:SetSize(64, 64)
    aboutIcon:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutIcon:SetTexture(iconPath)
    y = y - 70

    local aboutTitle = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutTitle:SetText(Colors.iSP .. "iSoundPlayer|r " .. Colors.Green .. "v" .. iSP.Version .. "|r")
    y = y - 20

    local aboutAuthor = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutAuthor:SetText(L["CreatedBy"] .. "|cFF00FFFF" .. iSP.Author .. "|r")
    y = y - 16

    local aboutGameVer = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutGameVer:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutGameVer:SetText(iSP.GameVersionName or "")
    y = y - 20

    local aboutInfo = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutInfo:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    aboutInfo:SetWidth(500)
    aboutInfo:SetJustifyH("LEFT")
    aboutInfo:SetText(L["AboutInfo"] .. "\n\n" .. L["AboutInfoEarlyDev"])
    local aih = aboutInfo:GetStringHeight()
    if aih < 14 then aih = 14 end
    y = y - aih - 8

    -- Discord Section
    _, y = CreateSectionHeader(aboutContent, L["Discord"], y)
    y = y - 2

    local discordDesc = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    discordDesc:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordDesc:SetText(L["DiscordDesc"])
    y = y - 16

    local discordBox = CreateFrame("EditBox", nil, aboutContent, "InputBoxTemplate")
    discordBox:SetSize(280, 22)
    discordBox:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordBox:SetAutoFocus(false)
    discordBox:SetText(L["DiscordLink"])
    discordBox:SetFontObject(GameFontHighlight)
    discordBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordBox:SetScript("OnEditFocusLost", function(self)
        self:HighlightText(0, 0)
        self:SetText(L["DiscordLink"])
    end)
    discordBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y - 30

    -- Translations Section
    _, y = CreateSectionHeader(aboutContent, L["Translations"], y)
    y = y - 2

    local translatorText = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    translatorText:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    translatorText:SetText("|T" .. iSP.AddonPath .. "Images\\Locale\\ruRU.blp:16|t |cFFFFFF00ZamestoTV|r - " .. L["Russian"])
    y = y - 22

    -- Developer Section
    y = y - 4
    _, y = CreateSectionHeader(aboutContent, L["Developer"], y)

    local cbDebug
    cbDebug, y = CreateSettingsCheckbox(aboutContent, L["EnableDebugMode"],
        L["DescDebugMode"],
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
    _, y = CreateSectionHeader(iNIFInstalledFrame, L["INIFSettingsHeader"], y)
    local iNIFDesc
    iNIFDesc, y = CreateInfoText(iNIFInstalledFrame,
        L["INIFInstalledDesc"],
        y, "GameFontHighlight")
    y = y - 10
    local iNIFButton = CreateFrame("Button", nil, iNIFInstalledFrame, "UIPanelButtonTemplate")
    iNIFButton:SetSize(180, 28)
    iNIFButton:SetPoint("TOPLEFT", iNIFInstalledFrame, "TOPLEFT", 25, y)
    iNIFButton:SetText(L["INIFOpenSettings"])
    iNIFButton:SetScript("OnClick", function()
        local iNIFFrame = _G["iNIFSettingsFrame"]
        if iNIFFrame then
            local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
            iNIFFrame:ClearAllPoints()
            iNIFFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
            settingsFrame:Hide()
            iNIFFrame:Show()
        else
            print(L["DebugError"] .. L["INIFNotFound"])
        end
    end)

    -- iNIF Promo View
    local iNIFPromoFrame = CreateFrame("Frame", nil, iNIFContent)
    iNIFPromoFrame:SetAllPoints(iNIFContent)
    iNIFPromoFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iNIFPromoFrame, L["INIFPromoHeader"], y)
    local iNIFPromo
    iNIFPromo, y = CreateInfoText(iNIFPromoFrame,
        L["INIFPromoDesc"],
        y, "GameFontHighlight")
    y = y - 4
    local iNIFPromoLink
    iNIFPromoLink, y = CreateInfoText(iNIFPromoFrame,
        L["INIFPromoLink"],
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
    _, y = CreateSectionHeader(iWRInstalledFrame, L["IWRSettingsHeader"], y)
    local iWRDesc
    iWRDesc, y = CreateInfoText(iWRInstalledFrame,
        L["IWRInstalledDesc"],
        y, "GameFontHighlight")
    y = y - 10
    local iWRButton = CreateFrame("Button", nil, iWRInstalledFrame, "UIPanelButtonTemplate")
    iWRButton:SetSize(180, 28)
    iWRButton:SetPoint("TOPLEFT", iWRInstalledFrame, "TOPLEFT", 25, y)
    iWRButton:SetText(L["IWROpenSettings"])
    iWRButton:SetScript("OnClick", function()
        -- Access iWR settings frame via the iWR addon object
        local iWRFrame = _G.iWR and _G.iWR.SettingsFrame
        if iWRFrame then
            local point, _, relPoint, xOfs, yOfs = settingsFrame:GetPoint()
            iWRFrame:ClearAllPoints()
            iWRFrame:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
            settingsFrame:Hide()
            iWRFrame:Show()
        else
            print(L["DebugError"] .. L["IWRNotFound"])
        end
    end)

    -- iWR Promo View
    local iWRPromoFrame = CreateFrame("Frame", nil, iWRContent)
    iWRPromoFrame:SetAllPoints(iWRContent)
    iWRPromoFrame:Hide()  -- Start hidden

    y = -10
    _, y = CreateSectionHeader(iWRPromoFrame, L["IWRPromoHeader"], y)
    local iWRPromo
    iWRPromo, y = CreateInfoText(iWRPromoFrame,
        L["IWRPromoDesc"],
        y, "GameFontHighlight")
    y = y - 4
    local iWRPromoLink
    iWRPromoLink, y = CreateInfoText(iWRPromoFrame,
        L["IWRPromoLink"],
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

        -- Update iNIF tab button text
        if iNIFTabButton then
            iNIFTabButton.text:SetText(iNIFLoaded and L["TabINIF"] or L["TabINIFPromo"])
        end

        local iWRLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("iWillRemember")
        iWRInstalledFrame:SetShown(iWRLoaded)
        iWRPromoFrame:SetShown(not iWRLoaded)

        -- Update iWR tab button text
        if iWRTabButton then
            iWRTabButton.text:SetText(iWRLoaded and L["TabIWR"] or L["TabIWRPromo"])
        end
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
        -- Refresh sound channel dropdown + volume sliders
        if channelDropdown then
            local ch = iSPSettings.SoundChannel or "Master"
            UIDropDownMenu_SetText(channelDropdown, channelDisplayNames[ch] or ch)
        end
        if UpdateChannelVolumeSlider then
            UpdateChannelVolumeSlider()
        end
        if UpdateSoundfileVolumeSlider then
            UpdateSoundfileVolumeSlider()
        end
    end
end

-- ╭───────────────────────────────────────────────────────────────────────────────╮
-- │                          Toggle / Open / Close                                │
-- ╰───────────────────────────────────────────────────────────────────────────────╯

-- Close other addon settings panels when opening ours
local function CloseOtherAddonSettings()
    local iNIFFrame = _G["iNIFSettingsFrame"]
    if iNIFFrame and iNIFFrame:IsShown() then iNIFFrame:Hide() end

    -- iWR is an AceAddon global
    local iWRFrame = _G.iWR and _G.iWR.SettingsFrame
    if iWRFrame and iWRFrame:IsShown() then iWRFrame:Hide() end
end

function iSP:SettingsToggle()
    if iSP.State.InCombat then
        print(L["InCombat"])
        return
    end
    if iSP.SettingsFrame and iSP.SettingsFrame:IsVisible() then
        iSP.SettingsFrame:Hide()
    elseif iSP.SettingsFrame then
        CloseOtherAddonSettings()
        iSP.SettingsFrame:Show()
    end
end

function iSP:SettingsOpen()
    if iSP.State.InCombat then
        print(L["InCombat"])
        return
    end
    if iSP.SettingsFrame then
        CloseOtherAddonSettings()
        iSP.SettingsFrame:Show()
    end
end

function iSP:SettingsClose()
    if iSP.SettingsFrame then
        iSP.SettingsFrame:Hide()
    end
end
