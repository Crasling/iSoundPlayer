local addonName, addon = ...

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local Colors = {
    -- Addon Brand Color
    iSP = "|cffff9716",

    -- Standard Colors
    White = "|cFFFFFFFF",
    Black = "|cFF000000",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Blue = "|cFF0000FF",
    Yellow = "|cFFFFFF00",
    Cyan = "|cFF00FFFF",
    Magenta = "|cFFFF00FF",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",
    DarkGray = "|cFF404040",

    -- WoW Class Colors
    Classes = {
        WARRIOR = "|cFFC79C6E",
        PALADIN = "|cFFF58CBA",
        HUNTER = "|cFFABD473",
        ROGUE = "|cFFFFF569",
        PRIEST = "|cFFFFFFFF",
        SHAMAN = "|cFF0070DE",
        MAGE = "|cFF40C7EB",
        WARLOCK = "|cFF8788EE",
        DRUID = "|cFFFF7D0A",
        DEATHKNIGHT = "|cFFC41F3B",
        MONK = "|cFF00FF98",
        DEMONHUNTER = "|cFFA330C9",
        EVOKER = "|cFF33937F"
    },

    -- Reset Color
    Reset = "|r"
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Localization Table Setup                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local L = {}
addon.L = L
addon.Colors = Colors

-- Fallback: Return key if translation missing
setmetatable(L, {__index = function(t, k)
    return k
end})

-- Helper function for consistent message formatting
local function Msg(message)
    return Colors.iSP .. "[iSP]: " .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Debug Messages                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["PrintPrefix"] = Colors.iSP .. "[iSP]: "
L["DebugPrefix"] = Colors.iSP .. "[iSP]: "
L["DebugInfo"] = Colors.iSP .. "[iSP]: " .. Colors.White .. "INFO: " .. Colors.Reset .. Colors.iSP
L["DebugWarning"] = Colors.iSP .. "[iSP]: " .. Colors.Yellow .. "WARNING: " .. Colors.Reset .. Colors.iSP
L["DebugError"] = Colors.iSP .. "[iSP]: " .. Colors.Red .. "ERROR: " .. Colors.Reset .. Colors.iSP

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 General Messages                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["AddonLoaded"] = Msg(Colors.iSP .. "iSoundPlayer" .. Colors.Green .. " v%s" .. Colors.Reset .. " loaded!")
L["AddonEnabled"] = Msg("Addon enabled")
L["AddonDisabled"] = Msg("Addon disabled")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Sound Messages                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SoundPlaying"] = Msg("Playing sound: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["SoundTesting"] = Msg("Testing sound: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["SoundFailed"] = Msg(Colors.Red .. "Failed to play sound: %s" .. Colors.Reset)
L["SoundAdded"] = Msg(Colors.Green .. "Added sound: %s" .. Colors.Reset)
L["SoundAlreadyExists"] = Msg(Colors.Yellow .. "Sound already in list!" .. Colors.Reset)
L["SoundRemoved"] = Msg(Colors.Red .. "Removed sound: %s" .. Colors.Reset)
L["NoSoundSpecified"] = Msg(Colors.Red .. "No sound file specified!" .. Colors.Reset)
L["EnterFilenameFirst"] = Msg(Colors.Red .. "Enter a filename first!" .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Trigger Messages                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["TriggerActivated"] = Msg("Trigger activated: " .. Colors.Yellow .. "%s" .. Colors.Reset)
L["TriggerDisabled"] = Msg("Trigger " .. Colors.Yellow .. "%s" .. Colors.Reset .. " is disabled")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Options Panel - Tabs                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Tab1General"] = "General"
L["Tab2Sounds"] = "Sounds"
L["Tab3Triggers"] = "Triggers"
L["Tab4About"] = "About"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - General Tab                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["GeneralSettings"] = Colors.iSP .. "General Settings"
L["EnableAddon"] = "Enable iSoundPlayer"
L["DescEnableAddon"] = "Enable or disable the entire addon"
L["ShowNotifications"] = "Show Notifications"
L["DescShowNotifications"] = "Display chat messages when sounds are played"
L["MinimapSettings"] = Colors.iSP .. "Minimap Button"
L["ShowMinimapButton"] = "Show Minimap Button"
L["DescShowMinimapButton"] = "Show or hide the minimap button"
L["ResetSettings"] = Colors.iSP .. "Reset Settings"
L["ResetToDefaults"] = "Reset to Defaults"
L["ResetConfirm"] = "Reset all settings to defaults?"
L["SettingsResetSuccess"] = Msg(Colors.Green .. "Settings reset to defaults!" .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - Sounds Tab                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SoundFiles"] = Colors.iSP .. "Sound Files"
L["SoundFilesInfo"] = Colors.Gray .. "Place your MP3 or OGG files in the 'sounds' folder inside the addon directory.\n\nPath: " .. Colors.White .. "Interface\\AddOns\\iSoundPlayer\\sounds\\\n\n" .. Colors.Red .. "IMPORTANT: " .. Colors.Gray .. "You must restart WoW after adding new sound files!" .. Colors.Reset
L["AddSoundFile"] = Colors.iSP .. "Add Sound File"
L["FilenameLabel"] = "Filename (e.g., mysound.mp3):"
L["AddSound"] = "Add Sound"
L["TestSound"] = "Test Sound"
L["RegisteredSounds"] = Colors.iSP .. "Registered Sounds"
L["NoSoundsRegistered"] = Colors.Gray .. "No sound files registered yet." .. Colors.Reset
L["RemoveSound"] = "Remove"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Options Panel - Triggers Tab                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Triggers"] = Colors.iSP .. "Triggers"
L["TriggersInfo"] = Colors.Gray .. "Configure when sounds should play. Connect in-game events to your sound files." .. Colors.Reset
L["AvailableTriggers"] = Colors.iSP .. "Available Triggers"
L["EnableTrigger"] = "Enable"
L["SelectSound"] = "Select Sound..."
L["NoSound"] = "No Sound"

-- Trigger Names
L["TriggerPlayerLogin"] = "Player Login"
L["TriggerPlayerLevelUp"] = "Level Up"
L["TriggerPlayerDead"] = "Player Death"
L["TriggerEnterCombat"] = "Enter Combat"
L["TriggerExitCombat"] = "Exit Combat"
L["TriggerAchievement"] = "Achievement"
L["TriggerQuestComplete"] = "Quest Complete"

-- PvP Trigger Names
L["TriggerPvPHonorableKill"] = "Honorable Kill"
L["TriggerPvPDoubleKill"] = "Double Kill"
L["TriggerPvPTripleKill"] = "Triple Kill"
L["TriggerPvPMultiKill"] = "Multi Kill"
L["TriggerPvPKillingSpree"] = "Killing Spree"
L["TriggerPvPDominating"] = "Dominating"
L["TriggerPvPUnstoppable"] = "Unstoppable"
L["TriggerPvPGodlike"] = "Godlike"

-- Trigger Descriptions
L["DescTriggerPlayerLogin"] = "When you log into the game"
L["DescTriggerPlayerLevelUp"] = "When you gain a level"
L["DescTriggerPlayerDead"] = "When your character dies"
L["DescTriggerEnterCombat"] = "When you enter combat"
L["DescTriggerExitCombat"] = "When you exit combat"
L["DescTriggerAchievement"] = "When you earn an achievement"
L["DescTriggerQuestComplete"] = "When you complete a quest"

-- PvP Trigger Descriptions
L["DescTriggerPvPHonorableKill"] = "When you get an honorable kill"
L["DescTriggerPvPDoubleKill"] = "When you kill 2 players within 10 seconds"
L["DescTriggerPvPTripleKill"] = "When you kill 3 players within 10 seconds"
L["DescTriggerPvPMultiKill"] = "When you kill 4+ players within 10 seconds"
L["DescTriggerPvPKillingSpree"] = "When you reach 5 kills without dying"
L["DescTriggerPvPDominating"] = "When you reach 10 kills without dying"
L["DescTriggerPvPUnstoppable"] = "When you reach 15 kills without dying"
L["DescTriggerPvPGodlike"] = "When you reach 20+ kills without dying"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Options Panel - About Tab                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["About"] = Colors.iSP .. "About"
L["CreatedBy"] = "Created by "
L["AboutInfo"] = "Play custom MP3 files at specific triggers in World of Warcraft.\n\nEarly development version."
L["Developer"] = Colors.iSP .. "Developer"
L["EnableDebugMode"] = "Enable Debug Mode"
L["DescDebugMode"] = Colors.Gray .. "Enables verbose debug messages in chat." .. Colors.Reset

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Advanced Sound Options                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["AdvancedOptions"] = Colors.iSP .. "Advanced Options"
L["Duration"] = "Duration (seconds)"
L["DescDuration"] = Colors.Gray .. "How long to play the sound. 0 = full sound" .. Colors.Reset
L["StartOffset"] = "Start Delay (seconds)"
L["DescStartOffset"] = Colors.Gray .. "Delay before playing. Note: Cannot seek into audio file" .. Colors.Reset
L["Loop"] = "Loop Sound"
L["DescLoop"] = Colors.Gray .. "Repeat the sound playback" .. Colors.Reset
L["LoopCount"] = "Loop Count"
L["DescLoopCount"] = Colors.Gray .. "How many times to repeat (1 = once, 2 = twice, etc.)" .. Colors.Reset
L["FadeIn"] = "Fade In"
L["DescFadeIn"] = Colors.Gray .. "Gradually increase volume (not supported by WoW API)" .. Colors.Reset
L["FadeOut"] = "Fade Out"
L["DescFadeOut"] = Colors.Gray .. "Gradually decrease volume (not supported by WoW API)" .. Colors.Reset
L["StopSound"] = "Stop Sound"
L["StopAllSounds"] = "Stop All Sounds"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Popup Dialogs                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["Yes"] = "Yes"
L["No"] = "No"
L["Confirm"] = "Confirm"
L["Cancel"] = "Cancel"
L["InCombat"] = Msg("Cannot be used in combat.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Options Panel - Sidebar                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SidebarHeaderiSP"] = Colors.iSP .. "iSoundPlayer|r"
L["SidebarHeaderOtherAddons"] = Colors.iSP .. "Other Addons|r"
L["TabINIF"] = "iNIF Settings"
L["TabINIFPromo"] = "iNeedIfYouNeed"
L["TabIWR"] = "iWR Settings"
L["TabIWRPromo"] = "iWillRemember"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Options Panel - Interface                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["InterfaceSettings"] = Colors.iSP .. "Interface"
L["SettingsHeader"] = Colors.iSP .. "Settings"
L["GeneralInfo"] = Colors.Gray .. "iSoundPlayer allows you to play custom MP3 files at specific triggers." .. Colors.Reset
L["SoundFilesInfoShort"] = Colors.Gray .. "Place your MP3 or OGG files in:|r\n" .. Colors.White .. "Interface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n" .. Colors.iSP .. "Sample Sounds:|r " .. Colors.Gray .. "Browse the iSoundPlayer\\_Samples folder, copy your favorites to the sounds folder, then register them here using their filename. Test before assigning!|r\n\n" .. Colors.iSP .. "IMPORTANT:|r " .. Colors.Gray .. "Use /reload after adding files (no restart needed)" .. Colors.Reset
L["FilenameInputLabel"] = Colors.White .. "Filename:|r " .. Colors.Gray .. "(e.g., mysound or mysound.mp3)" .. Colors.Reset
L["TestBtn"] = "Test"
L["SoundLabel"] = "Sound:"
L["None"] = "None"
L["NoSoundsWarning"] = "No sounds registered! Add sounds in the Sounds tab first."
L["NoSoundSelected"] = "No sound selected for this trigger!"
L["TriggerDataError"] = Colors.Red .. "Trigger data not loaded!" .. Colors.Reset
L["Enabled"] = "Enabled"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Options Panel - Other Addons                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["INIFSettingsHeader"] = Colors.iSP .. "iNeedIfYouNeed Settings"
L["INIFInstalledDesc"] = Colors.iSP .. "iNeedIfYouNeed" .. Colors.Reset .. " is installed! You can access iNIF settings from here.\n\n" .. Colors.Gray .. "Note: These settings are managed by iNIF and will affect the iNIF addon." .. Colors.Reset
L["INIFOpenSettings"] = "Open iNIF Settings"
L["INIFNotFound"] = "iNIF settings not found!"
L["INIFPromoHeader"] = Colors.iSP .. "iNeedIfYouNeed"
L["INIFPromoDesc"] = Colors.iSP .. "iNeedIfYouNeed" .. Colors.Reset .. " is a smart looting addon. It automatically rolls Need when party members need items, otherwise Greeds. Never miss the chance on random BoE loot that should have been greeded by all.\n\n" .. Colors.Reset .. "Simple checkbox on loot frames — check it and click Greed to enable monitoring."
L["INIFPromoLink"] = "Available on the CurseForge App and at curseforge.com/wow/addons/ineedifyouneed"
L["IWRSettingsHeader"] = Colors.iSP .. "iWillRemember Settings"
L["IWRInstalledDesc"] = Colors.iSP .. "iWillRemember" .. Colors.Reset .. " is installed! You can access iWR settings from here.\n\n" .. Colors.Gray .. "Note: These settings are managed by iWR and will affect the iWR addon." .. Colors.Reset
L["IWROpenSettings"] = "Open iWR Settings"
L["IWRNotFound"] = "iWR settings not found!"
L["IWRPromoHeader"] = Colors.iSP .. "iWillRemember"
L["IWRPromoDesc"] = Colors.iSP .. "iWillRemember" .. Colors.Reset .. " is an addon designed to help you track and easily share player notes with friends.\n\n" .. Colors.Reset .. "Keep notes on players you meet — who to avoid, who's reliable, and share this knowledge with your guild."
L["IWRPromoLink"] = "Available on the CurseForge App and at curseforge.com/wow/addons/iwillremember"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Minimap Tooltip                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["MinimapTooltipLeftClick"] = Colors.Yellow .. "Left Click: " .. Colors.Orange .. "Setup Guide"
L["MinimapTooltipRightClick"] = Colors.Yellow .. "Right Click: " .. Colors.Orange .. "Open Settings"
L["MinimapTooltipStatus"] = Colors.Yellow .. "Status: " .. Colors.Reset
L["StatusEnabled"] = Colors.Green .. "Enabled" .. Colors.Reset
L["StatusDisabled"] = Colors.Red .. "Disabled" .. Colors.Reset
L["MinimapTooltipSounds"] = Colors.Yellow .. "Sounds: " .. Colors.Orange .. "%d registered"
L["MinimapTooltipTriggers"] = Colors.Yellow .. "Triggers: " .. Colors.Orange .. "%d enabled"
L["MinimapHidden"] = "Minimap button hidden"
L["MinimapShown"] = "Minimap button shown"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Setup Guide                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SetupGuideHeader"] = Colors.iSP .. "iSoundPlayer Setup Guide|r"
L["SetupGuideWelcome"] = Colors.iSP .. "Welcome to iSoundPlayer!|r\n\n" .. Colors.White .. "This addon lets you play custom MP3 or OGG sound files when game events happen.|r"
L["SetupGuideStep1Header"] = Colors.iSP .. "Step 1: Add Your Sound Files|r"
L["SetupGuideStep1Text"] = Colors.White .. "1. Navigate to your WoW folder:|r\n" .. Colors.Gray .. "   Interface\\AddOns\\iSoundPlayer\\sounds\\|r\n\n" .. Colors.White .. "2. Place your MP3 or OGG files in the sounds folder|r\n\n" .. Colors.White .. "3. Type |r" .. Colors.iSP .. "/reload|r " .. Colors.White .. "in chat (no restart needed)|r\n\n" .. Colors.iSP .. "Sample Sounds:|r " .. Colors.Gray .. "Find samples you like in the iSoundPlayer_Samples folder, copy them into the sounds folder, then use their filename when registering sounds in-game. Test them before assigning to triggers!|r"
L["SetupGuideStep2Header"] = Colors.iSP .. "Step 2: Register Your Sounds|r"
L["SetupGuideStep2Text"] = Colors.White .. "1. Open Settings by typing |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "or clicking the minimap icon|r\n\n" .. Colors.White .. "2. Go to the |r" .. Colors.iSP .. "Sound Files|r " .. Colors.White .. "tab|r\n\n" .. Colors.White .. "3. Enter a name for your sound and select the file from the dropdown|r\n\n" .. Colors.White .. "4. Click |r" .. Colors.Green .. "Register Sound|r " .. Colors.White .. "to add it to your library|r\n\n" .. Colors.White .. "5. Use the |r" .. Colors.Yellow .. "Test Sound|r " .. Colors.White .. "button to preview it|r"
L["SetupGuideStep3Header"] = Colors.iSP .. "Step 3: Configure Triggers|r"
L["SetupGuideStep3Text"] = Colors.White .. "1. Go to the |r" .. Colors.iSP .. "Triggers|r " .. Colors.White .. "tab|r\n\n" .. Colors.White .. "2. Browse through categories like:|r\n" .. Colors.Gray .. "   • Player Events (login, level up, death)|r\n" .. Colors.Gray .. "   • Combat Events (enter/exit combat)|r\n" .. Colors.Gray .. "   • PvP Events (kills, sprees)|r\n" .. Colors.Gray .. "   • And many more!|r\n\n" .. Colors.White .. "3. Enable a trigger and assign a registered sound to it|r\n\n" .. Colors.White .. "4. Customize playback options (loop, fade, etc.)|r"
L["SetupGuideQuickTipsHeader"] = Colors.iSP .. "Quick Tips|r"
L["SetupGuideQuickTipsText"] = Colors.iSP .. "•|r " .. Colors.White .. "Use |r" .. Colors.Yellow .. "/isp|r " .. Colors.White .. "to open settings|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Left-click minimap icon to open this guide|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Right-click minimap icon to open settings|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Always |r" .. Colors.Yellow .. "/reload|r " .. Colors.White .. "after adding new sound files|r\n\n" .. Colors.iSP .. "•|r " .. Colors.White .. "Check the |r" .. Colors.iSP .. "General|r " .. Colors.White .. "tab to enable/disable the addon|r"
L["SetupGuideDontShow"] = Colors.Gray .. "Don't show on startup|r"
L["SetupGuideOpenSettings"] = Colors.iSP .. "Open Settings|r"
L["SetupGuideClose"] = Colors.Red .. "Close|r"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Slash Commands                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SlashHelp"] = Colors.iSP .. "iSoundPlayer " .. Colors.White .. "v%s\n" ..
                Colors.Yellow .. "Commands:\n" ..
                Colors.Green .. "  /isp settings" .. Colors.White .. " - Open settings\n" ..
                Colors.Green .. "  /isp enable" .. Colors.White .. " - Enable addon\n" ..
                Colors.Green .. "  /isp disable" .. Colors.White .. " - Disable addon"
