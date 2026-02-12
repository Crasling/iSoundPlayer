local addonName, iSP = ...
local L = iSP.L or {}
local Colors = iSP.Colors or {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Setup Guide Window                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local setupGuideFrame = nil

-- Create the setup guide window
function iSP:CreateSetupGuide()
    if setupGuideFrame then
        return setupGuideFrame
    end

    -- Main frame
    setupGuideFrame = CreateFrame("Frame", "iSPSetupGuide", UIParent, "BackdropTemplate")
    setupGuideFrame:SetSize(520, 480)
    setupGuideFrame:SetPoint("CENTER")
    setupGuideFrame:SetFrameStrata("DIALOG")
    setupGuideFrame:SetMovable(true)
    setupGuideFrame:EnableMouse(true)
    setupGuideFrame:RegisterForDrag("LeftButton")
    setupGuideFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    setupGuideFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    setupGuideFrame:Hide()

    -- Backdrop
    setupGuideFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 8, right = 8, top = 8, bottom = 8}
    })

    -- Header
    local header = setupGuideFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOP", 0, -20)
    header:SetText(Colors.iSP .. "iSoundPlayer Setup Guide|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, setupGuideFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)

    -- Content scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, setupGuideFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(450, 600)
    scrollFrame:SetScrollChild(scrollChild)

    -- Content
    local yOffset = -10

    -- Welcome text
    local welcomeText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    welcomeText:SetPoint("TOPLEFT", 10, yOffset)
    welcomeText:SetWidth(430)
    welcomeText:SetJustifyH("LEFT")
    welcomeText:SetText(Colors.iSP .. "Welcome to iSoundPlayer!|r\n\n" ..
        Colors.White .. "This addon lets you play custom MP3 or OGG sound files when game events happen.|r")
    yOffset = yOffset - 80

    -- Step 1
    local step1Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step1Header:SetPoint("TOPLEFT", 10, yOffset)
    step1Header:SetText(Colors.iSP .. "Step 1: Add Your Sound Files|r")
    yOffset = yOffset - 25

    local step1Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step1Text:SetPoint("TOPLEFT", 20, yOffset)
    step1Text:SetWidth(420)
    step1Text:SetJustifyH("LEFT")
    step1Text:SetText(
        Colors.White .. "1. Navigate to your WoW folder:|r\n" ..
        Colors.Gray .. "   Interface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n" ..
        Colors.White .. "2. Place your MP3 or OGG files in the sounds folder|r\n\n" ..
        Colors.White .. "3. Type |r" .. Colors.iSP .. "/reload|r " .. Colors.White .. "in chat (no restart needed)|r\n\n" ..
        Colors.iSP .. "Sample Sounds:|r " .. Colors.Gray .. "Find samples you like in the iSoundPlayer_Samples folder, copy them into the sounds folder, then use their filename when registering sounds in-game. Test them before assigning to triggers!|r"
    )
    yOffset = yOffset - 175

    -- Separator
    local sep1 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep1:SetPoint("TOPLEFT", 10, yOffset)
    sep1:SetSize(430, 1)
    sep1:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Step 2
    local step2Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step2Header:SetPoint("TOPLEFT", 10, yOffset)
    step2Header:SetText(Colors.iSP .. "Step 2: Register Your Sounds|r")
    yOffset = yOffset - 25

    local step2Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step2Text:SetPoint("TOPLEFT", 20, yOffset)
    step2Text:SetWidth(420)
    step2Text:SetJustifyH("LEFT")
    step2Text:SetText(
        Colors.White .. "1. Open Settings by typing |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "or clicking the minimap icon|r\n\n" ..
        Colors.White .. "2. Go to the |r" .. Colors.iSP .. "Sound Files|r " .. Colors.White .. "tab|r\n\n" ..
        Colors.White .. "3. Enter a name for your sound and select the file from the dropdown|r\n\n" ..
        Colors.White .. "4. Click |r" .. Colors.Green .. "Register Sound|r " .. Colors.White .. "to add it to your library|r\n\n" ..
        Colors.White .. "5. Use the |r" .. Colors.Yellow .. "Test Sound|r " .. Colors.White .. "button to preview it|r"
    )
    yOffset = yOffset - 155

    -- Separator
    local sep2 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep2:SetPoint("TOPLEFT", 10, yOffset)
    sep2:SetSize(430, 1)
    sep2:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Step 3
    local step3Header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    step3Header:SetPoint("TOPLEFT", 10, yOffset)
    step3Header:SetText(Colors.iSP .. "Step 3: Configure Triggers|r")
    yOffset = yOffset - 25

    local step3Text = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step3Text:SetPoint("TOPLEFT", 20, yOffset)
    step3Text:SetWidth(420)
    step3Text:SetJustifyH("LEFT")
    step3Text:SetText(
        Colors.White .. "1. Go to the |r" .. Colors.iSP .. "Triggers|r " .. Colors.White .. "tab|r\n\n" ..
        Colors.White .. "2. Browse through categories like:|r\n" ..
        Colors.Gray .. "   • Player Events (login, level up, death)|r\n" ..
        Colors.Gray .. "   • Combat Events (enter/exit combat)|r\n" ..
        Colors.Gray .. "   • PvP Events (kills, sprees)|r\n" ..
        Colors.Gray .. "   • And many more!|r\n\n" ..
        Colors.White .. "3. Enable a trigger and assign a registered sound to it|r\n\n" ..
        Colors.White .. "4. Customize playback options (loop, fade, etc.)|r"
    )
    yOffset = yOffset - 200

    -- Separator
    local sep3 = scrollChild:CreateTexture(nil, "ARTWORK")
    sep3:SetPoint("TOPLEFT", 10, yOffset)
    sep3:SetSize(430, 1)
    sep3:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    yOffset = yOffset - 15

    -- Quick Tips
    local tipsHeader = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tipsHeader:SetPoint("TOPLEFT", 10, yOffset)
    tipsHeader:SetText(Colors.iSP .. "Quick Tips|r")
    yOffset = yOffset - 25

    local tipsText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tipsText:SetPoint("TOPLEFT", 20, yOffset)
    tipsText:SetWidth(420)
    tipsText:SetJustifyH("LEFT")
    tipsText:SetText(
        Colors.iSP .. "•|r " .. Colors.White .. "Use |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "to open settings|r\n\n" ..
        Colors.iSP .. "•|r " .. Colors.White .. "Left-click minimap icon to open this guide|r\n\n" ..
        Colors.iSP .. "•|r " .. Colors.White .. "Right-click minimap icon to open settings|r\n\n" ..
        Colors.iSP .. "•|r " .. Colors.White .. "Always |r" .. Colors.Yellow .. "/reload|r " .. Colors.White .. "after adding new sound files|r\n\n" ..
        Colors.iSP .. "•|r " .. Colors.White .. "Check the |r" .. Colors.iSP .. "General|r " .. Colors.White .. "tab to enable/disable the addon|r"
    )
    yOffset = yOffset - 165

    -- Bottom buttons
    local buttonContainer = CreateFrame("Frame", nil, setupGuideFrame)
    buttonContainer:SetPoint("BOTTOM", 0, 15)
    buttonContainer:SetSize(480, 30)

    -- Don't Show Again checkbox (centered in middle area)
    local dontShowAgain = CreateFrame("CheckButton", nil, buttonContainer, "UICheckButtonTemplate")
    dontShowAgain:SetPoint("CENTER", -60, 0)
    dontShowAgain:SetSize(24, 24)

    local dontShowText = buttonContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dontShowText:SetPoint("LEFT", dontShowAgain, "RIGHT", 5, 0)
    dontShowText:SetText(Colors.Gray .. "Don't show on startup|r")

    -- Open Settings button (left side)
    local openSettingsBtn = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    openSettingsBtn:SetSize(150, 25)
    openSettingsBtn:SetPoint("LEFT", 20, 0)
    openSettingsBtn:SetText(Colors.iSP .. "Open Settings|r")
    openSettingsBtn:SetScript("OnClick", function()
        setupGuideFrame:Hide()
        iSP:SettingsToggle()
    end)

    dontShowAgain:SetScript("OnClick", function(self)
        iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}
        iSPSettings.SetupGuide.DontShowOnStartup = self:GetChecked()
    end)

    -- Close button
    local closeButton = CreateFrame("Button", nil, buttonContainer, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 25)
    closeButton:SetPoint("RIGHT", -20, 0)
    closeButton:SetText(Colors.Red .. "Close|r")
    closeButton:SetScript("OnClick", function()
        setupGuideFrame:Hide()
    end)

    return setupGuideFrame
