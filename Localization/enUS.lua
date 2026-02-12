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
    return Colors.iSP .. "[iSP]: " .. Colors.Reset .. message
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

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Slash Commands                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
L["SlashHelp"] = Colors.iSP .. "iSoundPlayer " .. Colors.White .. "v%s\n" ..
                Colors.Yellow .. "Commands:\n" ..
                Colors.Green .. "  /isp settings" .. Colors.White .. " - Open settings\n" ..
                Colors.Green .. "  /isp enable" .. Colors.White .. " - Enable addon\n" ..
                Colors.Green .. "  /isp disable" .. Colors.White .. " - Disable addon"
