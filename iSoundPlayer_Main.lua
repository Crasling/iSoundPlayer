-- ═════════════════════════════════════════════════════════════════════════════════════════════════════════
-- ██╗ ███████╗ ██████╗  ██╗   ██╗ ███╗   ██╗ ██████╗  ██████╗  ██╗      █████╗  ██╗   ██╗ ███████╗ ██████╗
-- ██║ ██╔════╝██╔═══██╗ ██║   ██║ ████╗  ██║ ██╔══██╗ ██╔══██╗ ██║     ██╔══██╗ ╚██╗ ██╔╝ ██╔════╝ ██╔══██╗
-- ██║ ███████╗██║   ██║ ██║   ██║ ██╔██╗ ██║ ██║  ██║ ██████╔╝ ██║     ███████║  ╚████╔╝  █████╗   ██████╔╝
-- ██║ ╚════██║██║   ██║ ██║   ██║ ██║╚██╗██║ ██║  ██║ ██╔═══╝  ██║     ██╔══██║   ╚██╔╝   ██╔══╝   ██╔══██╗
-- ██║ ███████║╚██████╔╝ ╚██████╔╝ ██║ ╚████║ ██████╔╝ ██║      ███████╗██║  ██║    ██║    ███████╗ ██║  ██║
-- ╚═╝ ╚══════╝ ╚═════╝   ╚═════╝  ╚═╝  ╚═══╝ ╚═════╝  ╚═╝      ╚══════╝╚═╝  ╚═╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝
-- ═════════════════════════════════════════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Namespace                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local addonName, iSP = ...
local Title = select(2, C_AddOns.GetAddOnInfo(addonName)):gsub("%s*v?[%d%.]+$", "")
local Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
local Author = C_AddOns.GetAddOnMetadata(addonName, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Localization                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local L = iSP.L or {}
local Colors = iSP.Colors or {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Chat Output Routing                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
function iSP:PrintToChat(...)
    local msg = table.concat({tostringall(...)}, " ")
    if ChatFrame1 then ChatFrame1:AddMessage(msg) end
    local frames = iSPSettings and iSPSettings.ChatFrames or {}
    for i = 2, NUM_CHAT_WINDOWS do
        if frames[i] then
            local cf = _G["ChatFrame" .. i]
            if cf then cf:AddMessage(msg) end
        end
    end
end

local print = function(...) iSP:PrintToChat(...) end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Libraries                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local LDBroker = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Addon Metadata                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.Title = Title
iSP.Version = Version
iSP.Author = Author
iSP.CurrentRealm = GetRealmName()
iSP.AddonPath = "Interface\\Addons\\iSoundPlayer\\"
iSP.SoundsPath = iSP.AddonPath .. "sounds\\"
iSP.CustomSoundsPath = "Interface\\AddOns\\iSoundPlayer_Sounds\\"

-- Game version info
iSP.GameVersion, iSP.GameBuild, iSP.GameBuildDate, iSP.GameTocVersion = GetBuildInfo()
iSP.GameVersionName = ""

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Constants                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.CONSTANTS = {
    -- Sound Limits
    MAX_SOUND_NAME_LENGTH = 100,
    MIN_SOUND_NAME_LENGTH = 3,

    -- Trigger Limits
    MAX_TRIGGERS = 100,

    -- Volume
    MIN_VOLUME = 0.0,
    MAX_VOLUME = 1.0,
    DEFAULT_VOLUME = 1.0,
}

iSP.ChannelCVars = {
    Master = "Sound_MasterVolume",
    SFX = "Sound_SFXVolume",
    Music = "Sound_MusicVolume",
    Ambience = "Sound_AmbienceVolume",
    Dialog = "Sound_DialogVolume",
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Runtime State                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.State = {
    InCombat = false,
    CurrentlyPlaying = nil,
    LastPlayedTime = 0,

    -- PvP Kill Tracking
    PvP = {
        Kills = {},              -- Track kill timestamps for multi-kill detection
        KillStreak = 0,          -- Current killing spree count
        LastKillTime = 0,        -- Timestamp of last kill
        MultiKillWindow = 10,    -- Seconds window for multi-kill (Double, Triple, etc.)
        KillStreakWindow = 60,   -- Seconds window for killing spree to break
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Default Settings                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
iSP.SettingsDefault = {
    -- General
    Enabled = true,
    ShowNotifications = false,
    DebugMode = false,
    SoundChannel = "Master",
    iSPVolume = 100,

    -- Minimap
    MinimapButton = {
        hide = false,
        minimapPos = -30
    },

    -- Sound
    SoundFiles = {},
    SoundDurations = {},  -- Per-sound test duration in seconds (keyed by filename)
    SoundNames = {},      -- Custom display names for sounds (keyed by filename)

    -- Triggers
    Triggers = {
        -- Trigger defaults are auto-filled from TriggerMeta in InitializeSettings()
        -- Explicit defaults below serve as documentation and initial values

        -- Player Events
        PLAYER_LOGIN = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_LEVEL_UP = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_DEAD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_ALIVE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_UNGHOST = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_XP_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_MONEY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_CONTROL_LOST = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_CONTROL_GAINED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_EQUIPMENT_CHANGED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_STARTED_MOVING = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_STOPPED_MOVING = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Combat Events
        PLAYER_REGEN_DISABLED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_REGEN_ENABLED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_TARGET_CHANGED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        UNIT_SPELLCAST_START = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        UNIT_SPELLCAST_SUCCEEDED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        UNIT_SPELLCAST_INTERRUPTED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        UPDATE_SHAPESHIFT_FORM = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Achievement & Quest Events
        ACHIEVEMENT_EARNED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_COMPLETE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_ACCEPTED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_TURNED_IN = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CRITERIA_COMPLETE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        QUEST_LOG_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Loot & Items
        LOOT_READY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        LOOT_OPENED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        LOOT_CLOSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_LOOT = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_MONEY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        START_LOOT_ROLL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ENCOUNTER_LOOT_RECEIVED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Group & Social
        GROUP_JOINED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        GROUP_LEFT = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        GROUP_ROSTER_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        READY_CHECK = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        READY_CHECK_CONFIRM = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PARTY_INVITE_REQUEST = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PARTY_LEADER_CHANGED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_WHISPER = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_GUILD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_PARTY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_RAID = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        FRIENDLIST_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        GUILD_MOTD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PLAYER_GUILD_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Dungeon & Raid
        PLAYER_ENTERING_WORLD = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ZONE_CHANGED_NEW_AREA = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ENCOUNTER_START = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        ENCOUNTER_END = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        BOSS_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        INSTANCE_LOCK_WARNING = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHALLENGE_MODE_COMPLETED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- PvP Events
        PVP_HONORABLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_DOUBLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_TRIPLE_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_MULTI_KILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_KILLING_SPREE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_DOMINATING = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_UNSTOPPABLE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PVP_GODLIKE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Profession & Crafting
        TRADE_SHOW = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        TRADE_CLOSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        TRADE_ACCEPT_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CHAT_MSG_SKILL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Economy & Mail
        MAIL_SHOW = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        MAIL_CLOSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        MAIL_INBOX_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        MAIL_SEND_SUCCESS = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        UPDATE_PENDING_MAIL = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        AUCTION_HOUSE_SHOW = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        AUCTION_HOUSE_CLOSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- Pet & Mount
        PET_BATTLE_OPENING_START = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PET_BATTLE_CLOSE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PET_SUMMONED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PET_DISMISSED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        PET_DIED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },

        -- UI & System
        UPDATE_INVENTORY_DURABILITY = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        BAG_UPDATE = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        CALENDAR_UPDATE_PENDING_INVITES = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
        TRANSMOG_COLLECTION_UPDATED = { enabled = false, sound = "", duration = 0, startOffset = 0, loop = false, loopCount = 1, fadeIn = false, fadeOut = false },
    },

    -- Chat Output Routing
    ChatFrames = {},
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Saved Variables                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
if not iSPSettings then
    iSPSettings = {}
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Game Version Detection                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
local gameTocNumber = tonumber(iSP.GameTocVersion) or 0
if gameTocNumber >= 120000 then
    iSP.GameVersionName = "Retail WoW"
elseif gameTocNumber > 50000 and gameTocNumber < 59999 then
    iSP.GameVersionName = "Classic MoP"
elseif gameTocNumber > 40000 and gameTocNumber < 49999 then
    iSP.GameVersionName = "Classic Cata"
elseif gameTocNumber > 30000 and gameTocNumber < 39999 then
    iSP.GameVersionName = "Classic WotLK"
elseif gameTocNumber > 20000 and gameTocNumber < 29999 then
    iSP.GameVersionName = "Classic TBC"
elseif gameTocNumber > 10000 and gameTocNumber < 19999 then
    iSP.GameVersionName = "Classic Era"
else
    iSP.GameVersionName = "Unknown Version"
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Initialization Functions                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:InitializeSettings()
    if not iSPSettings then
        iSPSettings = {}
    end

    -- Fill in missing settings with defaults
    for key, value in pairs(iSP.SettingsDefault) do
        if iSPSettings[key] == nil then
            if type(value) == "table" then
                iSPSettings[key] = CopyTable(value)
            else
                iSPSettings[key] = value
            end
        end
    end

    -- Ensure nested tables exist
    if not iSPSettings.MinimapButton then
        iSPSettings.MinimapButton = CopyTable(iSP.SettingsDefault.MinimapButton)
    end

    if not iSPSettings.Triggers then
        iSPSettings.Triggers = CopyTable(iSP.SettingsDefault.Triggers)
    end

    if not iSPSettings.SoundFiles then
        iSPSettings.SoundFiles = {}
    end

    if not iSPSettings.SoundNames then
        iSPSettings.SoundNames = {}
    end

    if not iSPSettings.CooldownAlerts then
        iSPSettings.CooldownAlerts = {}
    end

    if not iSPSettings.AuraAlerts then
        iSPSettings.AuraAlerts = {}
    end

    -- Auto-fill defaults for any triggers in TriggerMeta not yet in saved settings
    -- Handles upgrades from older versions that didn't have new triggers
    if iSP.TriggerMeta then
        local defaultTrigger = {
            enabled = false, sound = "", duration = 0, startOffset = 0,
            loop = false, loopCount = 1, fadeIn = false, fadeOut = false,
            announce = ""
        }
        for triggerID, _ in pairs(iSP.TriggerMeta) do
            if not iSPSettings.Triggers[triggerID] then
                iSPSettings.Triggers[triggerID] = CopyTable(defaultTrigger)
            else
                -- Ensure announce field exists for existing triggers (upgrade path)
                if iSPSettings.Triggers[triggerID].announce == nil then
                    iSPSettings.Triggers[triggerID].announce = ""
                end
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Debug Function                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
-- Debug message function with levels
-- Level 1 = ERROR (red)
-- Level 2 = WARNING (yellow)
-- Level 3 = INFO (white) - default
local function Debug(msg, level)
    if iSPSettings.DebugMode then
        level = level or 3 -- Default to INFO

        if level == 1 then
            print(L["DebugError"] .. msg)
        elseif level == 2 then
            print(L["DebugWarning"] .. msg)
        else
            print(L["DebugInfo"] .. msg)
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Sound Functions                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Active sound timers for managing playback
iSP.ActiveSounds = {}
iSP.TriggerLastFired = {}  -- Cooldown tracking: triggerID -> GetTime()
iSP.EventToTriggers = {}   -- Lookup: WoW event -> {triggerID, ...}
iSP.CooldownStates = {}    -- Spell cooldown alerts: spellName -> true if on cooldown
iSP.AuraSnapshot = { buffs = {}, debuffs = {} }  -- Last known player auras for diff detection
iSP.AuraAlertQueue = {}       -- Queue of aura alert entries waiting to play
iSP.AuraAlertPlaying = false  -- True while an aura alert sound is active

-- Saved original volumes before any iSP boost (restored when last sound stops)
iSP.SavedVolumes = nil

-- Lock/unlock volume sliders during playback
function iSP:LockVolumeSliders(locked)
    if iSP.ChannelVolSlider and iSP.ChannelVolSlider.SetLocked then
        iSP.ChannelVolSlider:SetLocked(locked)
    end
    if iSP.SfVolSlider and iSP.SfVolSlider.SetLocked then
        iSP.SfVolSlider:SetLocked(locked)
    end
end

-- Restore original channel volumes if no more iSP sounds are active
function iSP:RestoreVolumes()
    if iSP.SavedVolumes and not next(iSP.ActiveSounds) then
        for cvar, origVal in pairs(iSP.SavedVolumes) do
            SetCVar(cvar, origVal)
        end
        iSP.SavedVolumes = nil
        iSP:LockVolumeSliders(false)
        Debug("All sounds stopped, volumes restored", 3)
    end
end

-- Stop currently playing sound
function iSP:StopSound(soundID)
    if iSP.ActiveSounds[soundID] then
        -- Stop the actual audio via WoW API
        local handle = iSP.ActiveSounds[soundID].handle
        if handle then
            StopSound(handle)
        end
        -- Cancel all timers for this sound
        for _, timer in ipairs(iSP.ActiveSounds[soundID].timers or {}) do
            if timer then
                timer:Cancel()
            end
        end
        iSP.ActiveSounds[soundID] = nil

        if iSPSettings.DebugMode then
            print(L["PrintPrefix"] .. Colors.Red .. "Stopped sound: " .. soundID)
        end

        -- Restore volumes if this was the last active sound
        self:RestoreVolumes()
    end
end

-- Stop all currently playing sounds
function iSP:StopAllSounds()
    for soundID, _ in pairs(iSP.ActiveSounds) do
        -- Stop audio and cancel timers, but don't restore volumes yet
        local handle = iSP.ActiveSounds[soundID].handle
        if handle then
            StopSound(handle)
        end
        for _, timer in ipairs(iSP.ActiveSounds[soundID].timers or {}) do
            if timer then
                timer:Cancel()
            end
        end
        iSP.ActiveSounds[soundID] = nil
    end
    -- Restore volumes once after clearing all sounds
    self:RestoreVolumes()
end

-- Play a sound file by name with advanced options
-- options = {
--   duration = 0,      -- How long to play (0 = full sound)
--   startOffset = 0,   -- Start from X seconds into the file
--   loop = false,      -- Loop the sound
--   loopCount = 1,     -- How many times to loop
--   fadeIn = false,    -- Fade in (not supported by WoW API, placeholder)
--   fadeOut = false,   -- Fade out (not supported by WoW API, placeholder)
-- }
function iSP:PlaySound(fileName, options)
    if not fileName or fileName == "" then
        if iSPSettings.DebugMode then
            print(L["NoSoundSpecified"])
        end
        return false
    end

    if not iSPSettings.Enabled then
        if iSPSettings.DebugMode then
            print(L["AddonDisabled"])
        end
        return false
    end

    -- Default options
    options = options or {}
    local duration = options.duration or 0
    local startOffset = options.startOffset or 0
    local loop = options.loop or false
    local loopCount = options.loopCount or 1
    local fadeIn = options.fadeIn or false
    local fadeOut = options.fadeOut or false

    local soundID = fileName .. "_" .. time()

    -- Try custom sounds folder first (survives CurseForge updates),
    -- then fall back to bundled sounds folder
    local soundPath = iSP.CustomSoundsPath .. fileName

    if iSPSettings.DebugMode then
        print(string.format(L["SoundPlaying"], soundPath))
        if duration > 0 then
            print(Colors.Gray .. "  Duration: " .. duration .. "s")
        end
        if startOffset > 0 then
            print(Colors.Gray .. "  Start Offset: " .. startOffset .. "s")
        end
        if loop then
            print(Colors.Gray .. "  Looping: " .. loopCount .. " times")
        end
    end

    -- NOTE: WoW's PlaySoundFile API doesn't support:
    -- - Start offset (can't seek into audio file)
    -- - Duration control (can't stop sound once started)
    -- - Fade in/out effects
    --
    -- We can simulate some of these with timers and workarounds:

    -- Volume helper: boosts channel volume so iSP sounds are always audible.
    -- Boosts Master + target channel, scales down other channels to preserve their
    -- effective volume. Volumes stay boosted during playback and are restored when
    -- the last active iSP sound stops (via iSP:RestoreVolumes).
    -- Returns: success (bool), soundHandle (number or nil)
    local function VolPct(v)
        return math.floor(v * 100 + 0.5) .. "%"
    end

    local function PlayWithVolume(path, ch)
        local vol = (iSPSettings.iSPVolume or 100) / 100  -- 0.0 to 1.0

        -- Save original volumes only on first iSP sound (before any boost)
        if not iSP.SavedVolumes then
            iSP.SavedVolumes = {}
            for name, cvar in pairs(iSP.ChannelCVars) do
                local val = GetCVar(cvar)
                if val then
                    iSP.SavedVolumes[cvar] = tonumber(val) or 1.0
                end
            end
            iSP:LockVolumeSliders(true)
        end

        -- Always use original (pre-boost) values as reference for scaling
        local origMaster = iSP.SavedVolumes["Sound_MasterVolume"] or 1.0
        Debug("PlayWithVolume: Boosting for " .. ch .. " (iSP Volume: " .. VolPct(vol) .. ")", 3)

        if ch == "Master" then
            -- iSP sound plays through Master: set Master to iSPVolume
            -- Scale subs to preserve effective: sub * origMaster = sub_new * vol
            Debug("  Master: " .. VolPct(origMaster) .. " -> " .. VolPct(vol), 3)
            SetCVar("Sound_MasterVolume", vol)
            if vol > 0 then
                for name, cvar in pairs(iSP.ChannelCVars) do
                    if iSP.SavedVolumes[cvar] and name ~= "Master" then
                        local newVal = math.max(math.min(iSP.SavedVolumes[cvar] * origMaster / vol, 1.0), 0.01)
                        Debug("  " .. name .. ": " .. VolPct(iSP.SavedVolumes[cvar]) .. " -> " .. VolPct(newVal) .. " (preserved)", 3)
                        SetCVar(cvar, newVal)
                    end
                end
            end
        else
            -- iSP sound plays through sub-channel: set Master to 1.0, target to iSPVolume
            -- Scale other subs to preserve effective: origMaster * sub = 1.0 * sub_new
            Debug("  Master: " .. VolPct(origMaster) .. " -> 100%", 3)
            SetCVar("Sound_MasterVolume", 1.0)
            local targetCvar = iSP.ChannelCVars[ch]
            if targetCvar then
                Debug("  " .. ch .. ": " .. VolPct(iSP.SavedVolumes[targetCvar] or 0) .. " -> " .. VolPct(vol), 3)
                SetCVar(targetCvar, vol)
            end
            for name, cvar in pairs(iSP.ChannelCVars) do
                if iSP.SavedVolumes[cvar] and name ~= "Master" and name ~= ch then
                    local newVal = math.max(iSP.SavedVolumes[cvar] * origMaster, 0.01)
                    Debug("  " .. name .. ": " .. VolPct(iSP.SavedVolumes[cvar]) .. " -> " .. VolPct(newVal) .. " (preserved)", 3)
                    SetCVar(cvar, newVal)
                end
            end
        end

        -- Play the sound — volumes stay boosted during playback
        local ok, willPlay, handle = pcall(PlaySoundFile, path, ch)

        if ok and willPlay then
            return true, handle
        end

        -- Play failed — if no other active sounds, restore volumes
        if not next(iSP.ActiveSounds) then
            iSP:RestoreVolumes()
        end
        return false, nil
    end

    local function PlayWithOptions()
        -- Try to play the sound (Dialog channel requires TOC >= 50000 / MoP+)
        local channel = iSPSettings.SoundChannel or "Master"
        if channel == "Dialog" and (iSP.GameTocVersion or 0) < 50000 then
            channel = "Master"
        end
        local vol = iSPSettings.iSPVolume or 100
        local success, soundHandle = PlayWithVolume(soundPath, channel)

        -- If custom path failed, fall back to bundled sounds folder
        if not success then
            local bundledPath = iSP.SoundsPath .. fileName
            if bundledPath ~= soundPath then
                Debug("Custom path failed, trying bundled: " .. bundledPath, 3)
                soundPath = bundledPath
                success, soundHandle = PlayWithVolume(soundPath, channel)
            end
        end

        if not success and iSPSettings.DebugMode then
            print(string.format(L["SoundFailed"], soundPath))
            return false
        elseif success and iSPSettings.ShowNotifications then
            print(string.format(L["SoundPlaying"], fileName))
        end

        if success then
            Debug("Channel: " .. channel .. ", iSP Volume: " .. vol .. "%", 3)
        end

        -- Track active sound (store handle so StopSound can actually stop it)
        iSP.ActiveSounds[soundID] = {
            fileName = fileName,
            handle = soundHandle,
            startTime = time(),
            timers = {},
        }

        -- If duration is set, stop the sound after that many seconds
        if duration > 0 then
            local stopTimer = C_Timer.NewTimer(duration, function()
                -- Play silence or remove from active list
                self:StopSound(soundID)
            end)
            table.insert(iSP.ActiveSounds[soundID].timers, stopTimer)
        end

        -- Handle looping
        if loop and loopCount > 1 then
            local currentLoop = 1
            local loopTimer

            local function LoopSound()
                if currentLoop >= loopCount then
                    self:StopSound(soundID)
                    return
                end

                -- Calculate when to play next loop
                -- Since we can't detect sound length, use duration or a default
                local soundLength = duration > 0 and duration or 3 -- Default 3 seconds if no duration set

                currentLoop = currentLoop + 1
                local _, newHandle = PlayWithVolume(soundPath, iSPSettings.SoundChannel or "Master")
                if iSP.ActiveSounds[soundID] then
                    iSP.ActiveSounds[soundID].handle = newHandle
                end

                if currentLoop < loopCount then
                    loopTimer = C_Timer.NewTimer(soundLength, LoopSound)
                    table.insert(iSP.ActiveSounds[soundID].timers, loopTimer)
                end
            end

            local soundLength = duration > 0 and duration or 3
            loopTimer = C_Timer.NewTimer(soundLength, LoopSound)
            table.insert(iSP.ActiveSounds[soundID].timers, loopTimer)
        end

        -- Update state
        iSP.State.CurrentlyPlaying = fileName
        iSP.State.LastPlayedTime = time()

        return success
    end

    -- If startOffset is set, delay the playback
    -- NOTE: This doesn't actually seek into the file, just delays when it starts
    if startOffset > 0 then
        if iSPSettings.DebugMode then
            print(L["DebugInfo"] .. "Start offset delays playback but doesn't seek into file")
        end
        C_Timer.After(startOffset, PlayWithOptions)
        return true
    else
        return PlayWithOptions()
    end
end

-- Test sound playback (same as trigger but with stop timer and button lock)
iSP.TestingSound = false

function iSP:TestSound(fileName)
    if iSP.TestingSound then return false end
    iSP.TestingSound = true

    print(string.format(L["SoundTesting"], fileName))
    local dur = (iSPSettings.SoundDurations and iSPSettings.SoundDurations[fileName]) or 3
    local result = self:PlaySound(fileName)
    C_Timer.After(dur, function()
        iSP:StopAllSounds()
        iSP.TestingSound = false
        Debug("TestSound: stopped after " .. dur .. "s", 3)
    end)
    return result
end

-- Play sound for a trigger
function iSP:PlayTriggerSound(triggerID)
    if not iSPSettings.Triggers then return false end
    if not iSPSettings.Triggers[triggerID] then return false end

    local trigger = iSPSettings.Triggers[triggerID]
    if not trigger.enabled then
        if iSPSettings.DebugMode then
            print(string.format(L["TriggerDisabled"], triggerID))
        end
        return false
    end

    if not trigger.sound or trigger.sound == "" then
        if iSPSettings.DebugMode then
            print(string.format(L["NoSoundSpecified"]))
        end
        return false
    end

    if iSPSettings.DebugMode then
        print(string.format(L["TriggerActivated"], triggerID))
    end

    -- Build options from trigger settings
    -- Use per-sound duration from SoundDurations if trigger has no explicit duration
    local dur = trigger.duration or 0
    if dur == 0 and iSPSettings.SoundDurations then
        dur = iSPSettings.SoundDurations[trigger.sound] or 0
    end

    local options = {
        duration = dur,
        startOffset = trigger.startOffset or 0,
        loop = trigger.loop or false,
        loopCount = trigger.loopCount or 1,
        fadeIn = trigger.fadeIn or false,
        fadeOut = trigger.fadeOut or false,
    }

    local success = self:PlaySound(trigger.sound, options)

    -- Send announcement if configured
    if success and trigger.announce and trigger.announce ~= "" then
        self:SendAnnouncement(triggerID, trigger.announce)
    end

    return success
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Chat Announcements                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
function iSP:SendAnnouncement(triggerID, channel)
    local meta = iSP.TriggerMeta and iSP.TriggerMeta[triggerID]
    if not meta then return end

    local triggerName = meta.name or triggerID
    local message = string.format(L["AnnounceSent"], triggerName)

    -- Map channel to WoW API chat type and validate group membership
    local chatType
    if channel == "GENERAL" then
        -- Auto-select: Battleground > Raid > Party
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            chatType = "INSTANCE_CHAT"
        elseif IsInRaid() then
            chatType = "RAID"
        elseif IsInGroup() then
            chatType = "PARTY"
        end
    elseif channel == "PARTY" then
        if IsInGroup() and not IsInRaid() then
            chatType = "PARTY"
        end
    elseif channel == "RAID" then
        if IsInRaid() then
            chatType = "RAID"
        end
    elseif channel == "BATTLEGROUND" then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            chatType = "INSTANCE_CHAT"
        end
    elseif channel == "GUILD" then
        if IsInGuild() then
            chatType = "GUILD"
        end
    elseif channel == "SELF" then
        print(L["PrintPrefix"] .. message)
        Debug(string.format("Announcement printed to self: %s", message), 3)
        return
    end

    if chatType then
        SendChatMessage(message, chatType)
        Debug(string.format("Announcement sent to %s: %s", channel, message), 3)
    else
        Debug(string.format("Announcement skipped (%s): not in correct group", channel), 2)
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               PvP Kill Tracking                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Reset kill streak (after timeout or death)
function iSP:ResetKillStreak()
    self.State.PvP.KillStreak = 0
    self.State.PvP.Kills = {}
    if iSPSettings.DebugMode then
        print(L["DebugInfo"] .. "Kill streak reset")
    end
end

-- Process honorable kill
function iSP:OnHonorableKill()
    local now = time()
    local pvpState = self.State.PvP

    -- Check if kill streak should be reset (timeout)
    if (now - pvpState.LastKillTime) > pvpState.KillStreakWindow then
        self:ResetKillStreak()
    end

    -- Update kill tracking
    pvpState.LastKillTime = now
    pvpState.KillStreak = pvpState.KillStreak + 1
    table.insert(pvpState.Kills, now)

    if iSPSettings.DebugMode then
        print(L["DebugInfo"] .. "Honorable Kill! Streak: " .. pvpState.KillStreak)
    end

    -- Play honorable kill sound
    self:PlayTriggerSound("PVP_HONORABLE_KILL")

    -- Check for multi-kill (within 10 seconds)
    local recentKills = 0
    for i = #pvpState.Kills, 1, -1 do
        if (now - pvpState.Kills[i]) <= pvpState.MultiKillWindow then
            recentKills = recentKills + 1
        else
            break
        end
    end

    -- Play multi-kill sounds
    if recentKills >= 7 then
        self:PlayTriggerSound("PVP_GODLIKE")
    elseif recentKills >= 6 then
        self:PlayTriggerSound("PVP_UNSTOPPABLE")
    elseif recentKills >= 5 then
        self:PlayTriggerSound("PVP_DOMINATING")
    elseif recentKills >= 4 then
        self:PlayTriggerSound("PVP_MULTI_KILL")
    elseif recentKills >= 3 then
        self:PlayTriggerSound("PVP_TRIPLE_KILL")
    elseif recentKills == 2 then
        self:PlayTriggerSound("PVP_DOUBLE_KILL")
    end

    -- Play killing spree sounds (based on total streak)
    if pvpState.KillStreak == 5 then
        self:PlayTriggerSound("PVP_KILLING_SPREE")
    elseif pvpState.KillStreak == 10 then
        self:PlayTriggerSound("PVP_DOMINATING")
    elseif pvpState.KillStreak == 15 then
        self:PlayTriggerSound("PVP_UNSTOPPABLE")
    elseif pvpState.KillStreak >= 20 then
        self:PlayTriggerSound("PVP_GODLIKE")
    end

    -- Clean up old kills (keep only recent ones)
    while #pvpState.Kills > 0 and (now - pvpState.Kills[1]) > pvpState.MultiKillWindow do
        table.remove(pvpState.Kills, 1)
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Event Handlers                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Play trigger sound with cooldown check
function iSP:PlayTriggerSoundWithCooldown(triggerID)
    local meta = self.TriggerMeta and self.TriggerMeta[triggerID]
    if meta then
        local cd = meta.cooldown or 0
        if cd > 0 then
            local lastFired = self.TriggerLastFired[triggerID] or 0
            if (GetTime() - lastFired) < cd then return end
        end
        self.TriggerLastFired[triggerID] = GetTime()
    end
    self:PlayTriggerSound(triggerID)
end

-- Event handler — data-driven dispatch
local function OnEvent(self, event, ...)
    -- ── Core lifecycle events (always handled) ──
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            iSP:OnAddonLoaded()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        iSP:OnPlayerLogin()
        return
    end

    -- ── Combat state tracking (always active) ──
    if event == "PLAYER_REGEN_DISABLED" then
        iSP.State.InCombat = true
        if iSP.SettingsFrame and iSP.SettingsFrame:IsShown() then
            iSP.SettingsFrame:Hide()
        end
        local setupGuide = _G["iSPSetupGuide"]
        if setupGuide and setupGuide:IsShown() then
            setupGuide:Hide()
        end
        iSP:PlayTriggerSoundWithCooldown("PLAYER_REGEN_DISABLED")
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        iSP.State.InCombat = false
        iSP:PlayTriggerSoundWithCooldown("PLAYER_REGEN_ENABLED")
        return
    end

    -- ── Kill streak reset on death ──
    if event == "PLAYER_DEAD" then
        iSP:ResetKillStreak()
        iSP:PlayTriggerSoundWithCooldown("PLAYER_DEAD")
        return
    end

    -- ── Cooldown alerts ──
    if event == "SPELL_UPDATE_COOLDOWN" then
        iSP:OnSpellCooldownUpdate()
        return
    end

    -- ── Data-driven dispatch for all other events ──
    local triggers = iSP.EventToTriggers[event]
    if triggers then
        for _, triggerID in ipairs(triggers) do
            local meta = iSP.TriggerMeta[triggerID]
            if meta then
                -- Unit filter check (e.g. UNIT_SPELLCAST_START only for "player")
                if meta.unitFilter then
                    local unit = ...
                    if unit == meta.unitFilter then
                        iSP:PlayTriggerSoundWithCooldown(triggerID)
                    end
                else
                    iSP:PlayTriggerSoundWithCooldown(triggerID)
                end
            end
        end
    end
end

-- PvP kill tracking — version-split for Classic vs Retail
local _, _, _, tocVersion = GetBuildInfo()

if tocVersion and tocVersion < 100000 then
    -- ── Classic: use COMBAT_LOG_EVENT_UNFILTERED for precise kill detection ──
    local pvpKillFrame = CreateFrame("Frame")
    pvpKillFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    pvpKillFrame:SetScript("OnEvent", function()
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

        if subevent == "PARTY_KILL" then
            local playerGUID = UnitGUID("player")
            if sourceGUID == playerGUID and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
                if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
                    iSP:OnHonorableKill()
                end
            end
        end
    end)
else
    -- ── Retail 12.0+: use PARTY_KILL event + achievement criteria workaround ──
    -- Blizzard blocks COMBAT_LOG_EVENT_UNFILTERED for addons in retail.
    -- PARTY_KILL event still fires but hides attacker GUID as <secret> in instances.
    -- Workaround: compare total killing blow count (achievement criteria 1487) before/after.
    -- Credit: ErnestasBaltinas/hksounds for the technique.

    local pvpKillFrame = CreateFrame("Frame")
    local baselineKillCount = 0

    -- Get player's total killing blows from achievement statistics
    local function GetTotalKillCount()
        local _, _, _, _, _, _, _, _, killCount = GetAchievementCriteriaInfoByID(1487, 0)
        return killCount or 0
    end

    -- Check if a GUID is hidden (secret) by Blizzard
    local function IsGUIDSecret(guid)
        return issecretvalue and issecretvalue(guid)
    end

    -- Check if the target is a player (not NPC)
    local function IsTargetPlayer(guid)
        if not guid then return false end
        if IsGUIDSecret(guid) then
            -- In instances, target GUID might also be secret — assume player in PvP context
            return true
        end
        return guid:find("^Player%-") ~= nil
    end

    -- Determine if WE got the killing blow
    local function WasKilledByPlayer(attackerGUID)
        if IsGUIDSecret(attackerGUID) then
            -- GUID is hidden (instanced PvP) — check if our kill count increased
            local currentKills = GetTotalKillCount()
            if currentKills > baselineKillCount then
                baselineKillCount = currentKills
                return true
            end
            return false
        end
        -- Open world: direct GUID comparison
        return attackerGUID == UnitGUID("player")
    end

    -- Initialize baseline on login
    pvpKillFrame:RegisterEvent("PLAYER_LOGIN")
    pvpKillFrame:RegisterEvent("PARTY_KILL")

    pvpKillFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            baselineKillCount = GetTotalKillCount()
            if iSPSettings and iSPSettings.DebugMode then
                print(L["DebugInfo"] .. "Retail PvP: Baseline kill count = " .. baselineKillCount)
            end
        elseif event == "PARTY_KILL" then
            local attackerGUID, targetGUID = ...
            if WasKilledByPlayer(attackerGUID) and IsTargetPlayer(targetGUID) then
                iSP:OnHonorableKill()
            end
        end
    end)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Pet State Tracking                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

do
    local petFrame = CreateFrame("Frame")
    local previousPetState = nil -- nil = unknown, "alive", "dead", "none"

    local function GetPetState()
        if UnitExists("pet") then
            if UnitIsDead("pet") then
                return "dead"
            else
                return "alive"
            end
        else
            return "none"
        end
    end

    local function OnPetEvent()
        if not iSPSettings or not iSPSettings.Triggers then return end

        local summoned = iSPSettings.Triggers["PET_SUMMONED"]
        local dismissed = iSPSettings.Triggers["PET_DISMISSED"]
        local died = iSPSettings.Triggers["PET_DIED"]

        local anyEnabled = (summoned and summoned.enabled)
                        or (dismissed and dismissed.enabled)
                        or (died and died.enabled)
        if not anyEnabled then return end

        local newState = GetPetState()

        if newState == "alive" and previousPetState ~= "alive" then
            iSP:PlayTriggerSoundWithCooldown("PET_SUMMONED")
        elseif newState == "dead" and previousPetState == "alive" then
            iSP:PlayTriggerSoundWithCooldown("PET_DIED")
        elseif newState == "none" and previousPetState == "alive" then
            iSP:PlayTriggerSoundWithCooldown("PET_DISMISSED")
        end

        previousPetState = newState
    end

    petFrame:RegisterEvent("UNIT_PET")
    petFrame:RegisterEvent("UNIT_FLAGS")
    petFrame:RegisterEvent("PLAYER_LOGIN")

    petFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            previousPetState = GetPetState()
            return
        end

        if event == "UNIT_PET" then
            OnPetEvent()
            return
        end

        if event == "UNIT_FLAGS" then
            local unit = ...
            if unit == "pet" then
                OnPetEvent()
            end
            return
        end
    end)
end

eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- Register trigger events — data-driven from TriggerMeta
function iSP:RegisterTriggerEvents()
    -- Always register combat state events (used for InCombat tracking + UI hide)
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- Build EventToTriggers lookup and register enabled events
    self.EventToTriggers = {}

    if not iSP.TriggerMeta then return end

    for triggerID, meta in pairs(iSP.TriggerMeta) do
        -- Skip triggers without a WoW event (PvP custom triggers)
        if meta.event
           and meta.event ~= "PLAYER_REGEN_DISABLED"  -- Already registered above
           and meta.event ~= "PLAYER_REGEN_ENABLED"    -- Already registered above
        then
            -- Skip triggers not available for this game version
            if self:IsTriggerAvailable(triggerID) then
                if iSPSettings.Triggers[triggerID]
                   and iSPSettings.Triggers[triggerID].enabled then
                    eventFrame:RegisterEvent(meta.event)

                    if not self.EventToTriggers[meta.event] then
                        self.EventToTriggers[meta.event] = {}
                    end
                    table.insert(self.EventToTriggers[meta.event], triggerID)
                end
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Cooldown Alerts                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:RegisterCooldownAlerts()
    if not iSPSettings.CooldownAlerts then return end
    local hasEnabled = false
    for spellName, config in pairs(iSPSettings.CooldownAlerts) do
        if config.enabled then
            hasEnabled = true
            Debug("Cooldown alert registered: " .. spellName, 3)
        end
    end
    if hasEnabled then
        eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        Debug("SPELL_UPDATE_COOLDOWN event registered.", 3)
    else
        Debug("No enabled cooldown alerts found.", 3)
    end
end

iSP.CooldownAlertQueue = {}       -- Queue of spell names waiting to play
iSP.CooldownAlertPlaying = false  -- True while a cooldown alert sound is active
iSP.CooldownPollCounts = {}       -- Poll iteration count per spell (safety limit)
local COOLDOWN_MAX_POLLS = 30     -- Max polls before giving up (~15 seconds)
local COOLDOWN_STAGGER_DELAY = 0.8 -- Seconds between queued alert sounds

function iSP:CheckCooldownReady(spellName)
    local config = iSPSettings.CooldownAlerts and iSPSettings.CooldownAlerts[spellName]
    if not config or not config.enabled or not config.sound or config.sound == "" then
        Debug("CheckCooldownReady: " .. spellName .. " — config missing or disabled, aborting.", 2)
        self.CooldownStates[spellName] = nil
        self.CooldownPollCounts[spellName] = nil
        return
    end

    -- Safety: max poll limit to prevent infinite polling
    self.CooldownPollCounts[spellName] = (self.CooldownPollCounts[spellName] or 0) + 1
    if self.CooldownPollCounts[spellName] > COOLDOWN_MAX_POLLS then
        Debug("CheckCooldownReady: " .. spellName .. " — max polls reached (" .. COOLDOWN_MAX_POLLS .. "), giving up.", 2)
        self.CooldownStates[spellName] = nil
        self.CooldownPollCounts[spellName] = nil
        return
    end

    local start, duration, enabled = GetSpellCooldown(spellName)
    Debug("CheckCooldownReady: " .. spellName .. " — start=" .. tostring(start) .. " duration=" .. tostring(duration) .. " enabled=" .. tostring(enabled) .. " (poll " .. self.CooldownPollCounts[spellName] .. "/" .. COOLDOWN_MAX_POLLS .. ")", 3)
    if start and start > 0 and duration and duration > 1.5 then
        -- Still on cooldown — poll again in 0.5s
        Debug("CheckCooldownReady: " .. spellName .. " still on cooldown, polling again in 0.5s.", 3)
        C_Timer.After(0.5, function() iSP:CheckCooldownReady(spellName) end)
    else
        -- Cooldown finished — queue alert
        Debug("CheckCooldownReady: " .. spellName .. " is READY — queuing alert.", 3)
        self.CooldownStates[spellName] = nil
        self.CooldownPollCounts[spellName] = nil
        self:QueueCooldownAlert(spellName)
    end
end

function iSP:QueueCooldownAlert(spellName)
    -- Add to queue (avoid duplicates)
    for _, name in ipairs(self.CooldownAlertQueue) do
        if name == spellName then
            Debug("QueueCooldownAlert: " .. spellName .. " already in queue, skipping.", 3)
            return
        end
    end
    table.insert(self.CooldownAlertQueue, spellName)
    Debug("QueueCooldownAlert: " .. spellName .. " added to queue (queue size: " .. #self.CooldownAlertQueue .. ").", 3)

    -- If nothing is currently playing, start processing
    if not self.CooldownAlertPlaying then
        self:ProcessCooldownAlertQueue()
    end
end

function iSP:ProcessCooldownAlertQueue()
    if #self.CooldownAlertQueue == 0 then
        self.CooldownAlertPlaying = false
        Debug("ProcessCooldownAlertQueue: Queue empty, done.", 3)
        return
    end

    self.CooldownAlertPlaying = true
    local spellName = table.remove(self.CooldownAlertQueue, 1)
    local config = iSPSettings.CooldownAlerts and iSPSettings.CooldownAlerts[spellName]

    if not config or not config.sound or config.sound == "" then
        Debug("ProcessCooldownAlertQueue: " .. spellName .. " — no sound configured, skipping.", 2)
        self:ProcessCooldownAlertQueue()
        return
    end

    Debug("ProcessCooldownAlertQueue: Playing alert for " .. spellName .. " — sound: " .. config.sound, 3)
    local dur = (iSPSettings.SoundDurations and iSPSettings.SoundDurations[config.sound]) or 3
    self:PlaySound(config.sound, { duration = dur })
    if iSPSettings.ShowNotifications then
        print(iSP.Colors.iSP .. "[iSP]: |r" .. spellName .. " is ready!")
    end

    -- Process next queued alert after a stagger delay
    local remaining = #self.CooldownAlertQueue
    if remaining > 0 then
        Debug("ProcessCooldownAlertQueue: " .. remaining .. " more in queue, next in " .. COOLDOWN_STAGGER_DELAY .. "s.", 3)
        C_Timer.After(COOLDOWN_STAGGER_DELAY, function() iSP:ProcessCooldownAlertQueue() end)
    else
        self.CooldownAlertPlaying = false
    end
end

function iSP:OnSpellCooldownUpdate()
    if not iSPSettings.CooldownAlerts then return end
    for spellName, config in pairs(iSPSettings.CooldownAlerts) do
        if config.enabled and config.sound and config.sound ~= "" then
            local start, duration, enabled = GetSpellCooldown(spellName)
            if start and start > 0 and duration and duration > 1.5 and not self.CooldownStates[spellName] then
                -- Cooldown just started — begin polling
                Debug("Cooldown detected: " .. spellName .. " — duration=" .. tostring(duration) .. "s, polling in " .. tostring(duration - 0.2) .. "s.", 3)
                self.CooldownStates[spellName] = true
                self.CooldownPollCounts[spellName] = 0
                C_Timer.After(duration - 0.2, function() iSP:CheckCooldownReady(spellName) end)
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Aura Alerts                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local auraAlertFrame = CreateFrame("Frame")
local auraAlertInitialized = false
local AURA_STAGGER_DELAY = 0.8  -- Seconds between queued aura alert sounds

function iSP:ScanPlayerAuras()
    local buffs, debuffs = {}, {}
    local toc = gameTocNumber

    if toc >= 120000 then
        -- ── Midnight 12.0+: use C_UnitAuras.GetUnitAuras (batch API) ──
        local buffList = C_UnitAuras.GetUnitAuras("player", "HELPFUL")
        if buffList then
            for _, aura in ipairs(buffList) do
                if aura.name then buffs[aura.name] = true end
            end
        end
        local debuffList = C_UnitAuras.GetUnitAuras("player", "HARMFUL")
        if debuffList then
            for _, aura in ipairs(debuffList) do
                if aura.name then debuffs[aura.name] = true end
            end
        end
    elseif toc >= 100000 then
        -- ── Retail 10.0–11.x: use C_UnitAuras.GetAuraDataByIndex ──
        local i = 1
        while true do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not aura then break end
            if aura.name then buffs[aura.name] = true end
            i = i + 1
        end
        i = 1
        while true do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", i, "HARMFUL")
            if not aura then break end
            if aura.name then debuffs[aura.name] = true end
            i = i + 1
        end
    else
        -- ── Classic Era / TBC / Wrath / Cata / MoP: use UnitBuff/UnitDebuff ──
        local i = 1
        while true do
            local name = UnitBuff("player", i)
            if not name then break end
            buffs[name] = true
            i = i + 1
        end
        i = 1
        while true do
            local name = UnitDebuff("player", i)
            if not name then break end
            debuffs[name] = true
            i = i + 1
        end
    end

    return buffs, debuffs
end

function iSP:RegisterAuraAlerts()
    if not iSPSettings.AuraAlerts then return end
    local hasEnabled = false
    for auraName, config in pairs(iSPSettings.AuraAlerts) do
        if config.enabled then
            hasEnabled = true
            Debug("Aura alert registered: " .. auraName .. " (" .. (config.triggerOn or "both") .. ", " .. (config.auraType or "ANY") .. ")", 3)
        end
    end
    if hasEnabled then
        auraAlertFrame:RegisterEvent("UNIT_AURA")
        -- Take initial snapshot to avoid false "gained" alerts on login
        if not auraAlertInitialized then
            self.AuraSnapshot.buffs, self.AuraSnapshot.debuffs = self:ScanPlayerAuras()
            auraAlertInitialized = true
            Debug("Aura alert snapshot initialized: " .. self:CountTable(self.AuraSnapshot.buffs) .. " buffs, " .. self:CountTable(self.AuraSnapshot.debuffs) .. " debuffs.", 3)
        end
        Debug("UNIT_AURA event registered for aura alerts.", 3)
    else
        auraAlertFrame:UnregisterEvent("UNIT_AURA")
        Debug("No enabled aura alerts found.", 3)
    end
end

function iSP:CountTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function iSP:OnUnitAura(unit)
    if unit ~= "player" then return end
    if not iSPSettings.AuraAlerts then return end

    local newBuffs, newDebuffs = self:ScanPlayerAuras()
    local oldBuffs = self.AuraSnapshot.buffs
    local oldDebuffs = self.AuraSnapshot.debuffs

    for auraName, config in pairs(iSPSettings.AuraAlerts) do
        if config.enabled and config.sound and config.sound ~= "" then
            local triggerOn = config.triggerOn or "both"
            local auraType = config.auraType or "ANY"
            local fired = false

            -- Check buffs
            if auraType == "BUFF" or auraType == "ANY" then
                local wasActive = oldBuffs[auraName]
                local isActive = newBuffs[auraName]
                if isActive and not wasActive and (triggerOn == "gained" or triggerOn == "both") then
                    self:QueueAuraAlert(auraName, "gained")
                    fired = true
                elseif wasActive and not isActive and (triggerOn == "lost" or triggerOn == "both") then
                    self:QueueAuraAlert(auraName, "lost")
                    fired = true
                end
            end

            -- Check debuffs (skip if buff check already fired for "ANY" type)
            if not fired and (auraType == "DEBUFF" or auraType == "ANY") then
                local wasActive = oldDebuffs[auraName]
                local isActive = newDebuffs[auraName]
                if isActive and not wasActive and (triggerOn == "gained" or triggerOn == "both") then
                    self:QueueAuraAlert(auraName, "gained")
                elseif wasActive and not isActive and (triggerOn == "lost" or triggerOn == "both") then
                    self:QueueAuraAlert(auraName, "lost")
                end
            end
        end
    end

    self.AuraSnapshot.buffs = newBuffs
    self.AuraSnapshot.debuffs = newDebuffs
end

function iSP:QueueAuraAlert(auraName, alertType)
    -- Avoid duplicates in queue
    for _, entry in ipairs(self.AuraAlertQueue) do
        if entry.name == auraName and entry.type == alertType then
            Debug("QueueAuraAlert: " .. auraName .. " (" .. alertType .. ") already in queue, skipping.", 3)
            return
        end
    end
    table.insert(self.AuraAlertQueue, { name = auraName, type = alertType })
    Debug("QueueAuraAlert: " .. auraName .. " (" .. alertType .. ") added to queue (size: " .. #self.AuraAlertQueue .. ").", 3)

    if not self.AuraAlertPlaying then
        self:ProcessAuraAlertQueue()
    end
end

function iSP:ProcessAuraAlertQueue()
    if #self.AuraAlertQueue == 0 then
        self.AuraAlertPlaying = false
        Debug("ProcessAuraAlertQueue: Queue empty, done.", 3)
        return
    end

    self.AuraAlertPlaying = true
    local entry = table.remove(self.AuraAlertQueue, 1)
    local config = iSPSettings.AuraAlerts and iSPSettings.AuraAlerts[entry.name]

    if not config or not config.sound or config.sound == "" then
        Debug("ProcessAuraAlertQueue: " .. entry.name .. " — no sound configured, skipping.", 2)
        self:ProcessAuraAlertQueue()
        return
    end

    Debug("ProcessAuraAlertQueue: Playing alert for " .. entry.name .. " (" .. entry.type .. ") — sound: " .. config.sound, 3)
    local dur = (iSPSettings.SoundDurations and iSPSettings.SoundDurations[config.sound]) or 3
    self:PlaySound(config.sound, { duration = dur })
    if iSPSettings.ShowNotifications then
        if entry.type == "gained" then
            print(L["AuraGained"]:format(entry.name))
        else
            print(L["AuraLost"]:format(entry.name))
        end
    end

    -- Send announcement if configured
    if config.announce and config.announce ~= "" then
        local announceMsg = "[iSP] " .. entry.name .. " " .. entry.type .. "!"
        self:SendAuraAnnouncement(announceMsg, config.announce)
    end

    -- Process next queued alert after stagger delay
    local remaining = #self.AuraAlertQueue
    if remaining > 0 then
        Debug("ProcessAuraAlertQueue: " .. remaining .. " more in queue, next in " .. AURA_STAGGER_DELAY .. "s.", 3)
        C_Timer.After(AURA_STAGGER_DELAY, function() iSP:ProcessAuraAlertQueue() end)
    else
        self.AuraAlertPlaying = false
    end
end

function iSP:SendAuraAnnouncement(message, channel)
    local chatType
    if channel == "GENERAL" then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            chatType = "INSTANCE_CHAT"
        elseif IsInRaid() then
            chatType = "RAID"
        elseif IsInGroup() then
            chatType = "PARTY"
        end
    elseif channel == "PARTY" then
        if IsInGroup() and not IsInRaid() then chatType = "PARTY" end
    elseif channel == "RAID" then
        if IsInRaid() then chatType = "RAID" end
    elseif channel == "BATTLEGROUND" then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then chatType = "INSTANCE_CHAT" end
    elseif channel == "GUILD" then
        if IsInGuild() then chatType = "GUILD" end
    elseif channel == "SELF" then
        print(L["PrintPrefix"] .. message)
        return
    end
    if chatType then
        SendChatMessage(message, chatType)
    end
end

auraAlertFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_AURA" then
        iSP:OnUnitAura(unit)
    end
end)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Addon Lifecycle Events                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:OnAddonLoaded()
    -- Initialize settings
    self:InitializeSettings()

    -- Register trigger events
    self:RegisterTriggerEvents()

    -- Register cooldown alerts
    self:RegisterCooldownAlerts()

    -- Register aura alerts
    self:RegisterAuraAlerts()

    -- Determine game version name based on TOC
    local gameName = "Unknown"
    local tocVersion = iSP.GameTocVersion or 0

    if tocVersion >= 120000 then
        gameName = "Retail WoW"
    elseif tocVersion >= 50000 and tocVersion < 60000 then
        gameName = "Classic MoP"
    elseif tocVersion >= 40000 and tocVersion < 50000 then
        gameName = "Classic Cata"
    elseif tocVersion >= 30000 and tocVersion < 40000 then
        gameName = "Classic Wrath"
    elseif tocVersion >= 20000 and tocVersion < 30000 then
        gameName = "Classic TBC"
    elseif tocVersion >= 11500 and tocVersion < 20000 then
        gameName = "Classic Era"
    end

    -- Delayed loaded message (like iNIF/iWR)
    C_Timer.After(2, function()
        print(L["PrintPrefix"] .. Colors.iSP .. "iSoundPlayer " .. Colors.Reset .. gameName .. Colors.Green .. " v" .. iSP.Version .. Colors.Reset .. " loaded!")

        -- Welcome message (once per version)
        if iSPSettings.WelcomeMessage ~= iSP.Version then
            local playerName = UnitName("player")
            local _, class = UnitClass("player")
            local classColor = "|cFFFFFFFF"
            if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
                local c = RAID_CLASS_COLORS[class]
                classColor = string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
            end
            print(L["WelcomeStart"] .. classColor .. playerName .. L["WelcomeEnd"])
            iSPSettings.WelcomeMessage = iSP.Version
        end
    end)
end

function iSP:OnPlayerLogin()
    -- Create options panel
    if self.CreateOptionsPanel then
        self:CreateOptionsPanel()
    end

    -- Create minimap button
    self:CreateMinimapButton()

    -- Check if we should show the setup guide
    self:CheckShowSetupGuideOnStartup()

    -- Play login sound
    self:PlayTriggerSound("PLAYER_LOGIN")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Minimap Button                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:CreateMinimapButton()
    if not LDBIcon then return end

    -- Create LibDataBroker data object
    local iSPLDB = LDBroker:NewDataObject("iSoundPlayer", {
        type = "data source",
        text = "iSoundPlayer",
        icon = iSP.AddonPath .. "Images\\Icons\\Logo_iSP.blp",
        OnClick = function(self, button)
            if button == "LeftButton" and IsShiftKeyDown() then
                -- Shift+Left-click stops all playing sounds
                iSP:StopAllSounds()
                print(L["AllSoundsStopped"])
            elseif button == "LeftButton" then
                if iSP.State.InCombat then
                    print(L["InCombat"])
                    return
                end
                -- Show setup guide if available, otherwise show settings
                if iSP.ShowSetupGuide then
                    iSP:ShowSetupGuide()
                else
                    iSP:SettingsToggle()
                end
            elseif button == "RightButton" then
                -- Right-click always opens settings
                iSP:SettingsToggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:SetText(Colors.iSP .. "iSoundPlayer" .. Colors.Green .. " v" .. iSP.Version, 1, 1, 1)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipLeftClick"], 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipRightClick"], 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipShiftClick"], 1, 1, 1)
            tooltip:AddLine(" ", 1, 1, 1)
            tooltip:AddLine(L["MinimapTooltipStatus"] .. (iSPSettings.Enabled and L["StatusEnabled"] or L["StatusDisabled"]), 1, 1, 1)

            -- Show registered sounds count
            local soundCount = iSPSettings.SoundFiles and #iSPSettings.SoundFiles or 0
            tooltip:AddLine(string.format(L["MinimapTooltipSounds"], soundCount), 1, 1, 1)

            -- Show enabled triggers count
            local enabledTriggers = 0
            if iSPSettings.Triggers then
                for _, trigger in pairs(iSPSettings.Triggers) do
                    if trigger.enabled then
                        enabledTriggers = enabledTriggers + 1
                    end
                end
            end
            tooltip:AddLine(string.format(L["MinimapTooltipTriggers"], enabledTriggers), 1, 1, 1)
            tooltip:Show()
        end,
    })

    -- Register with LibDBIcon
    LDBIcon:Register("iSoundPlayer", iSPLDB, iSPSettings.MinimapButton)

    -- Show/hide based on settings
    if iSPSettings.MinimapButton.hide then
        LDBIcon:Hide("iSoundPlayer")
    else
        LDBIcon:Show("iSoundPlayer")
    end
end

-- Toggle minimap button visibility
function iSP:ToggleMinimapButton()
    if not LDBIcon then return end

    iSPSettings.MinimapButton.hide = not iSPSettings.MinimapButton.hide

    if iSPSettings.MinimapButton.hide then
        LDBIcon:Hide("iSoundPlayer")
        print(L["PrintPrefix"] .. L["MinimapHidden"])
    else
        LDBIcon:Show("iSoundPlayer")
        print(L["PrintPrefix"] .. L["MinimapShown"])
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Helper Functions                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Create styled frame (used by options panel)
function iSP:CreateiSPStyleFrame(parent, width, height, point, name)
    local frame = CreateFrame("Frame", name, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(width, height)
    if point then
        frame:SetPoint(unpack(point))
    end
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    -- Add to UISpecialFrames for ESC functionality
    if name then
        if not tContains(UISpecialFrames, name) then
            tinsert(UISpecialFrames, name)
        end
    end
    return frame
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Slash Commands                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯
SLASH_ISOUNDPLAYER1 = "/isp"
SLASH_ISOUNDPLAYER2 = "/isoundplayer"

SlashCmdList["ISOUNDPLAYER"] = function(msg)
    local cmd = string.lower(msg or "")

    if cmd == "settings" or cmd == "config" or cmd == "options" then
        iSP:SettingsToggle()
    elseif cmd == "enable" then
        iSPSettings.Enabled = true
        print(L["AddonEnabled"])
    elseif cmd == "disable" then
        iSPSettings.Enabled = false
        print(L["AddonDisabled"])
    else
        print(string.format(L["SlashHelp"], iSP.Version))
    end
end