end

-- Show the setup guide
function iSP:ShowSetupGuide()
    if not setupGuideFrame then
        self:CreateSetupGuide()
    end

    -- Update checkbox state
    local dontShowAgain = setupGuideFrame:GetChildren()
    for i = 1, setupGuideFrame:GetNumChildren() do
        local child = select(i, setupGuideFrame:GetChildren())
        if child.GetChildren then
            for j = 1, child:GetNumChildren() do
                local grandchild = select(j, child:GetChildren())
                if grandchild:GetObjectType() == "CheckButton" then
                    iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}
                    grandchild:SetChecked(iSPSettings.SetupGuide.DontShowOnStartup or false)
                end
            end
        end
    end

    setupGuideFrame:Show()
end

-- Hide the setup guide
function iSP:HideSetupGuide()
    if setupGuideFrame then
        setupGuideFrame:Hide()
    end
end

-- Check if we should show the guide on startup
function iSP:CheckShowSetupGuideOnStartup()
    iSPSettings.SetupGuide = iSPSettings.SetupGuide or {}

    -- Don't show if user has disabled it
    if iSPSettings.SetupGuide.DontShowOnStartup then
        return
    end

    -- Show if no sounds are registered
    local soundCount = iSPSettings.SoundFiles and #iSPSettings.SoundFiles or 0
    if soundCount == 0 then
        -- Delay showing to let the UI fully load
        C_Timer.After(2, function()
            iSP:ShowSetupGuide()
        end)
    end
end
