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

    -- Auto-fill defaults for any triggers in TriggerMeta not yet in saved settings
    -- Handles upgrades from older versions that didn't have new triggers
    if iSP.TriggerMeta then
        local defaultTrigger = {
            enabled = false, sound = "", duration = 0, startOffset = 0,
            loop = false, loopCount = 1, fadeIn = false, fadeOut = false
        }
        for triggerID, _ in pairs(iSP.TriggerMeta) do
            if not iSPSettings.Triggers[triggerID] then
                iSPSettings.Triggers[triggerID] = CopyTable(defaultTrigger)
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

-- Stop currently playing sound
function iSP:StopSound(soundID)
    if iSP.ActiveSounds[soundID] then
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
    end
end

-- Stop all currently playing sounds
function iSP:StopAllSounds()
    for soundID, _ in pairs(iSP.ActiveSounds) do
        self:StopSound(soundID)
    end
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

    local soundPath = iSP.SoundsPath .. fileName
    local soundID = fileName .. "_" .. time()

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

    -- Volume helper: temporarily adjusts channel volume for iSP sounds
    local function PlayWithVolume(path, ch)
        local vol = iSPSettings.iSPVolume or 100
        if vol >= 100 then
            return pcall(PlaySoundFile, path, ch)
        end
        local cvar = iSP.ChannelCVars[ch] or "Sound_MasterVolume"
        local origVol = tonumber(GetCVar(cvar)) or 1.0
        SetCVar(cvar, origVol * (vol / 100))
        local ok, err = pcall(PlaySoundFile, path, ch)
        C_Timer.After(0, function() SetCVar(cvar, origVol) end)
        return ok, err
    end

    local function PlayWithOptions()
        -- Try to play the sound
        local channel = iSPSettings.SoundChannel or "Master"
        local success, errorMsg = PlayWithVolume(soundPath, channel)

        if not success and iSPSettings.DebugMode then
            print(string.format(L["SoundFailed"], soundPath))
            return false
        elseif success and iSPSettings.ShowNotifications then
            print(string.format(L["SoundPlaying"], fileName))
        end

        -- Track active sound
        iSP.ActiveSounds[soundID] = {
            fileName = fileName,
            startTime = time(),
            timers = {},
        }

        -- If duration is set, we need to play another sound to "stop" it
        -- (WoW API limitation: can't actually stop a sound once started)
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
                PlayWithVolume(soundPath, iSPSettings.SoundChannel or "Master")

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

-- Test sound playback
function iSP:TestSound(fileName)
    print(string.format(L["SoundTesting"], fileName))
    return self:PlaySound(fileName)
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
    local options = {
        duration = trigger.duration or 0,
        startOffset = trigger.startOffset or 0,
        loop = trigger.loop or false,
        loopCount = trigger.loopCount or 1,
        fadeIn = trigger.fadeIn or false,
        fadeOut = trigger.fadeOut or false,
    }

    return self:PlaySound(trigger.sound, options)
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
-- │                              Addon Lifecycle Events                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iSP:OnAddonLoaded()
    -- Initialize settings
    self:InitializeSettings()

    -- Register trigger events
    self:RegisterTriggerEvents()

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
